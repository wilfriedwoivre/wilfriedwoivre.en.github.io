---
layout: post
title: Azure - Deployment Stack - Future of Blueprint ?
date: 2023-07-30
categories: [ "Azure" ]
githubcommentIdtoreplace: 
---

Microsoft announced [Deployement Stacks public preview](https://techcommunity.microsoft.com/t5/azure-governance-and-management/arm-deployment-stacks-now-public-preview/ba-p/3871180) the last week.
For those who follow very attentively what is happening in the Azure ecosystem, we hear about this technology for at least 2020

![image]({{ site.url }}/2023/07/30/azure-deployment-stack-future-of-blueprint-img0.png)

In short, a preview that was a little expected.

In the article, and on Azure documentation, we are told that we have to migrate from BluePrint to Deployment Stack + Template Specs before July 2026, therefore no rush...

If we compare the two very quickly.

Blueprints are a declarative way to orchestrate the deployment of various models of resources and other artifacts, especially these:

- Role Assignment
- Policy Assignment
- Arm Template
- Resource Groups

The life cycle of a BluePrint:

- Creation and modification of a BluePrint
- Blueprint publication in V1.0
- Blueprint assignment in V1.0
- Creation and modification of a new version of BluePrint
- Publication of a new version of BluePrint in V2.0
- Update of the assignment of the BluePrint in V2.0
- Deletion of a specific version of BluePrint
- Deletion of BluePrint

BluePrint is included with a lock management, in the form of 3 modes:

- No locks
- Read only of the resource group or the resource
- No deletion

The lock was integrated into Azure via a Deny Assignment and not via the type of lock that you can manage as a user.

In the advantages of BluePrint, we therefore have a versioning system, and the use of BluePrint is very useful for the implementation of governance on a scale.

In the counters, it only manages ARM, and in addition it is included as an artefact with a custom format, so not taken into account by VSCODE. Blueprint SDKS can greatly improve. Lock management is ultra limited, and finally it's always in preview ....

Now Deployment Stack's turn, if we take up the article, the role of the latter:

- Simplify CRU operations on your Azure resources
- a more efficient cleaning process
- Protection against unwanted updates

If we compare point by point to BluePrint.

We can already bear Arm or Bice as an Infra as Code, that's better but I know that many of you use Terraform.

The SDK, although it is a preview is already available in Azcli and Azpowershell. Here we use ARM or bicep templates, no concept of artifact. And it is integrated into the portal almost everywhere. On the other hand, more concept of versioning ....

Lock management has nothing to do now we have it all:

- **DenySettingsMode**: Defines prohibited operations on managed resources to protect you from the main unauthorized security that try to remove or update them. This restriction applies to everyone, unless access is explicitly granted. These values include None, Denydelete and Denywriteanddelete.
- **DenySettingsApplyToChildScopes**: The refusal parameters are applied to nested resources under managed resources.
- **DenySettingsExcludedAction**: List of management operations based on roles that are excluded from refusal parameters. Up to 200 actions are authorized.
- **DenySettingsExcludedPrincipal**: List of the main Microsoft END ID excluded from the lock. Up to five main ones are allowed.

I think that even if it is relatively new, Deployment Stack has the future, and coupled with Specs Template it can make a good replacement in Blueprint. I hope that within 1 year or 2 I could make you a return of experience on a migration from BluePrint
