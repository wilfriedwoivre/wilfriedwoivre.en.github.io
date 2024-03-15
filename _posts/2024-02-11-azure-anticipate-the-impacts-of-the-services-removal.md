---
layout: post
title: Azure - Anticipate the impacts of the services removal 
date: 2024-02-11
categories: [ "Azure" ]
githubcommentIdtoreplace: 
---

Azure services evolve over time. And one of the first Azure services is just a stay, these are Cloud Services.

Even if today, you can no longer create it, Microsoft has relied on it for a good number of PaaS services, and the time of switching on new versions. And for most of these components, this requires an operation on your part. Where then you can wait until Microsoft forces you to migrate, but you will not have the hand in case of failure.

Among the services I have in mind, we have:

- API Management stdv1
- Standard gateway application
- Virtual Network Gateway Standard SKU

All these products have migration paths that you can follow. But of course, you cannot spend your time on Azure updates to build your application roadmap.

To help you, Microsoft provides a workbook [Service Retirements](https://portal.azure.com/#view/Microsoft_Azure_Expert/AdvisorMenuBlade/~/workbooks) In the Advisor blade, In this one you have the list of all services that will be removed in the future, and he can even give you the instances that you use, so it is not an infinite list that you need to decrypt.

![](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/480301iEEB40BE3470595B6/image-dimensions/632x283?v=v2&WT.mc_id=AZ-MVP-4039694)

And if you are allergic to the portal, it is always possible to do this with a resource graph query

```kql
advisorresources
| project id, properties.impact, properties.shortDescription.problem
```
