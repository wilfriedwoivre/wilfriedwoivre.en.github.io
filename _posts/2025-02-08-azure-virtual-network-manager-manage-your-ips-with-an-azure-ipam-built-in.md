---
layout: post
title: Azure Virtual Network Manager - Manage your IPs with an Azure IPAM built in
date: 2025-02-08
categories: [ "Azure", "Network" ]
githubcommentIdtoreplace: 
---


Azure Virtual Manager is a tool to help you manage governance in the public cloud, and here particularly the network part.

For those who handle everyday network elements, you know that IPs management is an important point in order to avoid overlap, to identify your components or your environments. It is therefore necessary to have a mapping at one point to find out which IP belongs to whom and where it is in my ecosystem.

So it is possible to manage your IPS via different tools, passing from the Excel sheet (because Excel can do everything, even be the pillar of the worst tool idea to manage your tools) up to different IP Address Manager (IPAM) of the market, and there are a lot according to [Wikipedia](https://fr.wikipedia.org/wiki/Gestion_des_adresses_IP)

For me the essential elements of an IPAM are:

- The management of access to this one to add new ranges, and draw into these.
- Recover IPs from our infrastructure as code, namely reserving a range for my virtual network, and keep it even if I launch my stack 200 times.
- View the place available in my ranges.
- Research to know where my asset is in a search and not 2 hours of investigation, namely I type an IP type 10.0.0.4, I want to find the Pool of IP which corresponds, if a range has been allocated and to whom.

We will therefore look at what Microsoft provides us with, which has the advantage of being integrated into Azure, and therefore in the APIs of this one, that means that you can do bicep.

So we are going to create our Network Manager and our IPS Address Ranges.

```bicep
param location string = 'northeurope'

var cidr = '10.0.0.0/20'
var envPrefix = [for i in range(0, 2): cidrSubnet(cidr, 21, i)]

resource networkManager 'Microsoft.Network/networkManagers@2024-05-01' = {
  name: 'demo-networkmanager'
  location: location
  properties: {
    networkManagerScopes: {
      subscriptions: [
        subscription().id
      ]
    }
  }
}

resource globalPrefix 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'azure-rf1918-global'
  location: location
  parent: networkManager
  properties: {
    addressPrefixes: [
      cidr
    ]
  }
}

resource prdPrefix 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'azure-rf1918-prd'
  location: location
  parent: networkManager
  properties: {
    addressPrefixes: [
      envPrefix[0]
    ]
    parentPoolName: globalPrefix.name
  }
}

resource devPrefix 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'azure-rf1918-dev'
  location: location
  parent: networkManager
  properties: {
    addressPrefixes: [
      envPrefix[1]
    ]
    parentPoolName: globalPrefix.name
  }
}
```

Good point here, the creation is simple, we can quite easily add ranges, and even managed a notion of inheritance to subdivide our ranges.

Now for the allowance within a virtual network, it is possible to do like this, here I create 10 virtual networks, to make sure that it takes many different ranges:

```bicep
resource vnets 'Microsoft.Network/virtualNetworks@2024-05-01' = [
  for i in range(0, 8): {
    name: 'vnet-dev-${i}'
    location: location
    properties: {
      addressSpace: {
        ipamPoolPrefixAllocations: [
          {
            numberOfIpAddresses: '128'
            pool: {
              id: devPrefix.id
            }
          }
        ]
      }
    }
  }
]
```

Second good point, we can easily create our virtual network from bicep so that it can recover an IP from our IPAM.

For the occupation part of our ranges, here again we can see it simply from Azure:

![alt text]({{ site.url }}/images/2025/02/08/azure-virtual-network-manager-manage-your-ips-with-an-azure-ipam-built-in-img0.png)

So a good point for that.

And now for the search, we will say that it's brand new and that all the tools is improving over time. But to date the proposed search feature is only useful if you know what to look for and where.

In conclusion, Microsoft offers with this functionality something that had been eagerly awaited for several years, properly integrated with the APIs and the management of our network stacks, but which in my opinion still lacks some features to decide to change IPAM to this day.
