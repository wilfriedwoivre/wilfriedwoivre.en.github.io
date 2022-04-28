---
layout: post
title: Azure - Resource Graph Explorer, your next favorite tool
date: 2020-02-24
categories: [ "Azure" , "Resource Graph" ]
comments_id: 8
---

When you have multiple subscriptions, it can be complex to list all your resources, or create some reports like

- How many Storage Account i have and group by SKU ?
- How many VM are in my AKS Node Pools ?

So now, try to respond to the first question :

The old ways, make a script in Powershell, and use Az module to list all of your storage accounts, like this : 

```powershell
$subscriptions = Get-AzSubscription -TenantId $tenantId

$storages = @()
foreach ($subscription in $subscriptions)
{
    Select-AzSubscription -Subscription $subscription
    $storages += Get-AzStorageAccount
}

$storages | Select-Object -Property StorageAccountName, @{label="Sku"; expression={$_.Sku.Name}} | Group-Object Sku | Select Name, Count | Format-Table

```

You have a result like this :

```powershell
Name         Count
----         -----
Standard_GRS     1
Standard_LRS    15
```

On my tests subscriptions, only 5 subscriptions on this tenant, this script take around 10 seconds.

So the new ways, i can use Azure Resource Graph Explorer to help me on this request, i can use Powershell or Az cli to run my query, but i go use Azure Portal to help me write my query. 

![]({{ site.url }}/images/2020/02/24/azure-resource-graph-explorer-your-next-favorite-tool-img0.png)

This interface seems familiar if you use Log Analytics or Application Insights queries, and good news, it's the same language for queries.

So i can list all my Storage Account by type with this simple query

```sql
resources
| where type == "microsoft.storage/storageaccounts"
| extend sku = sku.name
| summarize count(name) by tostring(sku)
```

And we have the same results, but with a process time less than 1 second...

Resource Graph Explorer is clearly good to explore your subscriptions assets with a language query already know and that we use every days.
