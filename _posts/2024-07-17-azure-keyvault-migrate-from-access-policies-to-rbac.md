---
layout: post
title: Azure KeyVault - Migrate from access policies to RBAC
date: 2024-07-17
categories: [ "Azure", "KeyVault" ]
comments_id: 46 
---

On Azure, you can create and use Keyvault with two modes, with accesspolicia as historically, or with RBAC mode. And good news with this last mode we can put fine rights on each secret of your Keyvault, and no more a global permission on the keyvault.

Like any new feature on Azure, and changes to existing products, there is often the fact that the old mode becomes _legacy_. We can therefore ask questions around migration.

It is very simple to go from a Keyvault to AccessPolicy in RBAC via this PowerShell command

```powershell
Update-AzKeyVault -VaultName $name -ResourceGroupName $rg -EnableRbacAuthorization $true 
```

However, pay attention to the management of existing rights on your Keyvaults which will be lost, and that it will be necessary to migrate beforehand.

Microsoft provided built in role definition containing the default rights, but you do not have the same level of granularity as via the police access in terms of law.

I wrote a script that will create custom role for each operation available on the provider via the following commands:

```powershell
$keyVaultDataOperations = Get-AzproviderOperation -OperationSearchString 'Microsoft.keyvault/vaults/*' | Where { $_.IsDataAction } 

foreach ($operation in $keyVaultDataOperations) {
    Write-Host "Create keyvault rbac role for operation: $($operation.Operation)"

    $roleDefinitionName = "$BaseRoleDefinitionName - $($operation.OperationName)"
    if ($null -eq (Get-AzRoleDefinition -Name $roleDefinitionName -ErrorAction SilentlyContinue)) {
        $role = New-Object -TypeName Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition 
        $role.Name = $roleDefinitionName
        $role.Description = "Custom role definition for fine grained RBAC KeyVault operation $($operation.Operation) - $($operation.Description)"
        $role.IsCustom = $true
        $role.AssignableScopes = @("/subscriptions/$((Get-AzContext).Subscription.Id)")
        $role.Actions = @()
        $role.NotActions = @()
        $role.NotDataActions = @()
        $role.DataActions = @($operation.Operation)
        New-AzRoleDefinition -Role $role
    } 
}
```

And then we are going to create assignment roles for each of the rights declared in the accesspolicies of our Keyvaults.

For example for secrets, it will give us something of this type:

```powershell
foreach ($permission in $accessPolicy.PermissionsToSecrets) {
    if ($permission.ToLowerInvariant() -eq "all") {
        $roleDefinitions = Get-AzRoleDefinition | Where-Object { $_.IsCustom -and $_.Description.ToLowerInvariant().Contains('microsoft.keyvault/vaults/secrets') }
        $roleDefinitions | ForEach-Object { 
            if ($null -eq (Get-AzRoleAssignment -RoleDefinitionId $_.Id -ObjectId $accessPolicy.ObjectId -Scope $vault.ResourceId -ErrorAction SilentlyContinue)) {
                New-AzRoleAssignment -RoleDefinitionId $_.Id -ObjectId $accessPolicy.ObjectId -Scope $vault.ResourceId
            }
        }
    }
    else {
        if ($permission.ToLowerInvariant() -eq "get" -or $permission.ToLowerInvariant() -eq "list") {
            $permission = "read"
        }

        $roleDefinition = Get-AzRoleDefinition | Where-Object { $_.IsCustom -and $_.Description.ToLowerInvariant().Contains("microsoft.keyvault/vaults/secrets/$($permission.ToLowerInvariant())") }
        if ($null -eq $roleDefinition) {
            Write-Error "Role definition not found for permission $($permission)"
            exit
        }
        else {
            if ($null -eq (Get-AzRoleAssignment -RoleDefinitionId $roleDefinition.Id -ObjectId $accessPolicy.ObjectId -Scope $vault.ResourceId -ErrorAction SilentlyContinue)) {
                New-AzRoleAssignment -RoleDefinitionId $roleDefinition.Id -ObjectId $accessPolicy.ObjectId -Scope $vault.ResourceId
            }
        }
    }
}
```

It is therefore possible from this script to migrate our AccessPolicie Rights in RBAC.

However in my humble opinion, even if it is possible to migrate via a one shot script, I strongly advise you to carry out your migration with the following steps:

- Identify the keyvaults to migrate
- Identify the necessary rights and the expected scope
- Set up the RBAC
- Migrate your Keyvaults
- Apply fine rights on your secrets if necessary.

