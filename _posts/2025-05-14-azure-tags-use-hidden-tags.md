---
layout: post
title: Azure Tags - Use hidden tags
date: 2025-05-14
categories: [ "Azure" ]
comments_id: 53 
---

Azure tags are very useful from a governance point of view. They allow you to organize your resources, whether cross Resource Groups or cross subscriptions. Or even to filter simply within a *global trash* resource group.

Now on Azure, as you know, the name of a resource is used to identify it within Azure and therefore cannot be modified.
You therefore have three main choices to name your resources :

- a Well-defined and respected naming agreement respected by all.
- Naming based on your use cases.
- The _Cat Naming Convention_ which consists in named any way your resources by typing anything on your keyboard. My favorite method for demonstrations.  

Now in the life of a business, it is often occur to change the names of the teams, projects, applications, etc. And we therefore end up with resources with obsolete names.

It is possible to add a tag called _hidden-title_ which allows you to add an additional name to your resource as below:

![alt text]({{ site.url }}/images/2025/05/14/azure-tags-use-hidden-tags-img0.png)

And as you can see, the tag is not visible from the portal. but it is visible when you retrieve the information about your resource in powershell for example.

```powershell
Get-AzResource -ResourceGroupName $rgName

Name              : jhyblmpw
ResourceGroupName : tags-rg
ResourceType      : Microsoft.Storage/storageAccounts
Location          : westeurope
ResourceId        : /subscriptions/c4dc16cad0f/resourceGroups/tags-rg/providers/Microsoft.Storage/storageAccounts/jhyblmpw
Tags              :
                    Name          Value
                    ============  ========================
                    hidden-title  Awesome storage for demo

```

It is of course possible to remove the tags via the portal by creating a new tag with the same name and an empty value.

You can use other hidden tags while of course respecting the limit of 50 tags per resource.
