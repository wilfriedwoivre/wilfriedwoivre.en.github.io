---
layout: post
title: Azure Bicep - Register provider feature from your template
date: 2024-04-02
categories: [ "Azure", "Bicep" ]
githubcommentIdtoreplace: 
---

When you have multiple Azure subscriptions, it can be helpful to activate provider feature on all.

You can always use REST API / Az CLI / Azure Powershell as mentioned on Azure documatation, but you can also do it with this bicep:

```bicep
targetScope='subscription'

param providerName string = 'Microsoft.ContainerService'
param featureName string = 'AKS-PrometheusAddonPreview'

resource feature 'Microsoft.Features/featureProviders/subscriptionFeatureRegistrations@2021-07-01' = {
  name: '${providerName}/${featureName}'
}
```

Or this ARM version:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "providerName": {
      "type": "string",
      "defaultValue": "Microsoft.ContainerService"
    },
    "featureName": {
      "type": "string",
      "defaultValue": "AKS-PrometheusAddonPreview"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Features/featureProviders/subscriptionFeatureRegistrations",
      "apiVersion": "2021-07-01",
      "name": "[format('{0}/{1}', parameters('providerName'), parameters('featureName'))]"
    }
  ]
}
```

The good point of use bicep or ARM is that you can use it on Blueprint, Template Specs or Deployment Stacks regarding your use cases.
