---
layout: post
title: Azure Policy - API version hell
date: 2023-11-05
categories: [ "Azure", "Policy" ]
comments_id: 34 
---

Azure is a product that evolves every day, a bit like user security needs. Unfortunately these developments are so fast that it is sometimes complicated to share them all, but also to follow them.

Interaction with Azure is always done via REST APIs which are clearly visible if you do arm or bicep, and unfortunately very often ignored if you use Azure only via Azcli or Azure PowerShell.

Take the example of EventHub with API versions[2017-04-01](https://learn.microsoft.com/en-us/rest/api/eventhub/namespaces/create-or-update?view=rest-eventhub-2017-04-01&tabs=HTTP#definitions&WT.mc_id=AZ-MVP-4039694) et [2024-01-01](https://learn.microsoft.com/en-us/rest/api/eventhub/namespaces/create-or-update?view=rest-eventhub-2024-01-01&tabs=HTTP#definitions&WT.mc_id=AZ-MVP-4039694), We can see that a good number of property have added as time goes by.

|2024-01-01|Available on 2017-04-01 |
|---|---|
|id|yes|
|identity.principalId|no|
|identity.tenantId|no|
|identity.type|no|
|identity.userAssignedIdentities|no|
|location|yes|
|name|yes|
|properties.alternateName|no|
|properties.clusterArmId|no|
|properties.createdAt|yes|
|properties.disableLocalAuth|no|
|properties.encryption.keySource|no|
|properties.encryption.keyVaultProperties|no|
|properties.encryption.requireInfrastructureEncryption|no|
|properties.isAutoInflateEnabled|yes|
|properties.kafkaEnabled|yes|
|properties.maximumThroughputUnits|yes|
|properties.metricId|yes|
|properties.minimumTlsVersion|no|
|properties.privateEndpointConnections|no|
|properties.provisioningState|yes|
|properties.publicNetworkAccess|no|
|properties.serviceBusEndpoint|yes|
|properties.status|no|
|properties.updatedAt|yes|
|properties.zoneRedundant|no|
|sku|yes|
|systemData|no|
|tags|yes|
|type|yes|

<p></p>

If you have read my previous article on [Azure Policy](https://woivre.com/blog/2023/10/azure-policy-a-powerful-tool-only-with-good-hands) You are entitled to ask yourself how it works with the property *minimmilTlsVersion*. And if you don't ask yourself the question, we're going to answer it here.

We will therefore create 2 Resources Groups the first with two Policy Deny and append as follows:

*Deny*

```json
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.EventHub/namespaces"
      },
      {
        "field": "Microsoft.EventHub/namespaces/minimumTlsVersion",
        "exists": true
      },
      {
        "field": "Microsoft.EventHub/namespaces/minimumTlsVersion",
        "notEquals": "1.2"
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
```

*Append*:

```json
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.EventHub/namespaces"
      },
      {
        "field": "Microsoft.EventHub/namespaces/minimumTlsVersion",
        "exists": false
      }
    ]
  },
  "then": {
    "effect": "append",
    "details": [
      {
        "field": "Microsoft.EventHub/namespaces/minimumTlsVersion",
        "value": "1.2"
      }
    ]
  }
}
```

We will then deploy our next bicep with the oldest version of the API

```bicep
resource eventhub 'Microsoft.EventHub/namespaces@2017-04-01' = {
  name: 'wwo${deployment().name}${uniqueString(resourceGroup().id)}'
#disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    capacity: 1
  }
}
```

It therefore gives us this:

```powershell
New-AzrRsourceGroupDeployment -name test -ResourceGroupName eventhub-denyappendpolicy-rg -TemplateFile .\main.bicep | Out-Null
(Get-AzEventHubNamespace -ResourceGroupName eventhub-denyappendpolicy-rg).minimumTLSVersion

1.0
```

We can see here that despite our Azure Policy, our Hub event is always with a minimum TLS in 1.0.
But hey according to Azure everything went well during the deployment

![alt text]({{ site.url }}/images/2023/11/05/azure-policy-api-version-hell-img0.png)

Now we're going to try to do the same with the following Policy:

```json
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.EventHub/namespaces"
      }
    ]
  },
  "then": {
    "effect": "modify",
    "details": {
      "operations": [
        {
          "operation": "addOrReplace",
          "field": "Microsoft.EventHub/namespaces/minimumTlsVersion",
          "value": "1.2"
        }
      ],
      "roleDefinitionIds": [
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      ]
    }
  }
}
```

So we launch the same PowerShell command

```powershell
New-AzResourceGroupDeploymen -name test -ResourceGroupName eventhub-modifypolicy-rg -TemplateFile .\main.bicep | Out-Null (Get-AzEventHubNamespace -ResourceGroupName eventhub-modifypolicy-rg).minimumTLSVersion

New-AzResourceGroupDeployment: 3:26:51 PM - Error: Code=InvalidTemplateDeployment; Message=The template deployment failed because of policy violation. Please see details for more information.
New-AzResourceGroupDeployment: 3:26:51 PM - Error: Code=NonModifiablePolicyAlias; Message=The aliases: 'Microsoft.EventHub/namespaces/minimumTlsVersion' are not modifiable in requests using API version: '2017-04-01'. This can happen in requests using API versions for which the aliases do not support the 'modify' effect, or support the 'modify' effect with a different token type.
New-AzResourceGroupDeployment: 3:26:51 PM - Error: Code=PolicyViolation; Message=Unable to apply 'modify' operation using the alias: 'Microsoft.EventHub/namespaces/minimumTlsVersion'. This alias is not modifiable in requests using API versions: '2021-11-01,2021-06-01-preview,2021-01-01-preview,2018-01-01-preview,2017-04-01,2015-08-01,2014-09-01'. See https://aka.ms/policy-modify-conflicts for details. Policies: '{"policyAssignment":{"name":"eventhub-modify-tls","id":"/subscriptions/9d854bbf-c6b3-4b03-a3de-cc4dc16cad0f/resourceGroups/eventhub-modifypolicy-rg/providers/Microsoft.Authorization/policyAssignments/9a2a2c2a500740c69c10bb47"},"policyDefinition":{"name":"eventhub-modify-tls","id":"/subscriptions/9d854bbf-c6b3-4b03-a3de-cc4dc16cad0f/providers/Microsoft.Authorization/policyDefinitions/9ea2d44b-9311-4896-8c2d-dd0cd7907e8f"}}'
New-AzResourceGroupDeployment: The deployment validation failed
```

So certainly the deployment doesn't work, but we are clearly told that the alias is not supported by the version API that we use. We only have to update our version API in our bicep template.
