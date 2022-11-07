---
layout: post
title: Azure Policy - Find unused policies
date: 2022-11-10
categories: [ "Azure", "Policy" ]
comments_id: 26 
---

Creating Azure policies is very easy, however it can be handy to know if all of your Azure policies are in use in your environment.

For this I created a very practical Resource Graph query

```kql
policyresources
| where type == "microsoft.authorization/policydefinitions"
| extend policyType = tostring(properties.policyType)
| where policyType == "Custom"
| join kind=leftouter (
    policyresources
    | where type == "microsoft.authorization/policysetdefinitions"
    | extend policyType = tostring(properties.policyType)
    | extend  policyDefinitions = properties.policyDefinitions
    | where policyType == "Custom"
    | mv-expand policyDefinitions
    | extend policyDefinitionId = tostring(policyDefinitions.policyDefinitionId)
    | project associedIdToInitiative=policyDefinitionId 
    | distinct associedIdToInitiative) on $left.id == $right.associedIdToInitiative
| where associedIdToInitiative == ""
| join kind=leftouter(
    policyresources
    | where type == "microsoft.authorization/policyassignments"
    | extend policyDefinitionId = tostring(properties.policyDefinitionId)
    | project associatedDefinitionId=policyDefinitionId 
    | distinct associatedDefinitionId
) on $left.id == $right.associatedDefinitionId
| where associatedDefinitionId == ""
| extend displayName = tostring(properties.displayName)
| project id, displayName
```

You can find the resource graph query on my [github](https://github.com/wilfriedwoivre/azure-resource-graph-queries/tree/master/queries/policies/list-unused-policies).

In this Resource Graph query, we start by listing all the Azure Policies that are defined in your environment, and we will filter only on those that are *Custom*.

And then we will see if they are not assigned in an Initiative, or directly on an Azure scope, and retrieve our list of unnecessary Policies.

It is up to you afterwards to delete them if they are really of no use to you.

This new feature in Azure Resource Graph is very practical, and the tool is really useful for all things governance, and it is constantly evolving at Microsoft, which I think is a good thing. I can't wait to be able to query Azure Role Assignments, and Azure AD objects (yes, that's my wishlist for new features).
