---
layout: post
title: Bicep - Create Entra ID object from your template
date: 2024-05-31
categories: [ "Azure", "Bicep", "Entra ID" ]
comments_id: 41 
---

Recently we can create objects Entra ID via our Bicep templates.
This does not concern all types of objects to date, but we can only hope.

To do this, you need a version of Bicep > 0.27.1, and deploy from AzCLI or Az Powershell, this is not possible from VsCode today (but soon)

Let's start by editing our config file to add this configuration

```json
"experimentalFeaturesEnabled": {
    "extensibility": true
  }
```

And now here is our bicepin:

```bicep
provider microsoftGraph 

resource groupTest 'Microsoft.Graph/groups@v1.0' = { 
  displayName: 'groupTestbicep' 
  mailEnabled: false 
  mailNickname: 'groupTest' 
  securityEnabled: true 
  description: 'groupTest' 
  uniqueName: 'groupTestbicep'
}
```

We must not forget to add the provider to our template.

After deployment, we can of course see the ARM template which is used

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "languageVersion": "2.1-experimental",
    "contentVersion": "1.0.0.0",
    "imports": {
        "microsoftGraph": {
            "provider": "MicrosoftGraph",
            "version": "1.0.0"
        }
    },
    "resources": {
        "groupTest": {
            "import": "microsoftGraph",
            "type": "Microsoft.Graph/groups@v1.0",
            "properties": {
                "displayName": "groupTestbicep",
                "mailEnabled": false,
                "mailNickname": "groupTest",
                "securityEnabled": true,
                "description": "groupTest",
                "uniqueName": "groupTestbicep"
            }
        }
    }
}
```

So that's it after more than 10 years of existence, we can finally manipulate the ID entrance via our deployments, and therefore no need to have specific scripts to do this.
It is only only beginning today, but we can hope that Microsoft continues in this direction, because this is very practical from my point of view.
