---
layout: post
title: Azure Automation - Add a module from powershell gallery on runtime environment
date: 2024-06-27
categories: [ "Azure", "Automation" ]
githubcommentIdtoreplace: 
---

Recently Microsoft added Environment Runtime functionality in Azure Automation.
This allows, among other things, to remove one of the strong constraints that we have on Automation today, the complexity of updating modules.

Today you should know that an automation account shares its modules with all the runbooks so if you want to go from module Az 8 to Az 12, this will impact all your runbooks, if you have a lot of them a non-regression test can be very long to do.

Well now you can use Runtime Environment to help you.

To deploy a new runtime, nothing could be simpler via bicep

```bicep
resource powershell_7_2_Az_11_2_0 'Microsoft.Automation/automationAccounts/runtimeEnvironments@2023-05-15-preview' = {
  parent: automation
  name: 'Powershell-7.2-Az-11.2.0'
  properties: {
    runtime: {
      language: 'PowerShell'
      version: '7.2'
    }
    defaultPackages: {
      Az: '11.2.0'
    }
    description: 'Powershell 7.2 with Az 11.2.0'
  }
}

resource powershell_7_2_Az_12_0_0 'Microsoft.Automation/automationAccounts/runtimeEnvironments@2023-05-15-preview' = {
  parent: automation
  name: 'Powershell-7.2-Az-12.0.0'
  properties: {
    runtime: {
      language: 'PowerShell'
      version: '7.2'
    }
    description: 'Powershell 7.2 with Az 12.0.0'
  }
}
```

And to deploy your custom modules or those from the powershell gallery

```bicep
resource Az_12_0_0 'Microsoft.Automation/automationAccounts/runtimeEnvironments/packages@2023-05-15-preview' = {
  name: 'Az'
  parent: powershell_7_2_Az_12_0_0
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az/12.0.0'
    }
  }
}

```

Don't forget here that Azure Automation does not load the dependencies by itself, so you must add all the modules you need (Az.Resource, Az.Storage, etc.)

And then you can choose in the runbook definition on which environment with the **runtimeEnvironment** property, be careful to use the same API version as me

```bicep
resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-05-15-preview' = {
  name: 'demobicep'
  parent: automation
  location: location
  properties: {
    runbookType: 'PowerShell'
    runtimeEnvironment: powershell_7_2_Az_11_2_0.name
    description: 'Demo runbook'
  }
}
```

And here are no more excuses for the non-migration of automation accounts which have been there for 10 years with old powershell modules
