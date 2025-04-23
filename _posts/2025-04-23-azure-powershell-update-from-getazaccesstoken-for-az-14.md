---
layout: post
title: Azure PowerShell - Update from Get-AzAccessToken for Az 14
date: 2025-04-23
categories: [  ]
comments_id: 52 
---

In the next major version of the Az module for PowerShell, there is a significant breaking change that can potentially impact all your automation scripts.

It is about Get-AzAccessToken a very practical method to get a valid token to interact with Azure APIs.

As we can see below:

```powershell
get-azaccesstoken
WARNING: Upcoming breaking changes in the cmdlet 'Get-AzAccessToken' :
The Token property of the output type will be changed from String to SecureString. Add the [-AsSecureString] switch to avoid the impact of this upcoming breaking change.
- The change is expected to take effect in Az version : '14.0.0'
- The change is expected to take effect in Az.Accounts version : '5.0.0'
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.
```

To make the change, you have to pass -AsSecureString to have the same result you will have in version 14.

```powershell
$token = Get-AzAccessToken  -AsSecureString

$token.Token
System.Security.SecureString
```

The problem is that the token is now in a SecureString format, which is not usable as is for using it in REST calls.

You need to convert it to a plain text string.

```powershell
ConvertFrom-SecureString $token.Token -AsPlainText

eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkNOdjBPSTNSd3FsSEZFVm5hb01Bc2hDSDJYRSIsImtpZCI6IkNOdjBPSTNSd3FsSEZFVm5hb01Bc2hDS...
```

And now you can use it in your REST calls.

So make the change in your scripts before updating your module.
