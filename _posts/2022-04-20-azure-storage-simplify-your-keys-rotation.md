---
layout: post
title: Azure Storage - Simplify your keys rotation
date: 2022-04-20
categories: [ "Azure", "Storage", "Policy" ]
comments_id: 23 
---

From a security point of view, it is often necessary to rotate your access keys, whether it is a user password or an SPN key. But don't forget your technical assets where you can identify yourself with a key such as Azure Storage.

Unless you have managed this brilliantly in your application and infrastructure, rotating the keys of your storage can be tedious, and above all you risk forgetting to do it if you don't do it regularly.

To help you do it more often, Microsoft has released a new feature that will allow you to remember more easily, it is now possible to add an alerting when your keys have not been running for a long time.

To do this, simply add the following property to your storage in ARM:

```json
"keyPolicy": {
                "keyExpirationPeriodInDays": 60
            },
```

It is of course possible from the Azure portal, in the key management blade.

Now it's good to have a policy in place, but how we are alerted, well simply thanks to an Azure Policy built-in that you can find under the name **Storage account keys should not be expired**.

And for the curious here is its definition:

```json
{
  "properties": {
    "displayName": "Storage account keys should not be expired",
    "policyType": "BuiltIn",
    "mode": "Indexed",
    "description": "Ensure the user storage account keys are not expired when key expiration policy is set, for improving security of account keys by taking action when the keys are expired.",
    "metadata": {
      "version": "3.0.0",
      "category": "Storage"
    },
    "parameters": {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Audit allows a non-compliant resource to be created, but flags it as non-compliant. Deny blocks the resource creation and update. Disable turns off the policy."
        },
        "allowedValues": [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue": "Audit"
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
          },
          {
            "anyOf": [
              {
                "value": "[utcNow()]",
                "greater": "[if(and(not(empty(coalesce(field('Microsoft.Storage/storageAccounts/keyCreationTime.key1'), ''))), not(empty(string(coalesce(field('Microsoft.Storage/storageAccounts/keyPolicy.keyExpirationPeriodInDays'), ''))))), addDays(field('Microsoft.Storage/storageAccounts/keyCreationTime.key1'), field('Microsoft.Storage/storageAccounts/keyPolicy.keyExpirationPeriodInDays')), utcNow())]"
              },
              {
                "value": "[utcNow()]",
                "greater": "[if(and(not(empty(coalesce(field('Microsoft.Storage/storageAccounts/keyCreationTime.key2'), ''))), not(empty(string(coalesce(field('Microsoft.Storage/storageAccounts/keyPolicy.keyExpirationPeriodInDays'), ''))))), addDays(field('Microsoft.Storage/storageAccounts/keyCreationTime.key2'), field('Microsoft.Storage/storageAccounts/keyPolicy.keyExpirationPeriodInDays')), utcNow())]"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  },
  "id": "/providers/Microsoft.Authorization/policyDefinitions/044985bb-afe1-42cd-8a36-9d5d42424537",
  "type": "Microsoft.Authorization/policyDefinitions",
  "name": "044985bb-afe1-42cd-8a36-9d5d42424537"
}
```

Note that it is not possible to memorize the definition of this policy in the evening...

And don't forget to rotate your keys, you never know you might have to do it because of a security incident, it's better to have tested it before.
