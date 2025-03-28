---
layout: post
title: Azure Policy - Manage conflicts in your modify policies
date: 2024-10-17
categories: [ "Azure", "Policy" ]
comments_id: 48 
---

Policies with modify effect are very useful to enforce a rule, and prevent automatic modification from a legacy infrastructure as code to update TLS version from 1.2 to 1.0 for example.

However, if you have several policies that change the same field. What can happen if you assign the same policy twice on different scopes with different parameters, or if you have a governance problem, it can be complicated to know which prime on the other

There is __conflicteffect__ that exists, and this one offer a control to prioritize which policy take over on the other. This field has multiple values: __audit__, __deny__ ou __disabled__.

And good news, by default the value is __deny__ and it's the value i advise for your policy.

Indeed, if we have a policy conflict, we will have an error when updating the resource, while a policy with an audit effect will simply not play the modification operations in the event of a conflict.

Here is an example of a policy with a configured conflict effect.

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Storage/storageAccounts"
        },
        {
          "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
          "equals": "false"
        }
      ]
    },
    "then": {
      "effect": "[parameters('effect')]",
      "details": {
        "conflictEffect": "deny",
        "roleDefinitionIds": [
          "/providers/Microsoft.Authorization/roleDefinitions/17d1049b-9a84-46fb-8f53-869881c3d3ab"
        ],
        "operations": [
          {
            "condition": "[greaterOrEquals(requestContext().apiVersion, '2019-04-01')]",
            "operation": "addOrReplace",
            "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
            "value": true
          }
        ]
      }
    }
  },
  "parameters": {
    "effect": {
      "type": "String",
      "metadata": {
        "displayName": "Effect",
        "description": "The effect determines what happens when the policy rule is evaluated to match"
      },
      "allowedValues": [
        "Modify",
        "Disabled"
      ],
      "defaultValue": "Modify"
    }
  }
}
```
