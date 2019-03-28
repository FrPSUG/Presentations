# Not supported on Mac
# Create the site
# Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Import-Module -Name Microsoft.Online.SharePoint.PowerShell
$adminUPN="admin@tenant.onmicrosoft.com" #account that has SharePoint Admin rights
$orgName="tenant.onmicrosoft.com" #name of your Azure AD Tenant
$url="https://tenant.sharepoint.com/sites/FRPSUG2703" #URL of the SPO site that you want to create
$urlAdmin="https://tenant-admin.sharepoint.com" #URL of your Sharepoint Admin
$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."
Connect-SPOService -Url $urlAdmin -Credential $userCredential
New-SPOSite -Owner $adminUPN -StorageQuota 100 -Url $url -NoWait -Template "PROJECTSITE#0" -TimeZoneID 10 -Title "French PowerShell User Group"