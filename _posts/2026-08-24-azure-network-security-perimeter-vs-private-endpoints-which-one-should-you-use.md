---
layout: post
title: Azure Network Security Perimeter vs Private Endpoints: Which One Should You Use?
date: 2026-08-24
categories: [Azure, Network Security Perimeter]
githubcommentIdtoreplace:
---

Azure Network Security Perimeter and private endpoints are both powerful mechanisms for improving resource protection, but they are not interchangeable. Understanding their differences is essential when designing secure Azure architectures.

Private endpoints are mainly focused on creating a private network path to a specific Azure service. They are often used to ensure that traffic stays within a virtual network and avoids the public internet. In contrast, NSP focuses on the security boundary around a resource and provides a broader access-control model for protecting groups of resources.

## When private endpoints are a strong choice

Private endpoints are ideal when you want to:

- Ensure a resource is reachable only through a private network path
- Reduce exposure to the public endpoint
- Build strong network isolation for a specific service

## When NSP is more appropriate

NSP is usually more relevant when you want to:

- Protect a set of related resources with shared access rules
- Apply resource-centric security policies consistently
- Improve governance across a broader Azure environment

## A practical way to think about them

A useful way to frame the relationship is this: private endpoints focus on connectivity, whereas NSP focuses on perimeter-based access control. In many architectures, they complement each other rather than compete.

You might use private endpoints to isolate a critical service and NSP to enforce a consistent security boundary around a collection of resources that share the same protection requirements.

## A Bicep comparison example

Here is a small example that shows the two patterns at a high level:

```bicep
targetScope = 'resourceGroup'

@description('Storage account that should be reachable through a private path')
param storageAccountId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data-prod/providers/Microsoft.Storage/storageAccounts/stdataprod001'

@description('Subnet used for the private endpoint')
param privateSubnetId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod/subnets/snet-private-endpoints'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-11-01' = {
  name: 'pe-stdataprod001'
  location: resourceGroup().location
  tags: {
    Environment: 'prod'
    Purpose: 'Private access'
  }
  properties: {
    subnet: {
      id: privateSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-stdataprod001-blob'
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [ 'blob' ]
        }
      }
    ]
  }
}

resource perimeter 'Microsoft.Network/networkSecurityPerimeters@2024-05-01' = {
  name: 'app-prod-nsp'
  location: 'global'
  tags: {
    Environment: 'prod'
    SecurityBoundary: 'Shared services'
  }
  properties: {
    accessRules: [
      {
        name: 'allow-app-subnet'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          description: 'Allow application workloads to reach protected services'
          addressPrefixes: [
            '10.15.40.0/24'
          ]
          destinationPortRanges: [
            '443'
          ]
        }
      }
    ]
    // Use this when you need a resource-centric access control model
    // for a group of protected services.
  }
}
```

The private endpoint creates a private path, while the perimeter focuses on the access policy around protected resources. In many architectures, both are useful, but for different reasons.

## Final recommendation

If you are still deciding between the two, start by asking what problem you are trying to solve. If you need private connectivity, private endpoints are the natural answer. If you need stronger and more centralized access control for protected resources, NSP deserves serious consideration.

In the next article, I will show how to apply these concepts in a realistic Azure architecture.
