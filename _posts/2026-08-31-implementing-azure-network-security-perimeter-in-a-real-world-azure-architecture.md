---
layout: post
title: Implementing Azure Network Security Perimeter in a Real-World Azure Architecture
date: 2026-08-31
categories: [Azure, Network Security Perimeter]
githubcommentIdtoreplace: 
---

By the time you reach the implementation stage, Azure Network Security Perimeter becomes much more tangible. The real value appears when you apply it to an architecture that already includes shared services, workloads, and multiple teams.

A common scenario is a landing zone where several applications use Azure PaaS services such as Storage, Key Vault, and App Service. In that type of environment, NSP can help you define the trust boundary around sensitive resources and make access expectations more explicit.

## A sample architecture pattern

A practical pattern might look like this:

- A shared platform layer with identity, monitoring, and shared services
- Application workloads deployed in different workspaces or subscriptions
- Protected services that should only be reachable from approved internal paths
- Access policies that align with business and security requirements

In this kind of setup, NSP provides a way to enforce the boundary without forcing every resource to be redesigned from scratch.

## Implementation considerations

When implementing NSP in a real environment, it helps to start with a small scope. Choose a few critical resources, define their expected access pattern, and validate the policy before expanding it further. This approach tends to be more manageable than trying to secure everything at once.

You should also involve the teams that own the resources. They often know the legitimate access flows better than anyone else, and that context is essential for building accurate policies.

## A more realistic Bicep example

In a landing zone, you can start with a simple perimeter definition and then extend it as your access rules become clearer:

```bicep
targetScope = 'resourceGroup'

@description('Name of the perimeter used in the landing zone')
param perimeterName string = 'landingzone-prod-nsp'

@description('Key Vault instance to protect within the perimeter')
param keyVaultId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod/providers/Microsoft.KeyVault/vaults/kv-platform-prod'

@description('App Service that shares the same trust boundary')
param appServiceId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod/providers/Microsoft.Web/sites/app-prod-api'

resource perimeter 'Microsoft.Network/networkSecurityPerimeters@2024-05-01' = {
  name: perimeterName
  location: 'global'
  tags: {
    Environment: 'prod'
    Platform: 'LandingZone'
    Owner: 'Platform Engineering'
  }
  properties: {
    accessRules: [
      {
        name: 'allow-platform-operations'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          description: 'Allow platform operations and automation services'
          addressPrefixes: [
            '10.30.10.0/24'
          ]
          destinationPortRanges: [
            '443'
          ]
        }
      }
    ]
    // Link protected resources and define approved inbound sources here.
  }
}

output perimeterId string = perimeter.id
output protectedResources array = [
  keyVaultId
  appServiceId
]
```

This skeleton is a good starting point for a shared platform environment. From there, you can refine the rules so that only the intended apps, identities, and services are allowed into the protected boundary.

## The long-term benefit

The main benefit of NSP is not only stronger security. It is also better consistency. When access control is expressed in a clear and reusable way, it becomes easier to maintain over time and much simpler to explain to other teams.

If you are planning to strengthen your Azure networking posture, NSP is worth exploring as part of a broader strategy that includes private connectivity, identity controls, and monitoring.
