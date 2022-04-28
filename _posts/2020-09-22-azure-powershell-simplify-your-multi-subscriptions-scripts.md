---
layout: post
title: Azure Powershell - Simplify your multi subscriptions scripts
date: 2020-09-22
categories: [ "Azure", "Powershell" ]
comments_id: 14
---

When you have multiple Azure subscriptions that communicate with each other, it is often necessary to make scripts using multiple subscriptions. The simplest and most documented way is as follows:

```powershell
Connect-AzAccount #With an account with access to all subscriptions

$hubSubscriptionId = "...."
$spokeSubscriptionId = "...."

Select-AzSubscription -SubscriptionId $hubSubscriptionId

Get-AzResource ....

Select-AzSubscription -SubscriptionId $spokeResourceId

Get-AzResource
```

So yes, it is convenient to easily change context via a single line of powershells, but when it comes to retrieving a single piece of information on the second subscription, it may be necessary to change context every 2 lines. And I'm not even talking about if you want to perform several actions in parallel.

The prerequisite for this to work is to have Azure authentication on multiple accounts, which you have by default with this command :

```powershell
# With user login
Connect-AzAccount

# With SPN Login
$Credential = Get-Credential
Connect-AzAccount -Credential $Credential -Tenant 'xxxx-xxxx-xxxx-xxxx' -ServicePrincipal
```

For example if I want to retrieve information from the virtual network peerings to my vnet of an A subscription, I can do a script like this :

```powershell
$vnetHub = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnetName

foreach ($peering in $vnetHub.VirtualNetworkPeerings) {
  $remoteVnet = Get-AzResource -Id $peering.RemoteVirtualNetwork.Id -ExpandProperties

  Write-Host $remoteVnet.Properties.addressSpace.addressPrefixes
}
```

And of course it works even if my RemoteVirtualNetwork is in another subscription or in the current one.

This is a little trick, which I think is good to know especially for Powershell fans.
