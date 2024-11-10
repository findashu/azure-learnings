# Ensure you are logged into Azure
#Connect-AzAccount
$ErrorActionPreference = "Stop"
# Prompt for Subscription and Resource details
$subscriptionId = ""
$resourceName = "sa"
$roleName = "Storage Blob Data Contributor"
$identityType = "ADGroup"
$identityName = "ggroupone"

# Set the current Azure subscription
Set-AzContext -SubscriptionId $subscriptionId


if($identityType -eq "SPN") {
    $objectId = (Get-AzADServicePrincipal -DisplayName $identityName).Id
} else {
    $objectId = (Get-AzADGroup -DisplayName $identityName).Id
}


# Get the resource ID for the specified resource
$resourceId = (Get-AzResource -Name $resourceName).Id

# Check if the role is already assigned to the identity
$roleAssignments = Get-AzRoleAssignment -Scope $resourceId -PrincipalId $objectId

# Check if the identity already has the role assigned
$roleAssignmentExists = $roleAssignments | Where-Object { $_.RoleDefinitionName -eq $roleName }

if ($roleAssignmentExists) {
    Write-Host "The identity already has the '$roleName' role assigned to the resource." -ForegroundColor Green
} else {
    # If the role is not assigned, assign it
    Write-Host "Assigning '$roleName' role to the identity..." -ForegroundColor Yellow
    New-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName $roleName -Scope $resourceId
    Write-Host "Role '$roleName' successfully assigned to the identity." -ForegroundColor Green
}
