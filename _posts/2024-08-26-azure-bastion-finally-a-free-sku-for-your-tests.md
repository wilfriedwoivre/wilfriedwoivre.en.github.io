---
layout: post
title: Azure Bastion - Finally a free sku for your tests
date: 2024-08-26
categories: [ "Azure", "Bastion" ]
comments_id: 47 
---

Secure access to your Azure VMS is very important, and that is part of the common sense not to put an RDP (or SSH) access available over the internet, especially with a password available in GitHub or other ...

Microsoft has released a service called Azure Bastion which allows you to secure access to your VMS through this unique point

![](https://cdn-dynmedia-1.microsoft.com/is/image/microsoftcorp/Bastion-Image-Resized?resMode=sharp2&op_usm=1.5,0.65,15,0&wid=1800&qlt=100&fmt=png-alpha&fit=constrain)

If you have not seen the news a few weeks ago, it is possible to have a SKU developer without SLA, but free, however there are a lot of features that will not be available.

The biggest features that may be missing are as follows:

- Copy/paste file
- No support for peerings (RIP your favorite lab for Hub & Spoke model)
- No custom port, so you have to stay on 3389/22

After there are other features that can be problematic like the Kerberos support, but let's say it's free, and that it's a feature that we can do without for tests, it's always possible to make a double jump.

