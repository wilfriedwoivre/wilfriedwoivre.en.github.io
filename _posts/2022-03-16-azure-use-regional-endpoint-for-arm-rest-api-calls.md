---
layout: post
title: Azure - Use regional endpoint for ARM REST API calls
date: 2022-03-16
categories: [ "Azure", "Powershell" ]
comments_id: 21 
---


Recently I opened different support cases to Microsoft for an unusual behavior on Azure.

When I created a new resource in West Europe, it was available on the Azure portal, but from my Automation Account in North Europe I could not see it.

In other words, when I did a **Get-AzStorageAccount -ResourceGroup $resourceGroupName** from my workstation I could see my new storage, but from my Automation account I could not.

In order to diagnose the problem there is a very simple way, you just have to do in powershell the following commands:

```powershell
$token = Get-AzAccessToken
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.Token
}

$locations = @("westeurope", "northeurope")


foreach ($location in $locations) {
    Write-Host "Location : $location" -ForegroundColor  Cyan
    $restUrl = "https://$location.management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/resources?api-version=2022-01-01"; 
    (Invoke-WebRequest -Uri $restUrl -Method GET -Headers $authHeader).Headers
}
```

And you will see through which region your calls go through via the **x-ms-routing-request-id** header which contains the **WESTEUROPE** value corresponding to the region

Very useful when there is a synchronization problem on Azure side, and the support can force a sync if you don't want to wait for it to happen
