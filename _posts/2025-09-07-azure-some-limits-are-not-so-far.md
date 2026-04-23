---
layout: post
title: Azure - Some limits are not so far
date: 2025-09-07
categories: [ "Azure" ]
githubcommentIdtoreplace: 
---

The Cloud is infinite — that is what we often hear. But is that really true? In reality, there are limitations in the Cloud, and Azure is no exception. These limitations can be related to capacity, performance, security, or other aspects.


This is certainly something well known, but I still see many people forget it, or assume they will never be affected by these limitations.

So let’s start with the official Azure documentation that lists the different limits: [https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits?WT.mc_id=AZ-MVP-4039694)

These limits may seem far away compared to your current usage, but you can reach them faster than you might expect.

For example, when you set up Azure Policy bundles for each type of resource and risk, there is a limit on the number of custom definitions per scope. This can become a challenge in your governance architecture: you may need to use initiatives, create multiple scopes, or rely more on built-in policies.

Custom role definitions also have a tenant-level limit. So you cannot let all your users create custom roles without control, otherwise you may hit that limit sooner than expected and lose governance over the existing roles.

For heavy Azure API Management users, be aware that there are limits on the number of operations per instance. This count also includes operations present in revisions. By default, the service does not provide a simple metric to check whether you are close to that limit, so you must calculate it yourself and properly manage unused revisions and obsolete APIs.

The same applies to Azure Firewall: there are limits on how many rules you can create. A rule is roughly counted as 1 source, 1 destination, and 1 port. So if you add the rule **Allow TCP 9093 from 10.0.0.0/24 and 10.0.1.0/24 to 10.1.0.0/24**, it counts as 2 rules. To reduce this, you can use IP groups or open access more broadly when possible. But managing these rules can quickly become a challenge, especially if multiple teams manage the firewall.

My advice is this: for every new service you enable on your platform, or every new feature you offer as *self-service* to your users, ask yourself what the limits are and whether they can be reached.
And remember: even if these limits can evolve over time, you still need to apply all your governance processes around these resources, such as inventory and rigorous lifecycle management.
