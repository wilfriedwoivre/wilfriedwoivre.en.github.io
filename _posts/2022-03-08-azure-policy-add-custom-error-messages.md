---
layout: post
title: Azure Policy - Add custom error messages
date: 2022-03-08
categories: ["Azure", "Policy"]
comments_id: 19 
---

Azure Policy is very useful to do governance on Azure, however the error messages are not always clear, but it is possible to customize them as we will see in this article

Let's imagine a policy for your storage accounts to validate that they will all be accessible only in https, so we will have a policy like this:

```json
"if": {
    "allOf": [
        {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
        },
        {
            "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
            "equals": false
        }
    ]
},
"then": {
    "effect": "deny"
}
```

When assigning it, you will want to give it a name, at this point you have several choices:

- Put a name that speaks to all those who will have the error message such as *AllowOnlyStorageAccountWithOnlyHttpsSupport*
- Put a unique identifier such as *4cd4c48a-9a10-4386-ae0e-45ee0205231b*, since we agree that there is nothing better than a Guid, or not ...
- Have a nomenclature on your different Azure Policies in order to find them easily and avoid typos or approximate English, except that there is a risk of ending up with a code that is not always clear such as STG-SPEC-NWK-RSK0 (Storage-Specific-Network-Risk_0)
- The answer D

Well, to be honest, I prefer the third choice, because a nomenclature can be declined and there is no need to invent a name for everything. The real drawback however is that sometimes your policies get triggered and your users legitimately ask you "If not Wilfried, what does this error code mean?"
Well you should know that now all these support concerns are over, because Microsoft has provided the ability to put custom error messages like this:

![]({{ site.url }}/images/2022/03/08/azure-policy-add-custom-error-messages-img0.png)

So when you create your Storage Account, for example in powershell, you will get this message:

```powershell
PS C:\Users\wilfr> New-AzStorageAccount -Name policytestwwo -ResourceGroupName policy-test-2 -Kind StorageV2 -SkuName Standard_LRS -Location westeurope -AccessTier Hot -EnableHttpsTrafficOnly $false
New-AzStorageAccount : Resource 'policytestwwo' was disallowed by policy. Reasons: 'Allow only storage account with
only https support enabled'. See error details for policy resource IDs.
At line:1 char:1
+ New-AzStorageAccount -Name policytestwwo -ResourceGroupName policy-te ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : CloseError: (:) [New-AzStorageAccount], CloudException
    + FullyQualifiedErrorId : Microsoft.Azure.Commands.Management.Storage.NewAzureStorageAccountCommand
```

And voilà there you have your custom message! Of course, you can put whatever you want like a link to your internal documentation for this Policy.
