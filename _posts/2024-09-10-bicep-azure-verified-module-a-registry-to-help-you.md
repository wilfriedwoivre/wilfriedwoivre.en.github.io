---
layout: post
title: Bicep - Azure Verified Module, a registry to help you
date: 2024-09-10
categories: [ "Azure", "Bicep" ]
comments_id: 43 
---

If you have not followed the new features around Bicep, it is possible to create modules, and put them in a private registration via Azure Container Registry, I would surely make an article soon.

And now if we want to make a public registry, well today it is not possible, but Microsoft hosts for you Azure Verified Module which is also based on Azure Container Registry but which contains a set of modules validated by Microsoft based on Open Source Restity: [Azure Verified Module](https://github.com/Azure/bicep-registry-modules)

Recently I updated my Sandbox Toolkit based on Azure Function, and I decided among other things to redo my infra as code thanks to AVM, so I suggest making a feedback on it.

Let's start by creating an Azure storage:

```bicep
module stg 'br/public:avm/res/storage/storage-account:0.11.1' = {
  name: 'sandbox-storage'
  scope: resourceGroup
  params: {
    name: 'stg${uniqueString(resourceGroup.id)}'
    skuName: 'Standard_LRS'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}
```

So firstly it is very simple to access via VsCode since the search for modules is done directly with autocompletion, it remains up to know Azure Resource Providers you want to use.
And good news, it is easily to explore the contents of the module that you simply use via a click in VsCode, no need to refer to the Github.

For having implemented modules which is important to define is the management of your input and output parameters of the module, and good news AVM contains standards on these elements and offers a lot of parameter with default values For all (apart from the name of course), and good news these parameters are typical, so you will be well guided when creating your templates, and in the build of your bicep file will fail if you have not followed the typing .

Now, everything is not perfect, and it is an open source project, so the level of templates is not always the same, for example if I take storage I have these elements for the NetworkAcls part:

```bicep
@description('Optional. Networks ACLs, this value contains IPs to whitelist and/or Subnet information. If in use, bypass needs to be supplied. For security reasons, it is recommended to set the DefaultAction Deny.')
param networkAcls networkAclsType?

type networkAclsType = {
  @description('Optional. Sets the resource access rules. Array entries must consist of "tenantId" and "resourceId" fields only.')
  resourceAccessRules: {
    @description('Required. The ID of the tenant in which the resource resides in.')
    tenantId: string

    @description('Required. The resource ID of the target service. Can also contain a wildcard, if multiple services e.g. in a resource group should be included.')
    resourceId: string
  }[]?

  @description('Optional. Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics.')
  bypass: (
    | 'None'
    | 'AzureServices'
    | 'Logging'
    | 'Metrics'
    | 'AzureServices, Logging'
    | 'AzureServices, Metrics'
    | 'AzureServices, Logging, Metrics'
    | 'Logging, Metrics')?

  @description('Optional. Sets the virtual network rules.')
  virtualNetworkRules: array?

  @description('Optional. Sets the IP ACL rules.')
  ipRules: array?

  @description('Optional. Specifies the default action of allow or deny when no other rules match.')
  defaultAction: ('Allow' | 'Deny')?
}
```

While for Keyvault, it's much more light:

```bicep
@description('Optional. Rules governing the accessibility of the resource from specific network locations.')
param networkAcls object?
```

Afterwards, I remind you that this is an open source project, so I strongly encourage you to contribute if something is missing, of course if you have time. They are also looking for: [Needs Contributor](https://github.com/Azure/Azure-Verified-Modules/issues?q=is:issue+label:%22Needs:+Module+Contributor+:mega:%22+)

The use of this type of module will allow you to speed up the implementation of your templates based on these modules, and not to have to redo them on your side.
And as a bonus, since it is a module you can always use yours if you wish.

Since good news never comes alone, this registry also contains tests for each of the resources you can press to find the settings you need, for example for storage:

For example, the implementation of a Kind type `BlockBlobStorage`

```bicep
targetScope = 'subscription'

metadata name = 'Deploying as a Block Blob Storage'
metadata description = 'This instance deploys the module as a Premium Block Blob Storage account.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-storage.storageaccounts-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'ssablock'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

// ============== //
// Test Execution //
// ============== //

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      location: resourceLocation
      name: '${namePrefix}${serviceShort}001'
      skuName: 'Premium_LRS'
      kind: 'BlockBlobStorage'
    }
  }
]
```

But also lots of others, such as the management of encryption keys.

AVM does not only contain modules for Azure Resources, but also for user patterns, such as the implementation of the Landing Zone of Test (given the criticality of the subject, I advise you to use an external module only for tests)

And finally, Azure Verified Module is not an initiative that for Bicep, but also for Terraform!

Well and if I was going to make a request for a request now...
