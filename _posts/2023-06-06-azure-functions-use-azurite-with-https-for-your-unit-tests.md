---
layout: post
title: Azure Functions - Use Azurite with HTTPS for your unit tests
date: 2023-06-06
categories: [ "Azure", "Function" ]
githubcommentIdtoreplace: 
---

Previously, development was my core business, much less to date, but I always have great pleasure in developing applications. Most of these are based on serverless. My favorite language is C# so naturally I use Azure Functions for my developments.

 For my last project, I decided to do this in the rules of the art, finally at least I try, and therefore I set up unit tests for my Azure Function. Since from my point of view to make mocks for base access are useless to date, given the simplicity of having local and disposable bases or emulators to do the tests, as much to use them, and not to have reproduced everything The mock linked to access.

 Here my need is very simple, using an Azure Function which will insert data into a storage table.

 My C# code to connect to my account is therefore:

```csharp
var client = new TableClient(new Uri(this._options.Uri), tableName, new DefaultAzureCredential());
```

This allows me to only give access to my customer table, and to use the defaultazurecredential which will eventually allow me to use a managed identity in Azure.

 If we follow the Azure documentation, they explain that we must put as url for our table storage something like this: *http://127.0.0.1:10002*. So that's when I said to myself but why not https. If we look at the rest of the documentation they explain how to do it, but let's put it on the account of fatigue, it does not work, so we will do it here step by step.

## Installation

### Azurite

Simply in Visual Studio Code extensions, look for Azurite and install it.
Or via the link of the [Marketplace](https://marketplace.visualstudio.com/items?itemName=Azurite.azurite)

### Storage Explorer

Microsoft Documentation : [Storage Explorer](https://azure.microsoft.com/en-us/products/storage/storage-explorer/)

### mkcert

With Winget

```powershell
winget install mkcert
```

But any other tool to generate a PEM certificate with its key will do the trick.

## Azurite configuration

We are going to create our certificate for our local azurite to start, for that we are going to use mkcert.

```powershell
mkcert -install
mkcert 127.0.0.1
```

So we have two files that were created following this command.
After that, we will modify the settings of your VS code to configure our Azurite as follows:

```json
"azurite.location": ".azurite",
"azurite.cert": "D:\\Community\\ipam\\.azurite\\127.0.0.1.pem",
"azurite.key": "D:\\Community\\ipam\\.azurite\\127.0.0.1-key.pem",
"azurite.oauth": "basic"
```

For my part, I use the configurations of my workspace, and not that global, because this is linked to this project. So the following configurations are therefore used for this:

- Azurite.Location: This is the file where Azurite will store the data
- azurite.cert: this is the path to the PEM certificate
- Azurite.key: This is the path to the key to the PEM certificate
- Azurite.oauth: This is the type of authentication, here Basic, because it is the only one that works with HTTPS, and which allows me to use the defaultazurecredential.

It only remains to launch Azurite, and to launch our test.

## Storage Explorer configuration

Testing from VSCode is good, we have a beautiful message that we are successful. But hey I am curious and I still want to see the contents of my storage.

 For this, I reopen Mkcert and I make the following order:

```powershell
mkcert -CAROOT
```

Here I collect the path to a file that contains for CAROOT. I matter this one and the one called 127.0.0.1.pem in Storage Explorer with the option "Edit" -> "SSL certificates" -> "Import certificate". A reboot, and we can after importing our local storage, and traveling it as if it were on Azure.
