---
layout: post
title: Azure Policy - Enforce location for CosmosDB
date: 2019-12-27
categories: [ "Azure", "Policy", "Cosmos DB" ]
---

Now, it's very easy on Azure to limit allowed locations for your services. Azure has a built in Azure Policy for this use case.

Reminder, the policy to limit allowed location of your ressources is :

```json
"if": {
    "allOf": [
        {
            "field": "location",
            "notIn": "[parameters('listOfAllowedLocations')]"
        },
        {
            "field": "location",
            "notEquals": "global"
        }
    ]
},
"then": {
    "effect": "deny"
}  
```

You must add location of your choice. Don't forget to add **global** location if you want use not regional services like DNS Zone.

Now, on CosmosDB, with this policy if you have selected only *North Europe* and *West Europe* as allowed locations, you can create your Cosmos DB only on this two locations.

However, Cosmos DB have a feature to create a replica on an another region like *France Central*. Even if you have the policy, you can create the replica..

If you want deny creation of your replicas, you must create a custom policy with this defintion :

```json
{
  "mode": "All",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.DocumentDB/databaseAccounts"
        },
        {
          "not": {
            "field": "Microsoft.DocumentDB/databaseAccounts/Locations[*].locationName",
            "in": "[parameters('allowedLocations')]"
          }
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  },
  "parameters": {
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "displayName": "Allowed locations",
        "description": "The list of allowed locations for resources."
      }
    }
  }
}
```

For your parameters, it's not possible to use the strong type, we must use a list and use this parameter : *westeurope;northeurope;West Europe;North Europe*
