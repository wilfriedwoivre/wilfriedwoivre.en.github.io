---
layout: post
title: Azure Advisor - Manage recommendations at scale
date: 2026-02-11
categories: [ "Azure", "Azure Advisor" ]
githubcommentIdtoreplace: 
---

Azure Advisor is an Azure service that provides many recommendations for your environments, whether in terms of security, cost, or resilience. This tool is great, but it can be quite time-consuming to manage and account for all recommendations across an enterprise.

If you have an Azure environment that is fairly standardized and spans multiple subscriptions, you may want to dismiss some recommendations or at least postpone them.

You can do this quickly with a PowerShell script (or another automation approach).
To start, you can list the different recommendations with the following command:

```powershell
Get-AzAdvisorRecommendation -SubscriptionId <SubscriptionId>
```

Then, you can filter the recommendations you want to dismiss or postpone. For example, if you want to postpone a recommendation for 90 days, you can use the following command:

```powershell
Disable-AzAdvisorRecommendation -RecommendationName e33855d4-7579-e4d0-c459-23fad3665bd6 -Day 90
```

And if you simply want to postpone one recommendation type globally, you can use the following command:

```powershell
get-azAdvisorRecommendation | Where { $_.RecommendationTypeId -eq $recommendationId } | % { $_ | Disable-AzAdvisorRecommendation -Day 120 }
```

Let’s make 2026 the year we manage recommendations at scale—and leave no active recommendation without a planned action!
