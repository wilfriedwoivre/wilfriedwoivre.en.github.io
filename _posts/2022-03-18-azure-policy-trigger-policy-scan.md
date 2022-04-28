---
layout: post
title: Azure Policy - Trigger policy scan
date: 2022-03-18
categories: [ "Azure", "Policy" ]
comments_id: 22 
---

When you create your own Azure Policies, it can be tedious to test them, as the evaluation is triggered by Azure.

It has been possible for some time to force its execution on the scope of a resource group or a subscription. Even if in our case, it is more about forcing on a test resource group than on a subscription in order not to impact your other policies.

To trigger an evaluation, you can use a PowerShell command like this:

```powershell
# Subscription scope
Start-AzPolicyComplianceScan -AsJob

#Resource Group Scope
Start-AzPolicyComplianceScan -ResourceGroupName $rgName -AsJob
```

You can run without a Powershell Job, but the operation is very long, it's why i recommend usage of Powershell Job in a development scenario

It is possible to do this also with a REST API

To do this, you need to use the following urls:

Subscription: **<https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2019-10-01>**

Resource Group: **<https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{YourRG}/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2019-10-01>**

```powershell
$token = Get-AzAccessToken
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.Token
}

$subscriptionId = ""
$resourceGroup = ""

$restUrl = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview"

 Invoke-WebRequest -Uri $restUrl -Method POST -Headers $authHeader
```

And you will find this trace in your Activity Log:

![]({{ site.url }}/images/2022/03/18/azure-policy-trigger-policy-scan-img0.png)

So no more excuses to take a coffee while waiting for the policy to be triggered.
