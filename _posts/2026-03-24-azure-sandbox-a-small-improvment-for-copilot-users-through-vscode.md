---
layout: post
title: Azure Sandbox - A small improvment for Copilot users through VSCode
date: 2026-03-24
categories: [ "Azure" ]
comments_id: 63 
---

Like everyone else, you probably noticed the AI shift. I assume you are using it more and more, just like all of us.

A few years ago, I built an Azure Sandbox system that lets me create ephemeral resource groups. With a simple script, I could create a resource group, run my tests, and then deletion would happen automatically based on the date set in a tag. Nothing could be simpler.

Today, to do this, I mainly use a function in my PowerShell profile to create resource groups: the well-known *New-AzTestResourceGroup* function, which some of you may already have seen in my demos.

Now with AI, it is much faster to tell Copilot: "Create a resource group named *demo-rg* in *France Central* and add a storage account." Great time savings, especially since it can also generate the deployment file for you. However, the resource group does not always include the right tags.

There is a very simple way to add this: just ask Copilot to add the tags you want each time you create a resource group. You can scope this to your workspace, or apply it globally by adding a file in your user directory.

Here is an example of a file you can add in your user directory so Copilot can automatically add tags whenever you create a resource group.

```markdown
# Azure Resource Group Tagging Convention

## Mandatory Tags for Resource Groups
When creating Azure resource groups, always add the following tags:

- **AutoDelete**: `true`
- **ExpirationDate**: Current date in format `YYYY-MM-DD` (e.g., 2026-03-05)

## Implementation
- Apply these tags when using Bicep, Terraform, ARM templates, or Azure CLI
- Use `resourceGroup()` function in Bicep or equivalent in other IaC tools
- Set tags at resource group creation time, not as an afterthought
```

And the path is: *C:\Users\YourUserName\AppData\Roaming\Code\User\globalStorage\github.copilot-chat\memory-tool\memories*

And to finish, here is the article link for the sandbox (in french sorry): [https://woivre.fr/blog/2018/11/sandbox-azure-pour-tout-le-monde](https://woivre.fr/blog/2018/11/sandbox-azure-pour-tout-le-monde)

That is a small tip so you do not forget to clean up your resources after your tests.
