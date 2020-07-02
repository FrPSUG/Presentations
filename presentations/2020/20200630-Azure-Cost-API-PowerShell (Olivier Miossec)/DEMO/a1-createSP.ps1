$ServicePrincipal = New-AzADServicePrincipal -DisplayName "frpsug-demo-meetup2" -SkipAssignment

$SecureStringBinary = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($servicePrincipal.Secret)
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($SecureStringBinary)


$ServicePrincipal.ApplicationId

New-AzRoleAssignment -RoleDefinitionName "Cost Management Reader" -ServicePrincipalName $ServicePrincipal.ApplicationId