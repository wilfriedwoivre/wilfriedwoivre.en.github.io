---
layout: post
title: Azure Storage - Control usage of your SAS Keys
date: 2022-04-21
categories: [ "Azure", "Storage", "Policy" ]
comments_id: 24 
---

The use of SAS Keys in Azure Storage is a very practical system when you want to provide limited access to a Storage Account, whether in terms of rights, scope, or validity period.

However, leaving this to the teams can be a source of data leakage, as it is quickly possible to create a SAS Key with a very long duration in order to *save* time when using it, as it is always the same.

As an ops or security manager, it is therefore necessary to search the Storage logs for the different SAS Keys used in order to find errors of this type.

Well, once again, Microsoft is going to simplify our lives with this new feature. We can now add an alert when the SAS Key has a too long lifetime. Be careful though, it is an alert, not a blocking if you generate or use a non compliant SAS Key.

In ARM, you add this property to your storage, or put it in the configuration of your storage in the Azure portal

```json
"sasPolicy": {
                "sasExpirationPeriod": "1.00:00:00",
                "expirationAction": "Log"
            },
```

However note that there is a **expirationAction** field in Log which is the only possible value, but I hope to see a Deny in the future.

Once again, it is possible to have an Azure Policy to tell you which storage does not have a SAS Key Policy configured, and it is built-in you can find it under the name **Storage accounts should have shared access signature (SAS) policies configured** or here is its definition:

```json
{
  "properties": {
    "displayName": "Storage accounts should have shared access signature (SAS) policies configured",
    "policyType": "BuiltIn",
    "mode": "Indexed",
    "description": "Ensure storage accounts have shared access signature (SAS) expiration policy enabled. Users use a SAS to delegate access to resources in Azure Storage account. And SAS expiration policy recommend upper expiration limit when a user creates a SAS token.",
    "metadata": {
      "version": "1.0.0",
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
            "field": "Microsoft.Storage/storageAccounts/sasPolicy",
            "exists": "false"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  },
  "id": "/providers/Microsoft.Authorization/policyDefinitions/bc1b984e-ddae-40cc-801a-050a030e4fbe",
  "type": "Microsoft.Authorization/policyDefinitions",
  "name": "bc1b984e-ddae-40cc-801a-050a030e4fbe"
}
```

In order to know if your storages are using invalid SAS Keys, you have to go in the Logs of your storage, which you have of course configured, and perform the following Kusto search:

```sql
StorageBlobLogs 
| where SasExpiryStatus startswith "Policy violated"
| summarize count() by AccountName, SasExpiryStatus
```

And voilà how to quickly gain more control over your storages.
