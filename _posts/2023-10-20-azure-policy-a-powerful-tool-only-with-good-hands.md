---
layout: post
title: Azure Policy - A powerful tool only with good hands
date: 2023-10-20
categories: [ "Azure", "Policy" ]
comments_id: 33 
---

Azure Policy is a very powerful tool, especially when it comes to governance.

After an exchange with one of my colleagues on the management of the police, I think it is necessary to explain certain things on the different types of action, and especially on their order of execution.

Take for example the following case: _As a security manager, I wish **deny** the use of TLS other than 1.2 on my eventhubs_

The first approach is therefore to take up the demand and apply it on an Azure Policy that will look like that:

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

After deployment, a first test has been done from the Azure portal, and good news, the policy works well.
Now it must be remembered that all management with the Azure Providers is only API, what happens if we do not put _minimalTlsVersion_ in our payload, or in our bicep

```bicep
resource eventhub 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: 'wwo${deployment().name}${uniqueString(resourceGroup().id)}'
#disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    capacity: 1
  }
}
```

And very bad news for once, our Hub event is well created, and in terms of security it is therefore not compliant. 

To force this, there are 3 solutions based on the policy.

- Update our policy to force the presence of the minimalTLSVersion
- Add a policy to add the field with the right value
- Replace all of this with a modifying policy type

## Update our policy to force the presence of the minimalTLSVersion

Our first approach is to modify the policy in this way:

```json
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.EventHub/namespaces"
      },
      {
        "anyOf": [
          {
            "field": "Microsoft.EventHub/namespaces/minimumTlsVersion",
            "exists": false
          },
          {
            "field": "Microsoft.EventHub/namespaces/minimumTlsVersion",
            "notEquals": "1.2"
          }
        ]
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
```

As a result, we force the presence of the minimalTLSVersion field even on the API, and therefore our template must mention the property _minimalTLSversion_ with the right value to be valid.

In the pros, this is more aware of the devops on the implementation of the TLS.
In the counters, this can break existing CI/CD channels. This breaks the developer experience for a field that he did not judge important to put in a context secured by Azure Policy.

## Add a policy to add the field with the right value

If we stay on our first version of our Policy, it is possible to add a policy **Append** which will run before our Deny

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

In the pros, we solve all the counters of the previous implementation.
In the counters, do we really need 2 policies for a simple TLS problem? This argument is of course one pros if you are paid for each implemented policy.

## Replace all of this with a modifying policy type

We will therefore delete our _deny_ policy to replace it with this one:

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

In the pros, the property is modified transparently for the user, and we have only one policy to modify during a move to TLS 1.3 for example. In addition, it has an additional advantage that we will detail in a future post.
In the counters, an identity is created for you and assign to Azure, it is therefore necessary to manage the rights it has (here it is **Contributor** by ease)

For me there is no better proposition, it's up to you to choose according to your use cases.
In this specific case, if the TLS is not a subject, you can use the last proposal to simplify your infra as code. And thus free yourself from all the modifications of your different stacks of infra as code.
And if this is a subject in your home because you still have applications using TLS 1.0 or 1.1 The best is to put the first version with exemptions in the assignment of your policy.
