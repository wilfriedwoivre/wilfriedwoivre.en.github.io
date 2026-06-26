---
layout: post
title: Azure Keyvault - How to restore when you have Azure Policies
date: 2026-06-26
categories: [ "Azure", "KeyVault", "Policy" ]
githubcommentIdtoreplace: 
---


For governance requirements, you may have Azure Policies applied to your Key Vaults.
For example:

- Enable purge protection on your Key Vaults
- Enable soft delete on your Key Vaults
- Enforce network rules on your Key Vaults
- Deny creation of Key Vaults in specific regions
- Enforce the use of private endpoints on your Key Vaults

You are usually very happy with these policies. But now consider the following use case: a Key Vault was deleted by mistake and you want to restore it.

It is very likely that when you try to restore it, you get an error like this:

```powershell
➜  $removeKeyvault | Undo-AzKeyVaultRemoval
Undo-AzKeyVaultRemoval: Resource 'kvipbd7f00' was disallowed by policy. Policy identifiers: '[{"policyAssignment":{"name":"Deny Key Vaults without IP rules","id":"/subscriptions/subId/resourcegroups/rg-kv-iprules-lab-20260624/providers/Microsoft.Authorization/policyAssignments/assign-keyvault-ip-rule-deny"},"policyDefinition":{"name":"Key Vaults must define at least one IP rule","id":"/subscriptions/subId/providers/Microsoft.Authorization/policyDefinitions/deny-keyvault-without-ip-rules","version":"1.0.0"}}]'.
```

So you followed Microsoft documentation to restore your Key Vault, but it still fails because of a policy. In this case, the policy checks that at least one IP is configured in the Key Vault network rules.

To work around this issue, the simplest solution is to disable the policy that blocks the Key Vault restoration, restore the Key Vault, and then re-enable the policy. Of course, this only works if you have permissions to disable the policy, and disabling a policy can impact your governance, especially if it affects a large number of resources on a heavily used platform.

There is another solution that is less simple, but more elegant and does not require disabling the policy. It consists of recreating the Key Vault through an ARM or Bicep template. Here I will do it with ARM, but you can convert it to Bicep if you want.

Let's start by looking at what a deleted Key Vault looks like in JSON.

```json
{
  "Id": "/subscriptions/subId/providers/Microsoft.KeyVault/locations/westeurope/deletedVaults/kvipbd7f00",
  "DeletionDate": "2026-06-24T12:07:06Z",
  "ScheduledPurgeDate": "2026-09-22T12:07:06Z",
  "PublicNetworkAccess": null,
  "VaultUri": null,
  "TenantId": "00000000-0000-0000-0000-000000000000",
  "TenantName": null,
  "Sku": null,
  "EnabledForDeployment": false,
  "EnabledForTemplateDeployment": null,
  "EnabledForDiskEncryption": null,
  "EnableSoftDelete": null,
  "EnablePurgeProtection": true,
  "EnableRbacAuthorization": null,
  "SoftDeleteRetentionInDays": null,
  "AccessPolicies": null,
  "AccessPoliciesText": "",
  "NetworkAcls": null,
  "NetworkAclsText": "",
  "OriginalVault": null,
  "ResourceId": "/subscriptions/subId/resourceGroups/rg-kv-iprules-lab-20260624/providers/Microsoft.KeyVault/vaults/kvipbd7f00",
  "VaultName": "kvipbd7f00",
  "ResourceGroupName": null,
  "Location": "westeurope",
  "Tags": {},
  "TagsTable": null
}
```

As you can see, there is not much information about the deleted Key Vault. There are no networkAcls and no network rules. Clearly, a lot of information is missing to recreate the Key Vault.

This helps explain why the Key Vault is restored in public mode: that information is lost. Now, if we dig a bit into the API documentation, we find the [createMode](https://learn.microsoft.com/en-us/rest/api/keyvault/vaults/create-or-update#vaultcreateorupdateparameters) option, which allows you to create a Key Vault in "Recover" mode.

So we can create a Key Vault using the following ARM template:

```json
{
	"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
	"contentVersion": "1.0.0.0",
	"parameters": {
		"keyVaultName": {
			"type": "string",
			"metadata": {
				"description": "Name of the Azure Key Vault to create or recover."
			}
		},
		"location": {
			"type": "string",
			"defaultValue": "[resourceGroup().location]",
			"metadata": {
				"description": "Location for the Key Vault resource."
			}
		},
		"tenantId": {
			"type": "string",
			"defaultValue": "[subscription().tenantId]",
			"metadata": {
				"description": "Azure AD tenant ID for the Key Vault."
			}
		},
		"skuName": {
			"type": "string",
			"defaultValue": "standard",
			"allowedValues": [
				"standard",
				"premium"
			],
			"metadata": {
				"description": "SKU for the Key Vault."
			}
		},
		"ipRules": {
			"type": "array",
			"defaultValue": [],
			"metadata": {
				"description": "Array of public IPv4 CIDR strings allowed to access the Key Vault (for example: 203.0.113.10/32)."
			}
		},
		"defaultAction": {
			"type": "string",
			"defaultValue": "Deny",
			"allowedValues": [
				"Allow",
				"Deny"
			],
			"metadata": {
				"description": "Default network ACL action."
			}
		},
		"bypass": {
			"type": "string",
			"defaultValue": "AzureServices",
			"allowedValues": [
				"AzureServices",
				"None"
			],
			"metadata": {
				"description": "Traffic that can bypass network ACLs."
			}
		}
	},
	"variables": {
		"ipRuleObjects": "[map(parameters('ipRules'), lambda('ip', createObject('value', lambdaVariables('ip'))))]"
	},
	"resources": [
		{
			"type": "Microsoft.KeyVault/vaults",
			"apiVersion": "2023-07-01",
			"name": "[parameters('keyVaultName')]",
			"location": "[parameters('location')]",
			"properties": {
                "createMode": "recover",
				"tenantId": "[parameters('tenantId')]",
				"sku": {
					"family": "A",
					"name": "[parameters('skuName')]"
				},
				"enabledForDeployment": false,
				"enabledForDiskEncryption": false,
				"enabledForTemplateDeployment": false,
				"publicNetworkAccess": "Enabled",
				"networkAcls": {
					"bypass": "[parameters('bypass')]",
					"defaultAction": "[parameters('defaultAction')]",
					"ipRules": "[variables('ipRuleObjects')]",
				}
			}
		}
	],
	"outputs": {
		"keyVaultResourceId": {
			"type": "string",
			"value": "[resourceId('Microsoft.KeyVault/vaults', parameters('keyVaultName'))]"
		}
	}
}

```

This template can be called as follows:


```powershell
New-AzResourceGroupDeployment -name "recover-keyvault" -ResourceGroupName $removekeyvault.ResourceId.split('/')[4] -TemplateFile .\recover-keyvault.json -keyvaultName $removeKeyVault.VaultName  -ipRules @("1.1.1.1/32")
```

Almost like magic, your Key Vault is properly restored without changing policies.
Of course, this template should be adapted to the policies you use.

There is no longer any excuse to disable governance in your production environments.
Of course, I recommend testing this template in a test environment before using it in production, especially not as an emergency fix in the middle of the night.

