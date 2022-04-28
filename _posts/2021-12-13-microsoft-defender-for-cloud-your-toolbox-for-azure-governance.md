---
layout: post
title: Microsoft Defender for cloud - Your toolbox for Azure governance
date: 2021-12-13
categories: [ "Azure", "Monitoring", "Microsoft Defender for Cloud" ]
comments_id: 17 
---

Azure offers both services to host your applications, but also tools to help you manage them better, such as the Security Center.

This is a toolbox that is constantly evolving at Microsoft, and good news some of these tools are free, and of course another not.

Among the essential tools that we find there are :

- The degree of security (or the Secure Score)
- Your regulatory compliance
- Azure Defender
- Firewall Manager
- Insights
- Workbooks
- Workflow automation

The Security Center is a real gold mine if you want to invest in SecOps on Azure.

However, beware that the various recommendations in the Security Center are not always applicable to your use of Azure.

Let's take for example the following rule "**Storage account public access should be disallowed**": This one is not applicable in case your storage account is used to expose images via a CDN for example.

So before applying each action, it is necessary to understand if it corresponds to a legitimate architecture.

Now as it is necessary to understand how this works, these different recommendations come from a Policy Initiative called Azure Security Benchmark (previously Enable Monitoring in Azure Security Center). This is the initiative with the following definition: */providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8*

Sometimes it is necessary to see the settings related to this initiative in order to customize them according to the context of the subscription.

For example in the Security Center, we have this rule: **Network Watcher should be enabled**.
If we click on it, we can see the definition of the associated policy

```json
{
  "properties": {
    "displayName": "Network Watcher should be enabled",
    "policyType": "BuiltIn",
    "mode": "All",
    "description": "Network Watcher is a regional service that enables you to monitor and diagnose conditions at a network scenario level in, to, and from Azure. Scenario level monitoring enables you to diagnose problems at an end to end network level view. Network diagnostic and visualization tools available with Network Watcher help you understand, diagnose, and gain insights to your network in Azure.",
    "metadata": {
      "version": "2.0.0",
      "category": "Network"
    },
    "parameters": {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ],
        "defaultValue": "AuditIfNotExists"
      },
      "listOfLocations": {
        "type": "Array",
        "metadata": {
          "displayName": "Locations",
          "description": "Audit if Network Watcher is not enabled for region(s).",
          "strongType": "location"
        }
      },
      "resourceGroupName": {
        "type": "String",
        "metadata": {
          "displayName": "NetworkWatcher resource group name",
          "description": "Name of the resource group of NetworkWatcher, such as NetworkWatcherRG. This is the resource group where the Network Watchers are located."
        },
        "defaultValue": "NetworkWatcherRG"
      }
    },
    "policyRule": {
      "if": {
        "field": "type",
        "equals": "Microsoft.Resources/subscriptions"
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Network/networkWatchers",
          "resourceGroupName": "[parameters('resourceGroupName')]",
          "existenceCondition": {
            "field": "location",
            "in": "[parameters('listOfLocations')]"
          }
        }
      }
    }
  },
  "id": "/providers/Microsoft.Authorization/policyDefinitions/b6e2945c-0b7b-40f5-9233-7a5323b5cdc6",
  "type": "Microsoft.Authorization/policyDefinitions",
  "name": "b6e2945c-0b7b-40f5-9233-7a5323b5cdc6"
}
```

We can see that there are several parameters taken into account here, such as the name of the resource group, and the list of regions that we want to monitor.

![]({{ site.url }}/images/2021/12/13/microsoft-defender-for-cloud-your-toolbox-for-azure-governance-img0.png)

On my subscription, I deploy the network watcher for each region in a dedicated resource group that I know, because I do not like resource groups created by Microsoft without prior request. So we have to think here about modifying our resource group for networking by default it is NetworkWatcherRG. (capital letters, I like it ....)

In short, we can see here some examples of the usefulness of the Security Center, provided that it is used properly, and not just looked at from time to time.
Later, I will try to make other articles around these topics related to Security Center in order to dig more in detail the different features that it brings.
