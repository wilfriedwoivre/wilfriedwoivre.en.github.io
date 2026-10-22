---
layout: post
title: Azure Service Endpoint - Standard vs Basic
date: 2026-10-22
categories: [ "Azure", "Network", "Network Security Perimeter" ]
comments_id: 73 
---

Service endpoints are the oldest trick in the Azure network security book. They are free, easy, and they have been quietly hitting a wall at scale for years. On October 15, 2026, Microsoft made Standard service endpoint generally available, and the interesting question is whether it is worth paying for something that used to be free.

Spoiler: it depends on how many subnets you have, and on how much you hate maintaining ACLs.

A *Basic* service endpoint is enabled per subnet and per service type. Traffic to the PaaS service then leaves your subnet with the subnet’s identity, over the Microsoft backbone. The PaaS service still uses its public endpoint, and you tell its firewall to accept that subnet:

```bicep
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  name: 'snet-app'
  parent: vnet
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: [
      { service: 'Microsoft.Storage' }
    ]
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stbasicse001'
  location: location
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        { id: subnet.id, action: 'Allow' }
      ]
    }
  }
}
```

It works, and it costs nothing. The problem is the model: every subnet has to be listed on every PaaS resource. In a landing zone with a dozen spokes, a few subnets each and a handful of storage accounts and Key Vaults, you are maintaining hundreds of ACL entries. Every new subnet means touching the PaaS side. At large scale, you also start hitting the resource provider limits and throttling.

**What is Standard service endpoint?**

Standard introduces a network identifier: a public IP address that you attach to the service endpoint on your subnets. That IP is not used for routing. It is only a label that identifies your traffic.

The PaaS side then stops caring about subnets. You put your resources in a Network Security Perimeter and add one inbound IP rule matching the network identifier. Since the same public IP can be shared by many subnets, VNets and even subscriptions (same tenant, same region), one rule covers the whole estate.

The identifier has strict requirements: a Standard SKU, static, IPv4 public IP that already exists and is in Succeeded state before you associate it.

Supported services at GA: Storage, Key Vault, SQL Database and Cosmos DB.

A quick comparison for the both services :

|Capability|Basic service endpoint|Standard service endpoint|Private Link
|---|---|---|---|
|Private connectivity (no public endpoint exposed)|No|No|Yes
|On-premises access|No|No|Yes
|Data exfiltration protection|No|No|Yes
|Setup effort|Simple|Simple|Complex (DNS, approvals)
|Scales to many subnets|No|Yes|Yes
|Supported services|~10|4|70+
|Pricing|Free|Paid|Paid

Note that Standard does not close any of the gaps Private Link closes. It is still a public endpoint. What it fixes is manageability and scale. On the plus side, there is no private DNS zone to manage, which, if you read my [DNS deep dive](https://woivre.com/blog/2024/03/azure-private-endpoint-deep-dive-on-dns-resolution), is not a small advantage.

_**Cost**_

- **Basic**: free.
- **Standard**: a fixed hourly rate per virtual network, with no meter per subnet or per endpoint. Preview-era documentation mentioned a no-charge period, but the GA documentation is clear that it is a paid feature. You also pay for the Standard public IP you use as the identifier, like any other Standard public IPv4.
- **Private endpoint** (for comparison): an hourly rate per endpoint, plus data processed per GB.

The exact rate varies by region, so use the Azure pricing calculator. The formula is simple:

- monthly cost ≈ hourly rate × 730 h × number of VNets with Standard enabled

For 12 spoke VNets, that is 12 × 730 = 8,760 billed hours a month, times your regional rate. Compare that with the cost of a private endpoint per PaaS resource per VNet that needs access, and the cost of the engineer-hours spent maintaining ACLs.

**Example**: 12 spokes reaching one storage account and one Key Vault

Assume 12 spoke VNets with 2 subnets each, all calling the same two PaaS resources.

| \ | Basic | Standard |
|---|---|---|
|ACL entries on PaaS side|24 subnets × 2 resources = 48|1 NSP rule (the identifier range)|
|New subnet|Update every PaaS resource|Attach the identifier, nothing else|
|Cost|Free|12 VNets × hourly rate|

Here is the Standard Service Endpoint setup in CLI:

```bash
# 1. Network identifier: Standard, static IPv4, taken from a prefix
az network public-ip prefix create -g rg-network -n pipprefix-se --length 31 -l westeurope
az network public-ip create -g rg-network -n pip-se-identifier \
  --public-ip-prefix pipprefix-se --sku Standard --allocation-method Static

# 2. Attach it to the service endpoint on each subnet
az network vnet subnet update -g rg-spoke01 --vnet-name vnet-spoke01 -n snet-app \
  --add serviceEndpoints '{"service":"Microsoft.Storage","networkIdentifier":{"id":"/subscriptions/<sub-id>/resourceGroups/rg-network/providers/Microsoft.Network/publicIPAddresses/pip-se-identifier"}}'

# 3. Perimeter + profile
az network perimeter create -n nsp-paas -g rg-network -l westeurope
az network perimeter profile create --perimeter-name nsp-paas -g rg-network -n profile-spokes

# 4. Associate the PaaS resource in Learning mode first
az network perimeter association create --perimeter-name nsp-paas -g rg-network \
  --association-name assoc-storage --access-mode Learning \
  --profile "{id:/subscriptions/<sub-id>/resourceGroups/rg-network/providers/Microsoft.Network/networkSecurityPerimeters/nsp-paas/profiles/profile-spokes}" \
  --private-link-resource "{id:/subscriptions/<sub-id>/resourceGroups/rg-data/providers/Microsoft.Storage/storageAccounts/<storage-name>}"

# 5. One inbound rule for the whole estate
az network perimeter profile access-rule create --perimeter-name nsp-paas -g rg-network \
  --profile-name profile-spokes --access-rule-name allow-se-standard \
  --direction Inbound --address-prefixes "<prefix-range>"
```

The same thing in Bicep for the subnet side. The property shape comes from the CLI payload above, so use the latest API version that exposes networkIdentifier:

```bicep
resource networkIdentifier 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-se-identifier'
  location: location
  sku: { name: 'Standard' }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  name: 'snet-app'
  parent: vnet
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
        networkIdentifier: { id: networkIdentifier.id }
      }
    ]
  }
}
```

Learning mode is not optional in my book. As in my [NSP migration](https://woivre.com/blog/2026/09/azure-storage-migrate-your-acls-to-nsp-without-downtime) post, watch the perimeter diagnostic logs for one to two weeks before switching to Enforced. Microsoft recommends the same.

**Basic service endpoint**

| Pros | Cons |
| -- | -- | 
| Free | Every subnet must be listed on every PaaS resource |
| Very simple, no DNS changes | ACL sprawl and resource provider limits at scale |
| Around 10 supported services | Subnet lifecycle changes ripple into PaaS configuration |
| No perimeter or public IP to design | No centralized, perimeter-based access model |


**Standard service endpoint**

| Pros | Cons |
| -- | -- |
| One public IP identifies many subnets, VNets and subscriptions | Paid, per VNet per hour |
| One NSP rule instead of N×M ACL entries | Only 4 services at GA |
| Subnet changes don’t touch PaaS rules | Still a public endpoint, with no exfiltration protection and no on-premises access |
| Perimeter logging and Learning mode | Requires NSP and a Standard public IP |
| Still simple: no private DNS zone, no approval flow | |

My advisory : 

- Stay on Basic if you have a handful of subnets, one or two PaaS resources and a tight budget. Free and simple is hard to beat.
- Move to Standard when ACL maintenance becomes a real chore: many spokes, many subscriptions, subnets created by other teams. It is also the natural choice if you are already adopting NSP.
- Go to Private Link when you need real private connectivity, on-premises access or exfiltration protection. Standard does not replace it. It sits between Basic and Private Link.
- Stay on Basic if you already have a robust automation to manage ACL at scale for all of your PaaS resources.

Free was nice, but a flat hourly fee per VNet is a fair price for deleting a few hundred ACL entries.
