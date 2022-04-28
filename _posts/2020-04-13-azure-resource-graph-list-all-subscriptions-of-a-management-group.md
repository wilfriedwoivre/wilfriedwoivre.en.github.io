---
layout: post
title: Azure Resource Graph - List all subscriptions of a Management Group
date: 2020-04-13
categories: [ "Azure", "Resource Graph" ]
comments_id: 10 
---

Like me, you became a big fan of Resource Graph to explore the resources of your Azure subscriptions.

Now nothing is perfect, and even less on Azure, it still lacks features including this one: [Resource Graph type for Management Groups](https://feedback.azure.com/forums/915958-azure-governance/suggestions/39760720-resource-graph-type-for-management-groups)

This type would be practical for example to list all the subscriptions present in a Management Group.

But good news before this planned functionality is available, there is always a way to get there.

For that we will list all our subscriptions via the following request:

```graph
resourcecontainers
 | where type == "microsoft.resources/subscriptions"
```

If your subscription is in a Management Group, you will find a specific tag as follows:

```json
{
    "hidden-link-ArgMgTag": "[\"Admin\",\"GUID\"]"
}
```

or

```json
{
    "hidden-link-ArgMgTag": "[\"Sandbox\",\"SOAT\",\"GUID\"]"
}
```

This property corresponds to the tree structure of your Management Groups, which can be read from left to right.

The first field on the left is a Guid which is that of your tenant, and the following correspond to the IDs of your Management Groups by following the hierarchy.

Well of course if you have less than ten subscriptions, you can filter your request globally, but when you have a hundred, you will be very happy to know this tip.

You just have to filter your subscriptions via a request of this type:

```graph
resourcecontainers
 | where type == "microsoft.resources/subscriptions"
 | where tags contains "Sandbox"
 ```
