---
layout: post
title: Azure Network - Increase your subnet is now possible ! 
date: 2025-10-17
categories: [ "Azure", "Network" ]
comments_id: 58 
---

You've already found yourself in a situation where you were perhaps too cautious (or optimistic) about managing your IPs, and you assigned only a tiny /28 range to an application without realizing that tomorrow it would explode and you'd need to request a larger range to function.

Previously, the answer was often something like "Sorry, it's not possible to expand a subnet, you have to create a new one and migrate the resources or keep 2 disjoint subnets. You'll have to specify it every time you open routes, or when you need to modify route tables".

But now, good news: it's possible to add a second address prefix to your subnet like this


```powershell
$vnet = Get-AzVirtualNetwork -ResourceGroupName 'test-rg' -Name 'vnet-1'
Set-AzVirtualNetworkSubnetConfig -Name 'subnet-1' -VirtualNetwork $vnet -AddressPrefix '10.0.0.0/24', '10.0.1.0/24'
$vnet | Set-AzVirtualNetwork
```

The advantage here is that if you're lucky enough to have contiguous subnets like in the example above, your route openings simply change from 10.0.0.0/24 to 10.0.0.0/23, which greatly simplifies your operations.

But also your scale set inside your subnet can now scale to 300 nodes without having to move your workload to a new subnet. And this is also possible for GatewaySubnet if you made the mistake of creating it as /29 just for a simple Point to Site, and now you want to do S2S VPN or ExpressRoute.

