---
layout: post
title: Azure VM - Update your boot diagnostics
date: 2026-01-27
categories: [ "Azure", "Virtual Machines" ]
comments_id: 61 
---

As you all know, logs are important. One log that is often underestimated is boot diagnostics, at least to confirm whether the VM started correctly.
Previously in Azure, you could configure boot diagnostics by relying on a storage account to store the different data.

For some time now, Microsoft has updated the boot diagnostics configuration for Azure virtual machines. From now on, you can configure boot diagnostics without creating a dedicated storage account. In other words, it is now fully managed by Microsoft.

Here is a Graph query to detect all your VMs that have not yet switched to this new boot diagnostics mode:

```kql
resources
| where type =~ "microsoft.compute/virtualMachines"
| where properties.diagnosticsProfile.bootDiagnostics.enabled == true
| where isnotnull(properties.diagnosticsProfile.bootDiagnostics.storageUri)
```

If this can help you avoid dedicated storage accounts for boot diagnostics, that is one less resource to manage and secure, and it simplifies the configuration of your virtual machines.
