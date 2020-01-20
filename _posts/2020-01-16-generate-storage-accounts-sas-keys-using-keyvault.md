---
layout: post
title: Generate storage accounts SAS Keys using Keyvault 
date: 2020-01-16
categories: [ "Azure", "KeyVault", "Storage" ]
---

In business, security is a key point. It is not possible to design an application without any notion of security, whether this application is hosted on-premise or in the Cloud (preferably Azure).

Using Azure storage accounts for Blob, Tables or Queues, you may want to avoid using the storage keys in your solution or in the configuration available on your servers for Leakage reasons.

It is possible to set up several solutions to avoid using keys in your configuration:
* Use an SPN which will authenticate to Azure to get the key from your storage and if necessary generate a SAS Key
* Set up an SPN which will have access via AD on your storage account (this will be dealt with in a future article)
* Use an SPN which will have access to a KeyVault containing your storage keys
* Use the KeyVault to generate SAS Key.

First, you need the necessary access policies on the KeyVault to perform the add operation, and to assign the right policies to the users or SPN who will use it. By the way, it is not possible to do this operation via the portal, here is an example in Powershell:

```powershell
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $userPrincipalId -PermissionsToStorage get,list,delete,set,update,regeneratekey,getsas,listsas,deletesas,setsas,recover,backup,restore,purge
```

The second step is to associate your KeyVault with a storage account. It is possible to do this in PowerShell using the following commands:

```powershell
$storage = Get-AzureRMStorageAccount -StorageAccountName $storageAccountName -ResourceGroupName $storageAccountResourgeGroup

Add-AzureKeyVaultManagedStorageAccount -VaultName $keyvaultName -AccountName $storageAccountName -AccountResourceId $storage.Id -ActiveKeyName key2 -DisableAutoRegenerateKey
```

On this last step it is possible to activate the regeneration of the keys automatically on your storages.

The last step is to build a SAS Key which will be the template for the generation of the next keys. This template will be used to retrieve a new key. Here's how to do that in powershell:

```powershell
$sasTokenName = "fullaccess"
$storageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountResourgeGroup -Name $storageAccountName).Value[0]

$context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey -Protocol Https
$start = [System.DateTime]::Now.AddMinutes(-15)
$end = [System.DateTime]::Now.AddMinutes(15)
$token = New-AzureStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission "racwdlup" -Protocol HttpsOnly -StartTime $start -ExpiryTime $end -Context $context

$validityPeriod = [System.Timespan]::FromMinutes(30)
Set-AzureKeyVaultManagedStorageSasDefinition -VaultName $keyVaultName -AccountName $storageAccountName -Name $sasTokenName -ValidityPeriod $validityPeriod -SasType 'account' -TemplateUri $token
```

It is important to use an explicit and unique "sasTokenName" for each of your SAS Key, because this is the one that will be used later.

Now to get my SAS key, I just need to call the KeyVault with the following secret: **StorageAccountName-sasTokenName**, as we can see below in Powershell:

```powershell
$sasKey = (Get-AzureKeyVaultSecret -VaultName $keyvaultName -Name ("wwodemospn-fullaccess")).SecretValueText
```

With this method, no more storage keys lying around in config files.
