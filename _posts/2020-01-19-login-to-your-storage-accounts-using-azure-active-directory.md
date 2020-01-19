---
layout: post
title: Login to your Storage Accounts using Azure Active Directory
date: 2020-01-19
categories: [ "Azure", "Storage", "Azure Active Directory" ]
---

Previously, I wrote an article talking about how to use KeyVault to generate SAS Keys: [http://woivre.com/blog/2020/01/generate-storage-accounts-sas-keys-using-keyvault](http://woivre.com/blog/2020/01/generate-storage-accounts-sas-keys-using-keyvault)

In the same philosophy as the latter, it is possible to completely avoid using the Storage keys in your configs or your source code, even if I hope that it is already the case.

Some services on Azure support RBAC roles, such as storage accounts, which contain Reader or Contributor rights on Blob and queues.

Thanks to this it is possible for a specific AD account to connect to my Azure Storage to get a file for example.

The names of the build-in roles that exist for the storage accounts are:
* Storage Blob Data Contributor (Preview)
* Storage Blob Data Reader (Preview)
* Storage Queue Data Contributor (Preview)
* Storage Queue Data Reader (Preview)

It is possible to configure these different permissions using the DataAction property in the definition of your RBAC roles.

Until now, the C # SDK for Storage does not support this new functionality it must be done via the Azure REST APIs, as below:

```csharp
AuthenticationContext authContext = new AuthenticationContext($"https://login.microsoftonline.com/{TenantId}");
AuthenticationResult authResult = await authContext.AcquireTokenAsync($"https://{StorageAccountName}.blob.core.windows.net/", new ClientCredential(ApplicationId, SecretKey));
	
HttpClient client = new HttpClient(); 
client.DefaultRequestHeaders.Add("Authorization", "Bearer " + authResult.AccessToken);
client.DefaultRequestHeaders.Add("x-ms-version", "2017-11-09");

var response = await client.GetStringAsync($"https://{StorageAccountName}.blob.core.windows.net/{ContainerName}/{BlobName}");	
```

I generate a token thanks to ADAL and that I ask for it for my storage account.

With this article, you have even fewer excuses to keep your storage keys in your configs.
