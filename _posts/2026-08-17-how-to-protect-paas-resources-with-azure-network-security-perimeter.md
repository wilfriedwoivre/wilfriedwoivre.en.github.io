---
layout: post
title: How to Protect PaaS Resources with Azure Network Security Perimeter
date: 2026-08-17
categories: [Azure, Network Security Perimeter]
githubcommentIdtoreplace:
---

Azure PaaS resources are often central to modern cloud applications, but they can also be difficult to secure because they are frequently accessed from different services, pipelines, and users. Azure Network Security Perimeter provides a useful way to define a tighter security boundary around these resources.

When you protect PaaS resources with NSP, you are not only controlling network paths. You are also shaping how the resource can be reached and by whom. This is especially valuable for services that store sensitive data or expose APIs to internal systems.

## Typical use cases

NSP is a good fit when you want to:

- Limit access to Azure Storage accounts used by critical workloads
- Protect Key Vault instances from unnecessary public access
- Reduce exposure for web apps and other managed services
- Enforce consistent access controls across multiple resources in the same environment

## Recommended approach

A practical deployment usually starts with identifying the resources that need the highest level of protection. Then you define the perimeter and decide which identities or services are allowed to connect. The goal is to avoid overly broad access rules while keeping the environment operational.

In many cases, NSP works best when it is combined with other Azure security mechanisms such as private endpoints, role-based access control, and centralized monitoring.

## A Bicep skeleton for a protected PaaS perimeter

A simple way to represent the perimeter in infrastructure as code is shown below:

```bicep
targetScope = 'resourceGroup'

@description('Name of the perimeter protecting shared PaaS resources')
param perimeterName string = 'shared-paas-prod-nsp'

@description('Storage account that should be protected by the perimeter')
param storageAccountId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod/providers/Microsoft.Storage/storageAccounts/stappprod001'

resource perimeter 'Microsoft.Network/networkSecurityPerimeters@2024-05-01' = {
  name: perimeterName
  location: 'global'
  tags: {
    Environment: 'prod'
    Workload: 'FinanceApp'
    SecurityBoundary: 'PaaS'
  }
  properties: {
    accessRules: [
      {
        name: 'allow-shared-services'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          description: 'Allow requests from the shared services subnet'
          addressPrefixes: [
            '10.10.20.0/24'
          ]
          destinationPortRanges: [
            '443'
          ]
        }
      }
    ]
    // Link the protected resource and define any additional policy
    // associations as part of your deployment workflow.
  }
}

output perimeterResourceId string = perimeter.id
output protectedStorageAccountId string = storageAccountId
```

This shows the anchor point for your protected resource boundary. The next step is to define the specific rules that allow only the right identities and services to connect.

## What to watch for

One of the main challenges when implementing NSP is keeping the policy understandable. If a perimeter becomes too permissive, the benefit is reduced. It is better to start with a focused scope and expand it carefully as you validate the access pattern.

This makes NSP especially appealing for teams that want to apply network controls without turning every resource into a custom networking project.

In the next article, I will compare NSP with private endpoints and show where each approach is strongest.
