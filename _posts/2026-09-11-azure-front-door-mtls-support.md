---
layout: post
title: Azure Front Door - mTLS support
date: 2026-09-11
categories: [ "Azure", "Front Door" ]
comments_id: 217 
---

It is still in preview, but mTLS support is finally coming to Azure Front Door.

First, here is the link to the [documentation](https://learn.microsoft.com/en-us/azure/frontdoor/mutual-tls?WT.mc_id=AZ-MVP-4039694).

As a reminder, mTLS provides enhanced security by authenticating both the client and the server. The client must therefore present a valid certificate to access the asset exposed by the server.

For clarity, here is what this looks like in a diagram (thanks to Cloudflare for the diagram):
![alt text]({{ site.url }}/images/2026/09/11/azure-front-door-mtls-support-img1.png)


Why this is good news is that it is now possible to expose a global asset like Front Door and add stronger security with mTLS. The PaaS solutions available on Azure today are limited to Azure Application Gateway and Azure API Management. As you know, both of these components are regional, which therefore requires significant work on resilience and high-availability concerns.


As for the preview limitations I see, and which I hope will be corrected or improved before a likely GA release:

- Certificate rotation is not yet operational.
- Only a single certificate is allowed, which impacts rollover, especially for a global asset like Front Door. No timeline has been announced for updates to this type of configuration. 


