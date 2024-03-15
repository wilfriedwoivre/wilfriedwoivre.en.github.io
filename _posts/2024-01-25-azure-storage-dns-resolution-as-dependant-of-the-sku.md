---
layout: post
title: Azure Storage - DNS resolution as dependant of the SKU
date: 2024-01-25
categories: [ "Azure", "Storage", "Network" ]
githubcommentIdtoreplace: 
---

During one of my investigations I came across something that I consider interesting that it is better known. I asked Microsoft to add it to the documentation, but it is still not the case.

The management of DNS of a storage is not the same depending on the skus, which means that if you use proxies to access storage, you can have unpleasant surprises.

To show you, we will start by creating one storage by type of sku with this bicep:

```bicep
var skus = [
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
]

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = [for (item, index) in skus: {
  name: 'stodns${uniqueString(deployment().name)}${index}'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: item
  }
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
  }
}]
```

We will now make a simple nslookup

```powershell
$storages = Get-AzStorageAccount -ResourceGroupName "dns-storage-rg"

foreach ($storage in $storages) {
    Write-Output "------------------------------"
    Write-Output "Storage Account $($storage.StorageAccountName) with the SKU $($storage.Sku.Name)"

    nslookup "$($storage.StorageAccountName).blob.core.windows.net"
}


```

And we see in the results of interesting things:

```bash
------------------------------
Storage Account stodnsrbgf3xv4ufgzg0 with the SKU Standard_LRS
Server:  UnKnown
Address:  10.104.244.68

Name:    blob.amz06prdstr04c.store.core.windows.net
Address:  20.38.109.228
Aliases:  stodnsrbgf3xv4ufgzg0.blob.core.windows.net

------------------------------
Storage Account stodnsrbgf3xv4ufgzg1 with the SKU Standard_ZRS
Server:  UnKnown
Address:  10.104.244.68

Name:    blob.AMS07PrdStrz04A.trafficmanager.net
Addresses:  20.150.9.196
	  20.150.76.4
	  20.150.9.228
Aliases:  stodnsrbgf3xv4ufgzg1.blob.core.windows.net
	  blob.ams07prdstrz04a.store.core.windows.net

------------------------------
Storage Account stodnsrbgf3xv4ufgzg2 with the SKU Standard_GRS
Server:  UnKnown
Address:  10.104.244.68

Name:    blob.ams20prdstr15a.store.core.windows.net
Address:  20.209.108.75
Aliases:  stodnsrbgf3xv4ufgzg2.blob.core.windows.net

------------------------------
Storage Account stodnsrbgf3xv4ufgzg3 with the SKU Standard_GZRS
Server:  UnKnown
Address:  10.104.244.68

Name:    blob.AMS07PrdStrz10A.trafficmanager.net
Addresses:  20.209.193.33
	  20.209.231.33
	  20.209.193.65
Aliases:  stodnsrbgf3xv4ufgzg3.blob.core.windows.net
	  blob.ams07prdstrz10a.store.core.windows.net

------------------------------
Storage Account stodnsrbgf3xv4ufgzg4 with the SKU Standard_RAGRS
Server:  UnKnown
Address:  10.104.244.68

Name:    blob.ams23prdstr18a.store.core.windows.net
Address:  20.60.27.132
Aliases:  stodnsrbgf3xv4ufgzg4.blob.core.windows.net

------------------------------
Storage Account stodnsrbgf3xv4ufgzg5 with the SKU Standard_RAGZRS
Server:  UnKnown
Address:  10.104.244.68

Name:    blob.AMS07PrdStrz10A.trafficmanager.net
Addresses:  20.209.231.33
	  20.209.193.65
	  20.209.193.33
Aliases:  stodnsrbgf3xv4ufgzg5.blob.core.windows.net
	  blob.ams07prdstrz10a.store.core.windows.net

------------------------------
Storage Account stodnsrbgf3xv4ufgzg6 with the SKU Premium_LRS
Server:  UnKnown
Address:  10.104.244.68

Name:    blob.ams06prdstp06a.store.core.windows.net
Address:  52.239.212.228
Aliases:  stodnsrbgf3xv4ufgzg6.blob.core.windows.net

------------------------------
Storage Account stodnsrbgf3xv4ufgzg7 with the SKU Premium_ZRS
Server:  UnKnown
Address:  10.104.244.68

Name:    blob2.AMS08PrdStfz01A.trafficmanager.net
Addresses:  20.209.109.130
	  20.209.108.2
	  20.209.108.162
Aliases:  stodnsrbgf3xv4ufgzg7.blob.core.windows.net
	  blob2.ams08prdstfz01a.store.core.windows.net
```

We can therefore see here that all the storage with a SKU having a zone resilience go through a traffic manager in the resolution of their domain name. It will therefore be necessary to think of opening the resolution to the domain __*.trafficManager.net__ in your local dns.
