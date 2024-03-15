---
layout: post
title: Azure Policy - DenyAction effect
date: 2023-04-15
categories: ["Azure", "Policy"]
githubcommentIdtoreplace: 
---

A new effect is available on the Azure Policy, this is the _deryaction_, as its name suggests it allows you to do a Deny when you try to do an action. But the subtlety is that if the action is made via parent resource, of the type deletion of a resourcegroup, you can authorize it.

What can it be for, you tell me?

Well me the interest that I see is above all the nested resources like the iprules of the PostgreSql bases, or Keyvault, but also diagnostics on your resources:

Here is an example of Policy for the diagnostic part:

```json
{
  "if": {
    "field": "type",
    "equals": "Microsoft.Insights/diagnosticSettings"
  },
  "then": {
    "effect": "denyAction",
    "details": {
      "actionNames": ["delete"]
    }
  }
}
```
