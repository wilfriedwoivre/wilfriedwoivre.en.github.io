---
layout: post
title: Azure - Easily get an Access Token for your REST API calls 
date: 2022-03-14
categories: [ "Azure", "Powershell" ]
comments_id: 20 
---

Using REST APIs on Azure is of course an essential skill for all Cloud users whether they are developers or administrators.

In a script it is often convenient to switch to a REST API instead of a Powershell cmdlet, for different reasons like the following:

- Use of a property not available on our version of Powershell module
- Updating a property of an object not easy to do in powershell

And of course to be able to call Azure REST APIs you need an access token, and for that there are several ways to get one.

If you have an old version of the powershell modules, you can always use this script :

```powershell
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
}
```

Or more simply if you forgot this piece of code, I advise you to go on the site of the documentation [Azure](https://docs.microsoft.com/en-us/rest/api/resources/resource-groups/list) and to test an API, you will have the possibility of recovering an access token.

And if you have a fairly recent module, you can use the following method:

```powershell
$token = Get-AzAccessToken
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.Token
}
```

And voilà you can call Azure REST APIs with your token as follows:

```powershell
$restUrl = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups?api-version=2022-01-01"
Invoke-WebRequest -Uri $restUrl -Method GET -Headers $authHeader
```

We agree that it is much easier to remember.
