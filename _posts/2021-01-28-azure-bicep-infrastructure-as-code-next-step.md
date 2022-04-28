---
layout: post
title: Azure Bicep - Infrastructure as code, next step ?
date: 2021-01-28
categories: [ "Azure", "ARM", "Bicep" ]
comments_id: 15
---

I think many of you have at least taken a look at Azure Bicep, in this article I will try to explain why I think it is a technology to follow in the future.

**In summary, what is Azure Bicep according to Microsoft?**

Bicep is a Domain Specific Language (DSL) for deploying Azure resources declaratively. It aims to drastically simplify the authoring experience with a cleaner syntax and better support for modularity and code re-use. Bicep is a transparent abstraction over ARM and ARM templates. All resource types, apiVersions, and properties that are valid in an ARM template are equally valid in Bicep on day one.

**Now my opinion<**
Now that we've taken a little interest in the information provided by Microsoft, I became a little interested in using Bicep knowing that I'm quite used to ARM to declare my Azure resources.

So to get started on Azure Bicep, you need :

- Visual Studio Code
- Bicep CLI that you can find in the releases on [Github](https://github.com/Azure/bicep/releases)
- Bicep Extension for VSCode : [https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)

Tooling is very important to gain productivity, if I take the creation of ARM template, if you don't use the different snippets included in the Microsoft extension, it is clearly longer to write these templates from scratch.

Since Bicep generates ARM templates locally that can then be deployed on Azure, we'll compare the ARM template creation process with the tools that Microsoft makes available to us.

First of all, it is important to have tutorials on how to create our templates, and to do this here are the links :

- ARM : [Documentation Azure](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- Bicep : [Github](https://github.com/Azure/bicep/tree/main/docs)

To date Bicep is still in beta, so it is normal to have less documentation than for ARM, which has the advantage of having existed for a while.

Then you need examples, so that you don't start from scratch.

- ARM : [Github](https://github.com/Azure/azure-quickstart-templates)
- Bicep : [Github](https://github.com/Azure/bicep/tree/main/docs/examples)

In terms of examples, there are many contributions on Bicep recently, so on this point we are on equal footing with ARM templates. However one more point for Bicep, because the templates can be more complex with the use of modules, which is not proposed by default in the ARM examples.

And now let's move on to editing, and especially the functionalities of each of the VSCode extensions:

- ARM :
  
  - Snippets of sample resources
  - Azure Schema Integration
  - Support of parameter files
  - Auto Completion
  - Easy navigation in the templates

- Bicep :

  - Validation
  - Intellisense
  - Snippets of bicep objects
  - Easy navigation in bicep files
  - Refactoring

In use, it clearly appears that Bicep file editing is simplified thanks to intellisense, which is much more powerful than a simple auto-completion.

As for the differences between Bicep and ARM templates, I won't go into too much detail here, because it is clearly written in the roadmap that Bicep doesn't include all the ARM features, such as copy, but it is expected that they will be there.

To conclude, I'll just say that since I tested Bicep, I've been using only this, despite the fact that I had to write several thousand lines of ARM templates. And for the differences, I include them in the ARM template afterwards as long as Bicep doesn't provide them natively.
  
