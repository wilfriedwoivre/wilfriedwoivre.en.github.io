---
layout: post
title: Azure API - Find all the versions available for each resource provider operations
date: 2024-12-12
categories: [ "Azure" ]
comments_id: 49 
---

Last year, I talked about the challenges of managing Azure Policies APIs.

Now, if you want to automate tests to verify all API versions, you need to know all of them.

To discover the different API versions, there are several methods. The first is to consult the Azure REST API documentation provided by Microsoft, but this can be tedious.

The second (and probably the most commonly used so far) is to trigger an error and check the list of available APIs in the error message, as shown below:

```powershell
$header = @{ 'Content-Type' = 'application/json'; 'Authorization' = 'Bearer ' + (Get-AzAccessToken).Token }
$url = "https://management.azure.com/subscriptions/$((Get-AzContext).Subscription.Id)/providers/Microsoft.Authorization/roleAssignments?api-version=dummyapi"
Invoke-WebRequest -headers $header $url

--- 
Invoke-WebRequest:
{
  "error": {
    "code": "InvalidResourceType",
}

```

However, you will agree, there are better ways to find all the available versions.

It is therefore possible to retrieve the different APIs using the following command:

```powershell
(Get-AzResourceProvider -ProviderNamespace "Microsoft.Authorization" | Where-Object { $_.ResourceTypes.ResourceTypeName -eq "roleAssignments" } | Select-Object ResourceTypes).ResourceTypes.ApiVersions

--- 
2022-04-01
2022-01-01-preview
2021-04-01-preview
2020-10-01-preview
2020-08-01-preview
2020-04-01-preview
2020-03-01-preview
2019-04-01-preview
2018-12-01-preview
2018-09-01-preview
2018-07-01
2018-01-01-preview
2017-10-01-preview
2017-09-01
2017-05-01
2016-07-01
2015-07-01
2015-06-01
2015-05-01-preview
2014-10-01-preview
2014-07-01-preview
2014-04-01-preview
```

And there you have it, all that's left is to integrate this into a proper test CI pipeline.
