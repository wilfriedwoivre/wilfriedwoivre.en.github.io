---
layout: post
title: Azure Network Security Perimeter - Centrally manage your ACLs 
date: 2024-12-04
categories: [ "Azure", "Network Security Perimeter" ]
githubcommentIdtoreplace: 
---

During Microsoft Ignite 2024, Microsoft announced the public preview of Network Security Perimeter.
Today, it's a public preview, and for my point of view, this product is a game changer for Azure Security (If all feature i dream will be here one day)
AS this product offer multiple features, i think i will be write multiple posts on this blog.

In this post, we will focus on managing ACL for your Azure services, and more specifically on the inbound IP source.

Start with how to create a Network Security Perimeter with bicep:

```bicep
resource nsp 'Microsoft.Network/networkSecurityPerimeters@2023-08-01-preview' = {
  name: 'demo${uniqueString(resourceGroup().id)}'
  location: loc
}
```

The service is created, now you need a profile. And my advice is to create at least 2 profiles, one with the Learning Mode for the tests, and one with the enforce mode to apply the rules. With the bicep autocompletion, its appears you have only this two mode available.
Today we will focus on the enforced mode, we will see the learning mode later, and how to exploit the learning phase to build the security around your services.

```bicep
resource nsp_enforce 'Microsoft.Network/networkSecurityPerimeters/profiles@2023-08-01-preview' = {
  name: 'enforce_profile'
  parent: nsp
  location: loc
  properties: {}
}

resource nsp_enforce_accessrule 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2023-08-01-preview' = {
  name: 'allowed_ip'
  parent: nsp_enforce
  location: loc
  properties: {
    direction: 'Inbound'
    addressPrefixes: [
      '28.38.76.11/32'
      '52.51.0.0/24'
    ]
  }
}
```

It is important to know that the possible IPS to be put here must absolutely be public, no RFC1918 here.

And to finish you must associate your profile with your Azure resources, and this is where you will define the mode of access to know: *Enforced*, *Learning*

```bicep
resource nsp_association_storage 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2023-08-01-preview' = {
  name: 'testwwonsp${uniqueString(resourceGroup().id, sto.id)}'
  parent: nsp
  location: loc
  properties: {
    accessMode: 'Enforced'
    profile: {
      id: nsp_enforce.id
    }
    privateLinkResource: {
      id: sto.id
    }
  }
}

resource nsp_association_keyvault 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2023-08-01-preview' = {
  name: 'testwwonsp${uniqueString(resourceGroup().id, key.id)}'
  parent: nsp
  location: loc
  properties: {
    accessMode:'Enforced'
    profile: {
      id: nsp_enforce.id
    }
    privateLinkResource: {
      id: key.id
    }
  }
}

resource nsp_association_eventhub 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2023-08-01-preview' = {
  name: 'testwwonsp${uniqueString(resourceGroup().id, eventhub.id)}'
  parent: nsp
  location: loc
  properties: {
    accessMode: 'Enforced'
    profile: {
      id: nsp_enforce.id
    }
    privateLinkResource: {
      id: eventhub.id
    }
  }
}

```

Now why I am ultra fan of Network Security Perimeter, it's simply because I define the list of my IPs only in one place, and I especially don't have to worry about applying it to all types of resources that I protect.
As a reminder if I wanted to do the same in bicep for my storage and keyvault services I would do the next bicep:

```bicep

resource sto_without_nsp 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stononsp${uniqueString(resourceGroup().id)}'
  location: loc
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'standard_lrs'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      ipRules: [
        {
          value: '28.38.76.11'
          action: 'Allow'
        }
        {
          value: '52.51.0.0/24'
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
  }
}

resource key_without_nsp 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'keynonsp${uniqueString(resourceGroup().id)}'
  location: loc
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    networkAcls: {
      bypass: 'AzureServices'
      ipRules: [
        {
          value: '28.38.76.11/32'
        }
        {
          value: '52.51.0.0/24'
        }
      ]
      defaultAction: 'Deny'
    }
  }
}

resource eventhub_without_nsp 'Microsoft.EventHub/namespaces@2024-05-01-preview' = {
  name: 'eventhubnonsp${uniqueString(resourceGroup().id)}'
  location: loc
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    isAutoInflateEnabled: false
    disableLocalAuth: true  
  }
}

resource eventhub_without_nspacl 'Microsoft.EventHub/namespaces/networkRuleSets@2024-05-01-preview' = {
  name: 'default'
  parent: eventhub_without_nsp
  properties: {
    defaultAction: 'Deny'
    ipRules: [
      {
        ipMask: '28.38.76.11/32'
        action: 'Allow'
      }
      {
        ipMask: '52.51.0.0/24'
        action: 'Allow'
      }
    ]
  }
}
```

So I have for my storage, Keyvault and EventHub 3 different implementations to put my rules.
Here Azure Storage does not support the ranges in /32, we are therefore obliged to put the IP, and for event hub it is an inner resource.

So we see that Network Security Perimeter will help us simplify our infra as code without being concerned about this part.
Or even a complex management of Policy to be set up to automatically add all the IPs you want.

Now it is a preview, and therefore I hope that other features will arrive because for the moment the big blockers that I see by adoption today are as follows:

- We don't see the security elements if we look at the details of the service via the portal, or via the PowerShell commands, for example:

```powershell
➜  (Get-AzKeyVault -name $keyVaultName -ResourceGroupName nsp).NetworkAcls

DefaultAction                 : Allow
Bypass                        : AzureServices
IpAddressRanges               :
IpAddressRangesText           :
VirtualNetworkResourceIds     :
VirtualNetworkResourceIdsText :
```

- No integration into Microsoft Defender for Cloud, my resources always seem exposed. And I guess it's the same for other CNAPPs.

- Not all Azure services are supported for example for this inbound IPs control.

But for me it is a service to monitor because it will be a game changer for the future of perimeter security in the public cloud.

Tell me in comments if you have other aspects of the service you want me to dig.
