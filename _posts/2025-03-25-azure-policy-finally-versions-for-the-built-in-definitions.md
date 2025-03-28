---
layout: post
title: Azure Policy - Finally versions for the Built-in definitions
date: 2025-03-25
categories: [ "Azure", "Policy" ]
githubcommentIdtoreplace: 
---

During the last ignite, Microsoft announced a feature that I expected a lot around the Azure Policy, they are versioned.

If like me, you have been using Azure Policy for a long time, you should see that the definition of the policy provided by Microsoft can vary from one release to another. Technically these versions provide that new useful features, but hey I don't really like having deployed safety elements without my eye.

So now these police have versions, and to use them it's very simple, you just need to make this order to list the versions of a policy:

```powershell
get-azpolicyDefinition -Name '36fd7371-8eb7-4321-9c30-a7100022d048' | Select DisplayName, Versions

DisplayName                                    Versions
-----------                                    --------
Requires resources to not have a specific tag. {2.0.0, 1.1.1, 1.0.1, 1.0.0}

```

And to assign the one you want just make this order:

```powershell
# Select your definition
$definition = get-azpolicyDefinition -Name '36fd7371-8eb7-4321-9c30-a7100022d048' -Version 1.1.1

# Assign your policy
$policyparams = @{
    Name = 'test-policy-version'
    DisplayName = 'Test policy version'
    Scope = $rg.ResourceId
    PolicyDefinition = $definition
    Description = 'Test policy version'
}

New-AzPolicyAssignment @policyparams
```

And good news, this respects the management of semantic versions, and not versions with more or less obscure dates such as Azure Providers resources.
