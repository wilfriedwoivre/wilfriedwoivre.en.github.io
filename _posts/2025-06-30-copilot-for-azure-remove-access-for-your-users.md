---
layout: post
title: Copilot for Azure - Remove access for your users
date: 2025-06-30
categories: [ "Azure", "Copilot" ]
githubcommentIdtoreplace: 
---

Azure Copilot is a powerful tool that can transform the way your users interact with Microsoft's public cloud.

However, it is essential to set up appropriate access controls to ensure that only authorized persons can use this tool.

To do this, in the Azure portal, with an account that has global Admin rights on your tenant, and User Access Administrator rights on your Root Management Group, you can restrict access to Azure Copilot by following these steps:

- Go to the Azure portal.
- Navigate to **Copilot in Azure Admin Center**
- Click on **Access Management**.
- Change the setting **Available to all users** to **Not available to all users**
- Grant access rights to eligible users by adding a role on the root tenant Group **Copilot in Azure User**

Now there may be several reasons to take this action:

- You want to prevent Microsoft from collecting data on your prompts. [FAQ Azure Copilot](https://learn.microsoft.com/en-us/azure/copilot/responsible-ai-faq?WT.mc_id=AZ-MVP-4039694#what-data-does-microsoft-copilot-in-azure-collect) _Prompts provided by users and responses from Microsoft Azure Copilot are collected and used to improve Microsoft products and services only when users have given their explicit consent to include this information in feedback_
- You want to establish strict governance over the use of AI in your organization.
- For large enterprises, you want to guard against a wait time on the use of Copilot by only providing it to a limited number of users. [Current limitations](https://learn.microsoft.com/en-us/azure/copilot/capabilities?WT.mc_id=AZ-MVP-4039694#current-limitations)

And finally, it is important to be aware that blocking this feature may impact your user's productivity, as they will not be able to benefit from the advantages of AI in their daily tasks.
Indeed, Azure Copilot can help users automate tasks, find information more quickly, and improve their overall efficiency. Today, the service contains many features and is enriched week by week.

[Copilot Capabilities](https://learn.microsoft.com/en-us/azure/copilot/capabilities?WT.mc_id=AZ-MVP-4039694#perform-tasks), to this day:

- Understand your Azure environment:

    - Get insights into resources via Azure Resource Graph queries
    - Understand service events and health status
    - Analyze, estimate, and optimize costs
    - Search for Azure Advisor recommendations
    - Visualize network topology
    - Analyze your attack surface
    - Review Azure Firewall IDPS attacks

- Work smarter with Azure services:

    - Run commands
    - Deploy and manage virtual machines
    - Discover and deploy workload templates
    - Use AKS clusters effectively
    - Get insights into Azure Monitor metrics and logs

- Work smarter with Azure Local

    - Manage and troubleshoot storage accounts
    - Resolve disk performance issues
    - Design, troubleshoot, and secure networks
    - Resolve Azure Arc extension issues
    - Improve Azure SQL Database-based applications

- Write and optimize code:

    - Generate Azure CLI scripts
    - Generate PowerShell scripts
    - Generate Terraform and Bicep configurations
    - Create API management policies
    - Generate Kubernetes YAML files
    - Resolve application issues faster with App Service

In my opinion, in 2025, having a corporate policy that prohibits the use of AI is counterproductive. Companies that do not leverage AI risk falling behind their competitors who adopt it. It is essential to find a balance between governance and innovation to remain competitive in the market.

Azure Copilot is an essential tool for all profiles using the Cloud, whether as a developer, architect, infrastructure, SRE, Cyber Expert, FinOps, and more. So weigh the pros and cons carefully before limiting the use of Copilot in the enterprise.
