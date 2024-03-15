---
layout: post
title: Azure - Spring cleaning for your rbac
date: 2023-12-04
categories: ["Azure"]
githubcommentIdtoreplace: 
---

I suppose that in your Azure account, you have already come across the famous **Identiy not found** in your RBAC assignments

![alt text]({{ site.url }}/images/2023/12/04/azure-spring-cleaning-for-your-rbac-img0.png)

All of these identities have been deleted from your Entra ID, whether it is a user, a group or a SPN. However, Azure does not clean up for you, and it's up to you. But good news it doesn't count in the role of effective assignments and therefore within the limits it is just ugly in the portal.

So here is a small script to clean up:

```powershell
[CmdletBinding()]
param (
    [switch] $DryRun,
    [PSDefaultValue(Help='Current subscription')]
    [Parameter(Mandatory = $false, HelpMessage="Use a valid azure scope")]
    [string] $scope = ""
)

Connect-MgGraph -Scopes "Directory.Read.All" -NoWelcome

[array]$assignments = @()

if ("" -eq $scope) {
    $assignments = Get-AzRoleAssignment
} else {
    $assignments = Get-AzRoleAssignment -Scope $scope
}

Write-Output "Found $($assignments.Count) assignments"

foreach ($assignment in $assignments) {
    Write-Verbose "Processing $($assignment.RoleAssignmentId)"
    if ($null -eq (Get-MgDirectoryObject -DirectoryObjectId $assignment.ObjectId -ErrorAction SilentlyContinue)) {
        Write-Output "Removing $($assignment.RoleAssignmentId)"
        if (-not $DryRun) {
            $assignment | Remove-AzRoleAssignment
        }
    }
}

```
