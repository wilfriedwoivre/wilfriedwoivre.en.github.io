---
layout: post
title: Azure Network - No more public subnets
date: 2025-12-15
categories: [ "Azure", "Network" ]
comments_id: 60 
---

In late March 2026, Microsoft announced an important update regarding public subnets in Azure. From now on, subnets will be private by default, which means that resources deployed in these subnets will not have direct Internet access. This decision was made to strengthen the security of Azure environments and encourage best practices in networking.

So what exactly changes for you? Well, if you're in an enterprise with Zero Trust and hub & spoke architecture, this concretely changes nothing for you. Because the subnets in your spokes are already private by nature, since they go through your hub to access the Internet.

However, for smaller environments, you'll need to think carefully about either making your subnets public again or explicitly enabling Internet access via a NAT Gateway, a Firewall, or a Load Balancer with an outbound rule or a static IP on your VMs.

Concretely, your route table—whether implicit or explicit—to the Internet is disabled, so you need to replace it with a direct route.
The simplest solution is to set up a NAT Gateway, but be careful about the cost of this service since pricing is also based on data passing through it.

Microsoft provides examples for private subnets, I recommend you take a look: [GitHub - Azure Networking Private Subnet Routing](https://github.com/Azure-Samples/azure-networking_private-subnet-routing)
