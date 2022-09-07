---
layout: post
title: Azure - Overview of cloud governance
date: 2022-09-07
categories: [ "Azure" ]
githubcommentIdtoreplace: 
---

Cloud governance is a vast subject that is very trendy today. In this post, we will try to reveal everything behind this term, and how to respond to it for a company. Here we will only talk about Azure, but it would be quite possible to draw a parallel with any other Cloud, whether public or private.

Let's start with Microsoft's definition that can be found on the
[documentation Azure](https://docs.microsoft.com/en-us/azure/governance/azure-management)

Governance in th e cloud is one aspect of Azure management. This article describes the different areas of management to deploy and maintain your resources in Azure.

Management refers to the tasks and processes necessary to maintain your business applications and the resources that support them. Azure has many services and tools that work together to provide comprehensive management. These services are not only for resources in Azure, but also in other clouds and on-premises. The first step to designing a complete management environment is to fully understand the different tools and how they work together.

All this is well summarized by a diagram:

![image]({{ site.url }}/images/2022/09/07/azure-overview-of-cloud-governance-img0.png "image")

But what does that really mean? We will try to define it in the most exhaustive way possible. And feel free to add comments to this article if you have any other ideas.

Let's start at the beginning, and by asking questions about "Under what conditions does my company want to use Azure? And under what security context?" :

- What budget do I want to invest in this governance?
- How many applications / users in Azure in 5 years?
- What risks do I want to cover when using Azure? Zero-trust approach? More flexible personalized approach? Open bar ?
- How will we provide Cloud assets to my users? Team autonomy? Centralization? Mixed approach?
- How to add new applications / new users?
- How will I train my teams? my users?
- How will I monitor Azure, my applications, my costs?
- How will I connect Azure with my company?
- Will I do a lift & shift migration, or transform my applications so that they are Cloud Native?

If you can answer these different questions, you will be able to approach your strategy for using Azure in a more zen way.

But beware, there are no wrong answers to these questions, because it all depends on your business and the choices you make.

I propose to detail possible answers to some of these questions in future articles, and we will also see how to implement this on Azure, particularly on security and governance topics.

But first of all, let's break open doors. Having a cloud migration plan and a migration strategy for existing applications because it makes it easier to make the right choices, and to have success indicators.

Indeed, if we take the example of a large company which chooses to migrate a large number of applications to the public Cloud versus another company which only wishes to migrate a limited number of applications, but which the choice to use the Cloud as a backup for its data. We find ourselves here on two totally different scenarios and which are rather viable for companies today.

One of the great advantages of the Cloud is to have access to a large number of resources very quickly, and to be able to delete them at the end of use, so it is possible to make security choices solely related to the data, and to leave the Compute part with less perimeter security.

For online sales sites, if we migrate all the visible part, namely the e-commerce site, directly to the Public Cloud, we will first take into account the availability and proper functioning of the site. But we can also choose to migrate only another part of the information system in the Cloud which is less sensitive to this operational risk, but which can be harmful in the event of a data leak.

In short, through these few examples we can see that each company is different, and therefore that there is no strategy all drawn according to the type of company that wishes to go to Azure. But we will see that it is possible to find common biases and afterwards everyone is free to make their choice, or even not to use the public Cloud, but there you would be depriving yourself of an extraordinary adventure.
