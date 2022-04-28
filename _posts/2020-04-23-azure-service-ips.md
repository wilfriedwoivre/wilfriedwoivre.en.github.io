---
layout: post
title: Azure - Service IPs
date: 2020-04-23
categories: [ "Azure" ]
comments_id: 11
---

One of the requests that often comes up on Azure is that of setting up NSGs or firewalls in order to secure our assets in the Cloud. In recent years, Microsoft has done a remarkable job of providing capabilities such as Service Endpoints and Service Tags which are popularized by everyone. Now not all services have these features.

If you do a search on the internet you will find this page: [Azure IP Range and Service Tags](https://www.microsoft.com/en-us/download/details.aspx?id=56519)

If you download this document you will find a JSON file that you can parse to find the information you need.
However, Azure datacenters are acquiring new capacities day after day, and as a result new IPs may appear in this file, it is therefore updated very regularly by Microsoft.

Before there was only this file, and even before it was XML, that we had to recover on a regular basis, then parse it then inject it into our NSG configurations.

Now, this mechanism is much simpler, because there is the command `Get-AzNetworkServiceTag` in Powershell, or `az network list-service-tags` in CLI to help you.

Below in Powershell, here is how to recover the IPs of the Azure Batch management nodes for the West Europe region:

* 1st step *: Retrieve all the values for our region

```powershell
PS C:\Users\wilfr> $allTags = Get-AzNetworkServiceTag -Location westeurope
PS C:\Users\wilfr> $allTags


Name         : Public
Id           : /subscriptions/e7bd1bb5-e9af-49c7-b5aa-ac09992fdfeb/providers/Microsoft.Network/serviceTags/Public
Type         : Microsoft.Network/serviceTags
Cloud        : Public
ChangeNumber : 65
Values       : {ApiManagement, ApiManagement.AustraliaCentral, ApiManagement.AustraliaCentral2, ApiManagement.AustraliaEast...}
```

* 2nd step *: Filter only on the desired service

```powershell
PS C:\Users\wilfr> $serviceName = "BatchNodeManagement.WestEurope"
PS C:\Users\wilfr> $serviceTag = $allTags.Values | Where { $_.Name -eq $serviceName }
PS C:\Users\wilfr> $serviceTag


Name             : BatchNodeManagement.WestEurope
System Service   : BatchNodeManagement
Region           : westeurope
Address Prefixes : {13.69.65.64/26, 13.69.106.128/26, 13.69.125.173/32, 13.73.153.226/32...}
Change Number    : 1
```

* 3rd and last step *: Retrieve our Ips

```powershell
PS C:\Users\wilfr> $serviceTag.Properties.AddressPrefixes
13.69.65.64/26
13.69.106.128/26
13.69.125.173/32
13.73.153.226/32
13.73.157.134/32
13.80.117.88/32
13.81.1.133/32
13.81.59.254/32
13.81.63.6/32
13.81.104.137/32
13.94.214.82/32
13.95.9.27/32
23.97.180.74/32
40.68.100.153/32
40.68.191.54/32
40.68.218.90/32
40.115.50.9/32
52.166.19.45/32
52.174.33.113/32
52.174.34.69/32
52.174.35.218/32
52.174.38.99/32
52.174.176.203/32
52.174.179.66/32
52.174.180.164/32
52.233.157.9/32
52.233.157.78/32
52.233.161.238/32
52.233.172.80/32
52.236.186.128/26
104.40.183.25/32
104.45.13.8/32
104.47.149.96/32
137.116.193.225/32
168.63.5.53/32
191.233.76.85/32
```

And here it remains only to put them in your NSG or in your Firewall configuration according to your network topology.
