# Not supported on Mac
# Create the site
# Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Import-Module -Name Microsoft.Online.SharePoint.PowerShell
$adminUPN="admin@tenant.onmicrosoft.com" #account that has SharePoint Admin rights
$orgName="tenant.onmicrosoft.com" #name of your Azure AD Tenant
$url="https://tenant.sharepoint.com/sites/FRPSUG2703" #URL of the SPO site that you want to create
$urlAdmin="https://tenant-admin.sharepoint.com" #URL of your Sharepoint Admin
$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."

# Wait that the site is created
# Source : https://blogs.technet.microsoft.com/fromthefield/2014/02/18/office-365-powershell-script-to-create-a-list-add-fields-and-change-the-default-view-all-using-csom/
$ListTitle = "FRPSUG Demo"

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($url)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($adminUPN,$userCredential.Password)
$Context.Credentials = $Creds
$Context.ExecuteQuery()

#Retrieve lists
$Lists = $Context.Web.Lists
$Context.Load($Lists)
$Context.ExecuteQuery()

#Create list with "custom" list template
$ListInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
$ListInfo.Title = $ListTitle
$ListInfo.TemplateType = "100" #Custom List
$List = $Context.Web.Lists.Add($ListInfo)
$List.Description = $ListTitle
$List.Update()
$Context.ExecuteQuery()

#Create Fields
$fieldsName = "Resource Group Name", "Admin Name", "Password", "DNS Name"
foreach ($fieldName in $fieldsName) {

    $schemaXml="<Field DisplayName='$fieldName' Type='Text' Required='TRUE' />"
    $list.Fields.AddFieldAsXml($schemaXml, $true, [Microsoft.SharePoint.Client.AddFieldOptions]::DefaultValue)
    $Context.ExecuteQuery()

}

$schemaXml="<Field Type='Choice' DisplayName='Windows OS' Required='TRUE' Format='Dropdown'>
    <Default>2019-Datacenter</Default>
    <CHOICES>
        <CHOICE>2019-Datacenter</CHOICE>
        <CHOICE>2016-Datacenter</CHOICE>
        <CHOICE>2012-R2-Datacenter</CHOICE>
        <CHOICE>2008-R2-SP1</CHOICE>
    </CHOICES>
</Field>"
$list.Fields.AddFieldAsXml($schemaXml, $true, [Microsoft.SharePoint.Client.AddFieldOptions]::DefaultValue)
$Context.ExecuteQuery()