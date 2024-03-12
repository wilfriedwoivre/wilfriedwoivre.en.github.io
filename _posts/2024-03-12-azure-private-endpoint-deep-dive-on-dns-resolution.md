---
layout: post
title: Azure Private Endpoint - Deep dive on DNS resolution
date: 2024-03-12
categories: [ "Azure", "Network", "Private Endpoint" ]
comments_id: 28 
---

It's been a while since I tell myself that the management of private endpoints on Azure is not that trivial as that. In my opinion, the Azure documentation can mislead you by making you believe that it will solve all your problems of access to your resources, security, and so on, and all with a few clicks of Azure.

So I decided to write to you several posts to help you use the private endpoint on Azure with the must knowledge as possible.
We will therefore see in these articles the following subjects:

- the different uses to access your private endpoints
- Securing your private link via Azure Policy

 And of course you think that another subject deserves to be dug there are the comments for this. 

Before I start, I shared all the scripts that I use in this [GitHub repository](https://github.com/wilfriedwoivre/labprivatelink), don't hesitate to contribute, and do not forget to delete well your resources as soon as you have finished your tests.
We will start with the basics namely the DNS resolution of your private endpoint from your compute when in a very basic architecture. So we need:

- 1 virtual network
- 1 Private DNS Zone for your private Endpoint (here: privatelink.blob.core.windows.net)
- 1 storage
- 1 virtual machine

This therefore gives us the following diagram:

![image]({{ site.url }}/images/2024/03/12/azure-private-endpoint-deep-dive-on-dns-resolution-img0.png)

Here in terms of configuration, we will keep the elements as standard as possible, namely the DNS configuration of our Virtual Network in **Default (Azure Provided)**, as below:

![alt text]({{ site.url }}/images/2024/03/12/azure-private-endpoint-deep-dive-on-dns-resolution-img1.png)

The implementation of this configuration indicates that we will use the Azure DNS to resolve all our routes, including that to resolve the address of my blog [https://woivre.fr] (https://woivre.fr ) or that to resolve your private endpoint.

![alt text]({{ site.url }}/images/2024/03/12/azure-private-endpoint-deep-dive-on-dns-resolution-img2.png)

So in terms of flows when we want to solve our private endpoint, we therefore do the following steps:

![alt text]({{ site.url }}/images/2024/03/12/azure-private-endpoint-deep-dive-on-dns-resolution-img3.png)

- 1 - DNS request for the blob storage **mystorage.blob.core.windows.net**
- 2 - DNS response: **CNAME mystorage.privatelink.blob.core.windows.net**
- 3 - DNS query for the address **mystorage.privatelink.blob.windows.net**
- 4 - DNS response: **A 10.0.0.4 mystorage.privatelink.blob.windows.net**
- 5 - Connection to our blob storage via its private endpoint

When we do our nslookup, we therefore have the following result:

```bash
[Run cmd]
nslookup labprivatelinkgi7jjcx.blob.core.windows.net
Enable succeeded: 
[stdout]
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
labprivatelinkgi7jjcx.blob.core.windows.net	canonical name = labprivatelinkgi7jjcx.privatelink.blob.core.windows.net.
Name:	labprivatelinkgi7jjcx.privatelink.blob.core.windows.net
Address: 10.0.0.4
```

Cependant tout est une question de DNS ici, si l'on passe par un DNS autre, on obtient un tout autre résultat

```bash
[Run cmd]
nslookup labprivatelinkgi7jjcx.blob.core.windows.net 8.8.8.8
Enable succeeded: 
[stdout]
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
labprivatelinkgi7jjcx.blob.core.windows.net	canonical name = labprivatelinkgi7jjcx.privatelink.blob.core.windows.net.
labprivatelinkgi7jjcx.privatelink.blob.core.windows.net	canonical name = blob.ams09prdstr13a.store.core.windows.net.
Name:	blob.ams09prdstr13a.store.core.windows.net
Address: 20.60.222.129
```

From a point of view of the DNS resolution, our storage is always present when we make Lookup DNS, this does not in any way influence whether our storage is accessible from the outside or not.
To block access from the outside, you will have to think about choosing the right option in the networking part of your storage.

Now that the simple part is discussed, let's look at how to expose our account of an external customer, which can be on Azure or any other infrastructure. We will therefore have the following diagram:

![alt text]({{ site.url }}/images/2024/03/12/azure-private-endpoint-deep-dive-on-dns-resolution-img4.png)

In terms of DNS resolution, we will therefore have something very simple since our customer B which is the same as when we have tried to resolve our field from the DNS of Google. So I'm not going to detail this point more.

Our last use box that we are going to approach is the case where your two customers have a private dns zone setup that is its own, but that customer B needs to call the customer to via its public address as we can see on the diagram below.

![alt text]({{ site.url }}/images/2024/03/12/azure-private-endpoint-deep-dive-on-dns-resolution-img5.png)

If we retry the same orders of nslookup, we will see that there is a concern when using the DNS provided by Microsoft:

```bash
[VM]
vm
[Run cmd]
nslookup labprivatelink7ev3eoy.blob.core.windows.net
Enable succeeded: 
[stdout]
Server:		127.0.0.53
Address:	127.0.0.53#53

** server can't find labprivatelink7ev3eoy.blob.core.windows.net: NXDOMAIN


[stderr]

------------------------------------------
[VM]
vm
[Run cmd]
nslookup labprivatelink7ev3eoy.blob.core.windows.net 8.8.8.8
Enable succeeded: 
[stdout]
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
labprivatelink7ev3eoy.blob.core.windows.net	canonical name = labprivatelink7ev3eoy.privatelink.blob.core.windows.net.
labprivatelink7ev3eoy.privatelink.blob.core.windows.net	canonical name = blob.ams09prdstr07a.store.core.windows.net.
Name:	blob.ams09prdstr07a.store.core.windows.net
Address: 20.60.223.100


[stderr]

------------------------------------------
```

From Google DNS, we have no worries, but since the Azure recursive resolver it doesn't work, because if we take the following diagram:

![alt text]({{ site.url }}/images/2024/03/12/azure-private-endpoint-deep-dive-on-dns-resolution-img3.png)

During step 2, Azure brings us a CNAME to Private Link that my customer B does not have. This scenario is valid for you to be in the same subscription, the same holder, or the same Azure environment, therefore in 99% of cases. The only exception is if one of your two customers use Azure China for example.

To resolve this, there are several means:

- Add a private endpoint from your B customer to your customer's storage and to enter the IP of its private endpoint in your private DNS zone.
- Use a personalized resolver DNS, on VMS for example to resolve this DNS explicitly via Google, and the rest via the Azure Recresh Resolver.
- Set up an Azure DNS Resolver at your B customer B to resolve this DNS from Google.
- In the series of bad ideas, you can always update the hosts of all the assets of customer B who need to use the storage and put the public IP of the storage (but it can change)

If we choose the Azure DNS Resolver option, our customer B must set up a ruleset to access the storage of our customer A. 
This ruleset will have the following configuration

```bicep
resource rule 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2022-07-01' = {
  parent: ruleset
  name: '${deployment().name}-google-rule'
  properties: {
    domainName: '${storageDomainName}.'
    targetDnsServers: [
      {
        ipAddress: '8.8.8.8'
      }
    ]
  }
}
```

Which will give us the following ARM template in the end

```json
{
    "type": "Microsoft.Network/dnsForwardingRulesets/forwardingRules",
    "apiVersion": "2022-07-01",
    "name": "dnsresolver-04-dnsresolver-customerB-ruleset/dnsresolver-04-dnsresolver-customerB-google-rule",
    "dependsOn": [
        "[resourceId('Microsoft.Network/dnsForwardingRulesets', 'dnsresolver-04-dnsresolver-customerB-ruleset')]"
    ],
    "properties": {
        "domainName": "labprivatelinkawdaptz.blob.core.windows.net.",
        "targetDnsServers": [
            {
                "ipAddress": "8.8.8.8",
                "port": 53
            }
        ],
        "forwardingRuleState": "Enabled"
    }
}
```

And we see in our test that the magic operates, and that we can resolve the IP of our Blob Storage from Google. But not that of the second storage created

```bash

[VM]
vm
[Run cmd]
nslookup labprivatelinkawdaptz.blob.core.windows.net
Enable succeeded: 
[stdout]
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
labprivatelinkawdaptz.blob.core.windows.net	canonical name = labprivatelinkawdaptz.privatelink.blob.core.windows.net.
labprivatelinkawdaptz.privatelink.blob.core.windows.net	canonical name = blob.ams09prdstr13c.store.core.windows.net.
Name:	blob.ams09prdstr13c.store.core.windows.net
Address: 20.209.10.97


[stderr]

------------------------------------------
[VM]
vm
[Run cmd]
nslookup labprivatelinkawdaptz.blob.core.windows.net 8.8.8.8
Enable succeeded: 
[stdout]
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
labprivatelinkawdaptz.blob.core.windows.net	canonical name = labprivatelinkawdaptz.privatelink.blob.core.windows.net.
labprivatelinkawdaptz.privatelink.blob.core.windows.net	canonical name = blob.ams09prdstr13c.store.core.windows.net.
Name:	blob.ams09prdstr13c.store.core.windows.net
Address: 20.209.10.97


[stderr]

------------------------------------------
[VM]
vm
[Run cmd]
nslookup labprivatelinkr6lcrfw.blob.core.windows.net
Enable succeeded: 
[stdout]
Server:		127.0.0.53
Address:	127.0.0.53#53

** server can't find labprivatelinkr6lcrfw.blob.core.windows.net: NXDOMAIN


[stderr]

------------------------------------------
[VM]
vm
[Run cmd]
nslookup labprivatelinkr6lcrfw.blob.core.windows.net 8.8.8.8
Enable succeeded: 
[stdout]
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
labprivatelinkr6lcrfw.blob.core.windows.net	canonical name = labprivatelinkr6lcrfw.privatelink.blob.core.windows.net.
labprivatelinkr6lcrfw.privatelink.blob.core.windows.net	canonical name = blob.ams20prdstr15a.store.core.windows.net.
Name:	blob.ams20prdstr15a.store.core.windows.net
Address: 20.209.108.75


[stderr]

------------------------------------------
```

Note that this kind of problem does not arise only with different customers. Within the same subscription, if you have a public storage and you connect it via a managed private endpoint to a synapse instance you will have the same behavior, and you will have to play on DNS or go to a private endpoint solution .
