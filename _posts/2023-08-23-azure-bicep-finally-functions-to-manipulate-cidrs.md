---
layout: post
title: Azure Bicep - Finally functions to manipulate CIDRs
date: 2023-08-23
categories: [ "Azure", "Bicep", "ARM" ]
githubcommentIdtoreplace: 
---

After long periods of waiting, and Powershell scripts to prepare parameters to deploy networks or NetworkRules on services, Microsoft finally offers functions to manipulate CIDRs within your Bicep templates.

You can find the different methods on the [Microsoft documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-cidr?WT.mc_id=AZ-MVP-4039694#cidrsubnet)

Now we will try to play with it right here.

The first **cidrSubnet** method allows you to split a CIDR into different ranges, which can be very useful when you deploy standardized landing zones, and you don't want to precalculate all the ranges of your subnets. Clearly in our Bicep template, we will have something like this

```bicep
var cidr = '10.0.0.0/20'
var cidrSubnets = [for i in range(0, 10): cidrSubnet(cidr, 24, i)]

resource virtual_network 'Microsoft.Network/virtualNetworks@2023-04-01'= {
  name: 'virtual-network-demo'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        cidr
      ]
    }
  }
}


@batchSize(1)
resource subnets 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = [for (item, index) in cidrSubnets : {
  name: 'subnet-${index}'
  parent: virtual_network
  properties: {
    addressPrefix: item
  }
}]
```

And now very useful thing, when you configure Network Rules on your Azure services, you know very well that each service has its format. And in particular PostgreSQL which does not ask for a range, but which wants the start IP and the end IP. Well, thanks to the **parseCidr** method, you no longer need to do it in your script that calculates the parameters. You can simply do like this:

```bicep
var cidrSubnets = [
  '4.175.0.0/16'
  '4.180.0.0/16'
  '4.210.128.0/17'
  '4.231.0.0/17'
  '4.245.0.0/17'
  '13.69.0.0/17'
  '13.73.128.0/18'
  '13.73.224.0/21'
  '13.80.0.0/15'
  '13.88.200.0/21'
  '13.93.0.0/17'  
]


resource flexServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: 'flexwwopgs'
  location: resourceGroup().location
  properties: {
    administratorLogin: 'bigchief'
    administratorLoginPassword: ''
    version: '13'
    availabilityZone: '1'  
    storage: {
      storageSizeGB: 32
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
  }
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
}

@batchSize(1)
resource flexServerAcls 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-03-01-preview' = [for (item, index) in cidrSubnets: {
  name: 'flexpgswwo-${index}'
  parent: flexServer
  properties: {
    startIpAddress: parseCidr(item).firstUsable
    endIpAddress: parseCidr(item).lastUsable
  }
}]

```

So a big time saver, and it helps to avoid mistakes.
For my part, I am very happy to see that Microsoft continues to invest in new functions with real added value.
