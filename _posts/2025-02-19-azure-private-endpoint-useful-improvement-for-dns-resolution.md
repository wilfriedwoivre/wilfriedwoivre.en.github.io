---
layout: post
title: Azure Private Endpoint - Useful improvement for DNS resolution
date: 2025-02-19
categories: [ "Azure", "Network", "Private Endpoint" ]
githubcommentIdtoreplace: 
---

In a previous [post](https://woivre.com/blog/2023/11/azure-policy-api-version-hell), I told you about the DNS resolution of the private endpoint and how it can be complicated when you have several actors in play, or that you use managed private endpoint.

 At the time I had offered a solution based on Azure DNS Resolver to redirect the Forward DNS to a public DNS like Google.

 Well, know that from Microsoft has released a new feature where it is possible to bring this configuration to the level of your private DNS zone. Thanks to this bicep there __Resolutionpolicy: 'nxdomainredirect'__:

```bicep
resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: 'link-to-vnet-${uniqueString(deployment().name)}'
  parent: privateDnsZone
  tags: tags
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
    resolutionPolicy: 'NxDomainRedirect'
  }
}
```

This option is very practical, since in our Lab we go from this result:

```bash

[VM]
vm
[Run cmd]
nslookup labprivatelinkv5b65ik.blob.core.windows.net
Enable succeeded:
[stdout]
Server:         127.0.0.53
Address:        127.0.0.53#53

** server can't find labprivatelinkv5b65ik.blob.core.windows.net: NXDOMAIN


[stderr]

------------------------------------------
[VM]
vm
[Run cmd]
nslookup labprivatelinkv5b65ik.blob.core.windows.net 8.8.8.8
Enable succeeded:
[stdout]
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
labprivatelinkv5b65ik.blob.core.windows.net     canonical name = labprivatelinkv5b65ik.privatelink.blob.core.windows.net.
labprivatelinkv5b65ik.privatelink.blob.core.windows.net canonical name = blob.ams09prdstr07a.store.core.windows.net.
Name:   blob.ams09prdstr07a.store.core.windows.net
Address: 20.60.223.100


[stderr]
```

à celui là :

```bash
[VM]
vm
[Run cmd]
nslookup labprivatelinkv5b65ik.blob.core.windows.net
Enable succeeded:
[stdout]
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
labprivatelinkv5b65ik.blob.core.windows.net     canonical name = labprivatelinkv5b65ik.privatelink.blob.core.windows.net.
labprivatelinkv5b65ik.privatelink.blob.core.windows.net canonical name = blob.ams09prdstr07a.store.core.windows.net.
Name:   blob.ams09prdstr07a.store.core.windows.net
Address: 20.60.223.100


[stderr]

------------------------------------------
[VM]
vm
[Run cmd]
nslookup labprivatelinkv5b65ik.blob.core.windows.net 8.8.8.8
Enable succeeded:
[stdout]
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
labprivatelinkv5b65ik.blob.core.windows.net     canonical name = labprivatelinkv5b65ik.privatelink.blob.core.windows.net.
labprivatelinkv5b65ik.privatelink.blob.core.windows.net canonical name = blob.ams09prdstr07a.store.core.windows.net.
Name:   blob.ams09prdstr07a.store.core.windows.net
Address: 20.60.223.100


[stderr]

------------------------------------------
```

So no need to set up unitary forWarde, and you can let azure manage this part there for you. A time saving especially when you work with tools like Synapse or Fabric which offers to create Managed Private Endpoint for many of your services.

I would update the lab to add this use box to the list.
