---
layout: post
title: Azure VM - RunCommand access
date: 2026-04-23
categories: [ "Azure", "Virtual Machines"  ]
githubcommentIdtoreplace: 
---

Just a quick article to talk about the RunCommand permission on virtual machines.

It is very practical, I agree, and I use it regularly, but it can also be dangerous if given to people who shouldn't have it.

Indeed, the permission on Windows runs as SYSTEM, and can therefore do anything on the virtual machine, including installing malware or stealing sensitive data, or disabling security services.
And on Linux, it's no better as it runs as sudo, and can also do anything.

And to top it off, once you have run a command, it is not possible to stop it, so do not copy commands that you do not understand, or that you have not verified, and do not run them on production machines without having tested them beforehand in a test environment.

So do not give this permission *Microsoft.Compute/virtualMachines/runCommand/action* to just anyone, and make sure that the people who have it are trustworthy and know what they are doing. Or give it on machines in sandboxes that do not have access to your production environments.
