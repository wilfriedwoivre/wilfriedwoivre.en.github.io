---
layout: post
title: Azure Storage - Migrate your ACLs to NSP without downtime
date: 2026-09-25
categories: [ "Azure", "Storage", "Network Security Perimeter" ]
comments_id: 72 
---

If you have ever had to tighten Azure Storage access, you know the main problem is not the feature itself. It is doing it without breaking the workload that depends on it.

This is where Azure Network Security Perimeter (NSP) is useful. You can add a clearer trust boundary around the resource before removing older networking rules. In other words, you move from a fragile set of exceptions to a structured access model without a risky cutover.

The usual approach is simple:

1. Identify the real source networks that must still reach the storage account.
2. Create the NSP allow rule for those sources.
3. Keep the existing network ACLs in place temporarily.
4. Validate that the app can still reach the resource.
5. Remove the legacy rules only after the new model is proven.

This gives you a zero-downtime migration path: add the new boundary first, validate, then reduce the old one.

```bicep
@description('Trusted app subnet that should reach storage')
param appSubnetPrefix string = '10.20.30.0/24'

@description('Storage account name')
param storageAccountName string = 'stnspdemo${uniqueString(resourceGroup().id)}'

var vnetName = 'vnet-prod-shared'
var subnetName = 'snet-app'

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          action: 'Allow'
        }
      ]
    }
  }
}

resource perimeter 'Microsoft.Network/networkSecurityPerimeters@2024-05-01' = {
  name: 'nsp-prod-storage'
  location: 'global'
  properties: {
    accessRules: [
      {
        name: 'allow-app-subnet'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          description: 'Allow trusted workload subnet to reach Azure Storage'
          addressPrefixes: [
            appSubnetPrefix
          ]
          destinationPortRanges: [
            '443'
          ]
        }
      }
    ]
  }
}

resource associatedResource 'Microsoft.Network/networkSecurityPerimeters/associatedResources@2024-05-01' = {
  parent: perimeter
  name: 'storage-association'
  properties: {
    resource: {
      id: storageAccount.id
    }
  }
}
```

This is intentionally minimal. The goal is not to model every environment. The goal is to show the migration pattern clearly: define the trust boundary, validate it, and only then remove the older ACLs.

The real value of NSP here is not just stronger security. It is clarity. When the allowed path is expressed in one place, the storage boundary becomes easier to explain, validate, and maintain.

That is usually the safest and most practical way to tighten Azure Storage access without downtime.

