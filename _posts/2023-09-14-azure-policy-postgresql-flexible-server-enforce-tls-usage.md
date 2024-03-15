---
layout: post
title: Azure Policy - PostgreSQL Flexible Server - Enforce TLS usage
date: 2023-09-14
categories: ["Azure", "Policy"]
comments_id: 39 
---

A small quick article to show you how to swell the TLS for the Azure Database for PostgreSQL Flexible Server. If you are looking in the Azure control plan options you are not going to find an option as on the postgresql single server bases.

 However by searching well you will find the option in the Data Plane settings of the base itself.

Good news by default, the option _require_secure_transport_ is _on_ and the property _minimum_tls_vVersion_ is at _tlsv1.2_.
Now the first action is deactivated via the Azure portal, when the second the only options are TLS 1.2 or TLS 1.3, but you can use the same procedure to block.

So we're going to add two police here, the first to look at if the property exists

```json
{
  "if": {
    "field": "type",
    "equals": "Microsoft.DBforPostgreSQL/flexibleServers"
  },
  "then": {
    "effect": "auditIfNotExists",
    "details": {
      "type": "Microsoft.DBforPostgreSQL/flexibleServers/configurations",
      "name": "require_secure_transport",
      "existenceCondition": {
        "field": "Microsoft.DBForPostgreSql/flexibleServers/configurations/value",
        "equals": "ON"
      }
    }
  }
}
```

And now we can also make a _deny_ in case of change:

```json
{
  "if": {
    "allOf": [
      {
        "field": "name",
        "equals": "require_secure_transport"
      },
      {
        "field": "type",
        "equals": "Microsoft.DBforPostgreSQL/flexibleServers/configurations"
      },
      {
        "field": "Microsoft.DBForPostgreSql/flexibleServers/configurations/value",
        "equals": "OFF"
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
```

You can of course apply something similar if you only want to enforce TLS 1.3 as minimum version