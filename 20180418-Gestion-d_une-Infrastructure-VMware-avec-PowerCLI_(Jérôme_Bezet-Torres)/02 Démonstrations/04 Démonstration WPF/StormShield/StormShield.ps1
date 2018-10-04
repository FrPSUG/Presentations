$ProgressPreference = 'SilentlyContinue'
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       | out-null 
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.IconPacks.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"
[System.Windows.Forms.Application]::EnableVisualStyles()


#########################################################################
#                        Load Main Panel                                #
#########################################################################

$Global:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition

function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}
$XamlMainWindow=LoadXaml($pathPanel+"\Main.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)


#########################################################################
#                        HAMBURGER VIEWS                                #
#########################################################################

#******************* Item in the menu  *****************
$Connection      		= $Form.FindName("Connection") 
$Scenario_1   			= $Form.FindName("Scenario_1")
$Scenario_2   			= $Form.FindName("Scenario_2") 
$Cleans	     			= $Form.FindName("Cleans") 
$Information    		= $Form.FindName("Others") 

#******************* Generral controls  *****************
$TabMenuHamburger 	= $Form.FindName("TabMenuHamburger")

#******************* Load Other Views  *****************
$viewFolder = $pathPanel +"\views"

$XamlChildWindow = LoadXaml($viewFolder+"\Connection.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Connection_Xaml  = [Windows.Markup.XamlReader]::Load($Childreader)
$Connection.Children.Add($Connection_Xaml)        		 | Out-Null

$XamlChildWindow = LoadXaml($viewFolder+"\Scenario1.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Scenario_1_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader)
$Scenario_1.Children.Add($Scenario_1_Xaml)  			 | Out-Null 

$XamlChildWindow = LoadXaml($viewFolder+"\Scenario2.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Scenario_2_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader)
$Scenario_2.Children.Add($Scenario_2_Xaml)    			 | Out-Null

$XamlChildWindow = LoadXaml($viewFolder+"\Cleans.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Cleans_Xaml     = [Windows.Markup.XamlReader]::Load($Childreader)
$Cleans.Children.Add($Cleans_Xaml)    					 | Out-Null   

$XamlChildWindow = LoadXaml($viewFolder+"\Info.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Info_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader) 
$Information.Children.Add($Info_Xaml)	   		 | Out-Null 
       

#******************************************************
# Initialize with the first value of Item Section *****
#******************************************************

$TabMenuHamburger.SelectedItem = $TabMenuHamburger.ItemsSource[0]

#########################################################################
#                        HAMBURGER EVENTS                               #
#########################################################################


#******************* Items Section  *******************

# Controls for Connection part
$Connection_vCenter = $Connection_Xaml.findname("ConnectionvCenter")
$Disconnect_vCenter = $Connection_Xaml.findname("DiscovCenter")
$Icon_NC = $Connection_Xaml.findname("Disconnect")
$Icon_C = $Connection_Xaml.findname("Connect")
$Status_Connection_Info = $Connection_Xaml.findname("Status_C_NC")
$passwordBox = $Connection_Xaml.findname("passwordBox")
$Utilisateur = $Connection_Xaml.findname("Utilisateur")
$Host_Connection = $Connection_Xaml.findname("Host_IP")
$DataGrid_Datastore = $Connection_Xaml.findname("DataGrid_DataStore")
$DataGrid_Network = $Connection_Xaml.findname("DataGrid_Network")
$DataGrid_vSwitch = $Connection_Xaml.findname("DataGrid_vSwitch")
$Parametres =$Connection_Xaml.findname("Parametres") 
$AutoLogin =$Connection_Xaml.findname("AutoLogin") 
$SaveCred =$Connection_Xaml.findname("SaveCred") 


# Controls for Scenario_1 part
$NB_Grp = $Scenario_1_Xaml.findname("NB_Grp")
$Espace_disk_SC1 = $Scenario_1_Xaml.findname("Espace_disk_SC1")
$NB_Vlan = $Scenario_1_Xaml.findname("NB_Vlan_SC1")
$Besoin_RAM_SC1 = $Scenario_1_Xaml.findname("B_Ram_SC1")
$Liste_Vlan_SC1 = $Scenario_1_Xaml.findname("Liste_Vlan_SC1")
$Check1 = $Scenario_1_Xaml.findname("Check1")
$Run_Deployment1 = $Scenario_1_Xaml.findname("Run_Deployment1")
$Working_SC1 = $Scenario_1_Xaml.findname("Working_SC1")
$Task_SC1 = $Scenario_1_Xaml.findname("Task_SC1")
$Working_SC1 = $Scenario_1_Xaml.findname("Working_SC1")
$P1_SC1 = $Scenario_1_Xaml.findname("P1_SC1")
$C_P_SC1 = $Scenario_1_Xaml.findname("C_P_SC1")
$Check_PG_SC1 = $Scenario_1_Xaml.findname("Check_PG_SC1")
$P2_SC1 = $Scenario_1_Xaml.findname("P2_SC1")
$I_App_SC1 = $Scenario_1_Xaml.findname("I_App_SC1")
$Check_IA_SC1 = $Scenario_1_Xaml.findname("Check_IA_SC1")
$P3_SC1 = $Scenario_1_Xaml.findname("P3_SC1")
$C_Net_SC1 = $Scenario_1_Xaml.findname("C_Net_SC1")
$Check_Net_SC1 = $Scenario_1_Xaml.findname("Check_Net_SC1")
$P4_SC1 = $Scenario_1_Xaml.findname("P4_SC1")
$C_Meta_SC1 = $Scenario_1_Xaml.findname("C_Meta_SC1")
$Check_Met_SC1 = $Scenario_1_Xaml.findname("Check_Met_SC1")
$Export_SC1 = $Scenario_1_Xaml.findname("Export_SC1")


# Controls for Scenario_2 part
$NB_Compagnies = $Scenario_2_Xaml.findname("NB_Comp")
$Espace_disk_SC2 = $Scenario_2_Xaml.findname("Edisk_SC2")
$NB_Vlan_SC2 = $Scenario_2_Xaml.findname("NB_Vlan_SC2")
$Besoin_RAM_SC2 = $Scenario_2_Xaml.findname("B_Ram_SC2")
$Liste_Vlan_SC2 = $Scenario_2_Xaml.findname("Liste_Vlan_SC2")
$Check2 = $Scenario_2_Xaml.findname("Check2")
$Task_SC2 = $Scenario_2_Xaml.findname("Task_SC2")
$Working_SC2 = $Scenario_2_Xaml.findname("Working_SC2")
$P1_SC2 = $Scenario_2_Xaml.findname("P1_SC2")
$C_P_SC2 = $Scenario_2_Xaml.findname("C_P_SC2")
$Check_PG_SC2 = $Scenario_2_Xaml.findname("Check_PG_SC2")
$P2_SC2 = $Scenario_2_Xaml.findname("P2_SC2")
$I_App_SC2 = $Scenario_2_Xaml.findname("I_App_SC2")
$Check_IA_SC2 = $Scenario_2_Xaml.findname("Check_IA_SC2")
$P3_SC2 = $Scenario_2_Xaml.findname("P3_SC2")
$C_Net_SC2 = $Scenario_2_Xaml.findname("C_Net_SC2")
$Check_Net_SC2 = $Scenario_2_Xaml.findname("Check_Net_SC2")
$P4_SC2 = $Scenario_2_Xaml.findname("P4_SC2")
$C_Meta_SC2 = $Scenario_2_Xaml.findname("C_Meta_SC2")
$Check_Met_SC2 = $Scenario_2_Xaml.findname("Check_Met_SC2")
$Export_SC2 = $Scenario_2_Xaml.findname("Export_SC2")
$Run_Deployment2 = $Scenario_2_Xaml.findname("Run_Deployment2")

# Controls for Cleans part
$Nombre_Groupes_SC1 = $Cleans_Xaml.findname("NB_SC1")
$Nombre_Compagnies_SC2 = $Cleans_Xaml.findname("NB_SC2")
$Delete_PG_SC1 = $Cleans_Xaml.findname("DP_SC1")
$Delete_PG_SC2 = $Cleans_Xaml.findname("DP_SC2")
$clean_SC1 = $Cleans_Xaml.findname("Clean_1")
$clean_SC2 = $Cleans_Xaml.findname("Clean_2")

#########################################################################
#                        Variables                                      #
#########################################################################
$OVAFolder = $pathPanel +"\OVA"
$Appliance_Debian_Company =$OVAFolder +"\DEBIAN_TRANING_company.ova"
$Appliance_Debian_Trainer = $OVAFolder +"\DEBIAN_TRANING_trainer.ova"
$Appliance_SNS_Trainer = $OVAFolder +"\SNS_TRAINING_trainer.ova"
$Appliance_SNS_Company = $OVAFolder +"\SNS_TRAINING_company.ova"
$Appliance_RTR_StormShield = $OVAFolder +"\RTR_StormShield.ova"
$separator =", "
$list = New-Object System.Collections.ArrayList
$Global:Reseaux_SC1 = [ordered] @{
"LAN_DMZ1_A"= 1
"LAN_DMZ1_B"= 2
"LAN_FWS"= 3
"LAN_IN_A"= 4
"LAN_IN_B"= 5
"LAN_Gestion"= 6
"LAN_IN_TRAINER"= 7
}
$Global:Table = [ordered] @{
	"A"= 1
	"B"= 2
	"C"= 3
	"D"= 4
	"E"= 5
	"F"= 6
	"G"= 7
	"H"= 8
	"I"= 9
	"J"=10
	"K"=11
	"L"=12
	}
		
####Info Ressources Disk et Ram#######
#SC1
[INT]$SC1_Disque = "4,030"
[INT]$SC1_Ram = "3,700"
#SC2
[INT]$SC2_Disque = "1.2"
[INT]$SC2_Ram = "1.1"

$NB_Grp.Value="2"
$NB_Compagnies.Value="2"
$Nombre_Groupes_SC1.Value="2"
$Nombre_Compagnies_SC2.Value="2"
$verboseLogFile = "StormShieldWizard.log"
$Export_SC1.Visibility="Hidden"
$Export_SC2.Visibility="Hidden"
$Parametres.Visibility="Hidden"
$AutoLogin.Visibility="Hidden"
#########################################################################
#                       Functions       								#
#########################################################################
Function My-Logger {
    param(
    [Parameter(Mandatory=$true)]
    [String]$message
    )
	$logMessage = [System.Text.Encoding]::UTF8
    $timeStamp = Get-Date -Format "MM-dd-yyyy_hh:mm:ss"
	$logMessage = "[$timeStamp] $message"
	
    $logMessage | Out-File -Append -LiteralPath $verboseLogFile 
}

function Get-groups ($NBgroupe)
{
    $global:Groupes =[ordered] @{}

	for ($i = 1; $i -le $NBgroupe; $i++)
	{ 
		$VLAN = $i*10

		[String]$Name = "G"+ $i
		
		$global:Groupes.add($Name,$VLAN)

}}
function Get-Compagny ($groupes)
{
    $global:Company =[ordered] @{}
    $global:Reseaux_SC2 =[ordered] @{}
   
   #Contruction du Dictionnaire Company
   $Global:Table.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
    $IDVlan =$_.value
    $Letter = $_.Key
	
     if ($IDVlan -le $groupes ){
		 $Global:Company.add($Letter,$IDVlan)
		 
      }

  }

      $Global:Company.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
        [INT]$IDVlan =$_.value
        $Name = $_.Key

        [INT]$IDVlanf = [INT]$IDVlan*10
        [INT]$IDVlanf2 = $IDVlanf+1
        $global:Reseaux_SC2.add("LAN_IN_$Name",$IDVlanf)
        $global:Reseaux_SC2.add("LAN_DMZ1_$Name",$IDVlanf2)

    }

    $global:Reseaux_SC2.add("LAN_Gestion",130)
    $global:Reseaux_SC2.add("LAN_IN_TRAINER",131)
    $global:Reseaux_SC2.add("LAN_FWS",132)

}
function New-FileConfVlan ()
{

	param(

		[ValidateSet("SC1", "SC2")]
		$Scenario
	)

    My-Logger "##################################################"
    My-Logger "Create Two Files for Create and Delete Vlan"
    My-Logger "##################################################"

    $Date = Get-Date -DisplayHint Date
    $First= "### Configuration Cisco Create Vlan  ###"
    $First | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Create_Vlans_$Scenario.txt"
    $First= "### Scénario $Scenario StormShield $Date "
    $First | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Create_Vlans_$Scenario.txt"

    $Value = "config terminal"
    $Value | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Create_Vlans_$Scenario.txt"
    $Value ="!"
    $Value | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Create_Vlans_$Scenario.txt"

    $First= "### Configuration Cisco Remove Vlan  ###"
    $First | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Remove_Vlans_$Scenario.txt"
    $First= "### Scenario $Scenario StormShield $Date "
    $First | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Remove_Vlans_$Scenario.txt"

    $Value = "config terminal"
    $Value | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Remove_Vlans_$Scenario.txt"
    $Value ="!"
    $Value | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Remove_Vlans_$Scenario.txt"

    
}
function New-ConfVLan ()
{ 
	param(

		[ValidateSet("SC1", "SC2")]
		$Scenario
	)
    
    My-Logger "Add Vlan $Item to Files"
    $Data1 = "vlan "
    $Data2 = "name Storm_"

    $FirstLine = $Data1 + $item
    $FirstLine | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Create_Vlans_$Scenario.txt"
    $SecondLine = $Data2+$item
    $SecondLine | Out-File -Append -Encoding default -FilePath "$Global:pathPanel\Create_Vlans_$Scenario.txt"
    $Value ="!"
    $Value | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Create_Vlans_$Scenario.txt"

    $Data1 = "no vlan "

    $FirstLine = $Data1 + $item
    $FirstLine | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Remove_Vlans_$Scenario.txt"
    $Value ="!"
    $Value | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\Remove_Vlans_$Scenario.txt"

}
function New-FileFolder ()
{
	param(

		[ValidateSet("scenario1", "scenario2")]
		$Scenario,
		$NBgroupes,
		$NB_Compagnies
	)

    $Value = 'vm\StormShield\'
	$result = Test-Path -Path "$Global:pathPanel\$Scenario.txt"
	if ($result -eq $True)
	{
		Remove-Item -Path "$Global:pathPanel\$Scenario.txt"
	}
	if ($Scenario -eq "scenario1")
	{
		for ($i = 1; $i -le $NBgroupes; $i++)
			{ 
		
				$Data = $Value + "G$i"

				$Data | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\$Scenario.txt"

			}	
		}
		if ($Scenario -eq "scenario2")
		{
			 $Global:Table.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
             $IDVlan =$_.value
             $Letter = $_.Key
  
             if ($IDVlan -le $NB_Compagnies ){
				 $Data = $Value +"Compagnie_$Letter"
				 $Data | Out-File -Append -Encoding utf8 -FilePath "$Global:pathPanel\$Scenario.txt"
              }

        }
			}	
}
function New-FolderFromPath
{
	param
	(
	[Parameter(Mandatory=$true)]
	[String] $Path 
	)
  $splittedPaths = $Path.Split('\')

  $location = Get-Folder $splittedPaths[0] -ErrorAction Stop

  $splittedPaths[1..$splittedPaths.Length] | ForEach-Object {
    $nouveauDossier = Get-Folder -Name $_ -Location $location `
            -ErrorAction Ignore
    if($nouveauDossier -eq $null) { 
       # Write-Verbose "Création du répertoire $_"
        $nouveauDossier = New-Folder -Name $_ -Location $location
    }else{
        #Write-Warning "Le dossier $_ existe déjà"
    }
    $location = $nouveauDossier
  }
  
  return $nouveauDossier
}
function Get-CountNetwork ($Nbgroupes) 
{
  
	[INT]$Global:NBreseaux = ""
  
	if ([INT]$Nbgroupes -eq 2)
	{
		
		[INT]$Global:NBreseaux = 9
	
	}
	elseif([INT]$Nbgroupes -ne 2)
	{
		[INT]$Global:NBreseaux = (9 +(([INT]$Nbgroupes - 2)*3))
	}
	
}
function Test-AutoLogin  {
	
	My-Logger "#########################"
	My-Logger "# Autologin Search      #"
	My-Logger "#########################"
	$test = 0
	$AutoLogin.Visibility ="Visible"
	$KeyFile = $Global:pathPanel+"\"+"AES.key"
	$MgrCreds = $Global:pathPanel+"\"+"account_Creds.xml"
	
		If (Test-Path $KeyFile) {
		My-logger "AES Key is present"
		$test += 1
		My-logger "Continuing..."
		}
		If (Test-Path $MgrCreds) {
			My-logger "Account_Creds.xml is present"
			$test += 1
			My-logger "Continuing..."
		}
				
		if ($test -eq 2) {
			My-logger "All Files are present"
			$AutoLogin.Visibility ="Visible"
			My-Logger "Show Autologin Button"
			$SaveCred.Visibility = "Hidden"
				My-Logger "Hide Save Credential Button"
		}
		else {
			$AutoLogin.Visibility ="Hidden"
			My-Logger "Hidden Autologin Button"
		}


}
function Test-RegKey {
	[cmdletbinding()]
	Param(
		[Parameter(Position=0)]
		[System.String]$Path,
		
		[Parameter(Position=1)]
		[System.String]$Key
	)

    if ($Key.IsPresent)
    {

    (Test-Path $Path) -and  (Get-ItemProperty $Path).$Key
    }
    else
        {
        (Test-Path $Path)
        }
    }
function New-RegKeyProduct
 {
     [CmdletBinding()]
     Param
     (
                 
         [Parameter(Mandatory = $true)]
         [ValidateSet("JM2K69")]   
         [String]$Author,
         [ValidateSet("StormShield","PhotonOS","Docker")]
         [String]$Product,
         [ValidateSet("AES_Key_Hash")]
         [Parameter(Mandatory = $true)]
         [String]$Key,
         $Value

     )
 
     $test = Test-RegKey -Path HKCU:\Software\$Author\$Product -Key $key
     $testA = Test-RegKey -Path HKCU:\Software\$Author
    if ($test -eq $true)
    { }
    else
    {
       if ($testA -eq $true)
       {
            New-Item -Path HKCU:\Software\$Author -Name $Product |Out-Null
            New-ItemProperty -path HKCU:\Software\$Author\$Product -Name $key -Value $Value |Out-Null

       }
       else
       {    
            New-Item -Path HKCU:\Software -Name $Author |Out-Null
            New-Item -Path HKCU:\Software\$Author -Name $Product |Out-Null
            New-ItemProperty -path HKCU:\Software\$Author\$Product -Name $key -Value $Value |Out-Null
        }

    }
    
        
    
 }
 function Read-RegKeyProduct
 {
     [CmdletBinding()]
     Param
     (
         [Parameter(Mandatory = $true)]
         [ValidateSet("JM2K69")]   
         [String]$Author,
         [ValidateSet("StormShield","PhotonOS","Docker")]
         [String]$Product,
         [ValidateSet("AES_Key_Hash")]
         [Parameter(Mandatory = $true)]
         [String]$Key
         

     )
 
     $test = Test-RegKey -Path HKCU:\Software\$Author\$Product -Key $key
     
    if ($test -eq $true)
        { 
            $AESKey = (Get-ItemProperty -Path HKCU:\Software\$Author\$Product\ -Name $Key).AES_Key_Hash
            return  $AESKey
        }
    else
        {
            write-warning "Key not found" 
        }
    
 }
function Remove-RegKeyProduct
 {
     [CmdletBinding()]
     Param
     (
         [Parameter(Mandatory = $true)]
         [ValidateSet("JM2K69")]   
         [String]$Author,
         [ValidateSet("StormShield","PhotonOS","Docker")]
         [String]$Product,
         [ValidateSet("AES_Key_Hash")]
         [Parameter(Mandatory = $true)]
         [String]$Key
         

     )
 
     $test = Test-RegKey -Path HKCU:\Software\$Author\$Product -Key $key

    if ($test -eq $true)
        { 
            Remove-ItemProperty -Path HKCU:\Software\$Author\$Product\ -Name $Key
            Remove-Item -Path HKCU:\Software\$Author\$Product
        }
    
 }

#########################################################################
#                        Controls                                       #
#########################################################################
$TabMenuHamburger.add_ItemClick({  
	$TabMenuHamburger.Content = $TabMenuHamburger.SelectedItem
	$TabMenuHamburger.IsPaneOpen = $false	
	 	 
 })		
$SaveCred.add_Click({
	My-Logger "#########################"
	My-Logger "# Save Credential       #"
	My-Logger "#########################"

	##Create Secure AES Keys for User and Password Management
$KeyFile = $Global:pathPanel+"\"+"AES.key"
If (Test-Path $KeyFile){
My-logger "AES File Exists"
$Key = Get-Content $KeyFile
My-logger "Continuing..."
}
Else {
$Key = New-Object Byte[] 16   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile
$hash=Get-FileHash $KeyFile
New-RegKeyProduct -Author JM2K69 -Product StormShield -Key AES_Key_Hash -Value $hash.hash

}

	

	$MgrCreds = $Global:pathPanel+"\"+"account_Creds.xml"
	If (Test-Path $MgrCreds){
	My-Logger "account_Creds.xml file found"
	My-logger "Continuing..."
	$ImportObject = Import-Clixml $MgrCreds
	$SecureString = ConvertTo-SecureString -String $ImportObject.Password -Key $Key
	$UserName = $ImportObject.UserName.Split("#")[0]
	$Global:vcenter = $ImportObject.UserName.Split("#")[1]
	$MyCredential = New-Object System.Management.Automation.PSCredential($UserName, $SecureString)
	}
	Else {
	
	$Global:vcenter = $Host_Connection.text.tostring()
	$Global:User= $Utilisateur.text.tostring()
	$Global:pass_value = $PasswordBox.password.tostring()
	$Password = $Global:pass_value | ConvertTo-SecureString -AsPlainText -Force
	
	
	$exportObject = New-Object psobject -Property @{
		UserName = $Global:User+"#"+$Global:vcenter
		Password = ConvertFrom-SecureString -SecureString $password -Key $Key
	}

	$exportObject | Export-Clixml $MgrCreds
	$MyCredential = $newPScreds
	}
	$SaveCred.Visibility = "Hidden"
	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Sauvegarde","Les donnees de connections ont bien ete sauvegardees.." )

})
	$AutoLogin.add_Click({

		My-Logger "##################"
		My-Logger "#   Autologin  #"
		My-Logger "##################"
		$EndFuntion = $false
		try 
		{
			$FindKey = Test-RegKey  -Path HKCU:\Software\JM2K69\StormShield -Key AES_Key_Hash
			if ($FindKey -eq $false)
			{
				$EndFuntion = $true
				Remove-Item "$Global:pathPanel\AES.key" -Force | Out-Null
				Remove-Item $MgrCreds -Force | Out-Null

			}
			$readOriginalAES = Read-RegKeyProduct -Author JM2K69 -Product StormShield -Key AES_Key_Hash 
			$HashRead = Get-FileHash "$Global:pathPanel\AES.key"
			

			if($readOriginalAES -eq $HashRead) 
			{
				$Key = Get-Content  "$Global:pathPanel\AES.key"
				$EndFuntion = $false
			}
			else
			{
				$EndFuntion = $true
				Remove-Item "$Global:pathPanel\AES.key" -Force | Out-Null
				Remove-RegKeyProduct -Author JM2K69 -Product StormShield -Key AES_Key_Hash
				Remove-Item $MgrCreds -Force | Out-Null
			}
	}
	catch{}

		$MgrCreds = $Global:pathPanel+"\"+"account_Creds.xml"
		If (Test-Path $MgrCreds){
		My-Logger "account_Creds.xml file found"
		
		$ImportObject = Import-Clixml $MgrCreds
		
		try
			{
				
				$SecureString = ConvertTo-SecureString -String $ImportObject.Password -Key $Key -WarningAction SilentlyContinue
				
			}
		catch
			{
				Remove-Item $MgrCreds -Force | Out-Null
				Remove-Item "$Global:pathPanel\AES.key" -Force | Out-Null
				Remove-RegKeyProduct -Author JM2K69 -Product StormShield -Key AES_Key_Hash
				[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Erreur","Les donnees ont ete alterees : Autologin Impossible. Par mesure de securite les donnees ont ete detruites." )
				$EndFuntion = $true
				$AutoLogin.Visibility ="Hidden"
				My-Logger "Hidden Autologin Button"
				$SaveCred.Visibility = "Visible"
				My-Logger "Show Save Credential Button"
			}
				
		if ($EndFuntion -eq $false)
		{
			$UserName = $ImportObject.UserName.Split("#")[0]
			$Global:vcenter = $ImportObject.UserName.Split("#")[1]
			$MyCredential = New-Object System.Management.Automation.PSCredential($UserName, $SecureString)
		
			Connect-VIServer -Server $Global:vcenter -Credential $MyCredential

			if ( $Global:DefaultVIServer[0].name -ne $null) 
			{
				$vCenter = $Global:DefaultVIServer[0].name
				My-Logger "Connection successfull to vCenter $vCenter "
				$Parametres.Visibility="Visible"
				$Status_Connection_Info.Content = "Connect"
				$Status_Connection_Info.Foreground ="Green"

				$Icon_NC.Visibility="1"
				$Icon_C.Visibility="0"

				[System.Windows.Forms.Application]::DoEvents()
				[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Connection","Vous etes connectez au vCenter $Global:vcenter vous devez maintenant definir les parametres, DataStore, vSwitch et PortGroup permettant d'acceder a Internet. " )
				[System.Windows.Forms.Application]::DoEvents()

			}
			else {
				$Status_Connection_Info.Content = " Not Connected"
				$Status_Connection_Info.Foreground ="Red"
			}

			$InfoDataStore = Get-Datastore
			$InfovSwitch = Get-VirtualSwitch
			$Info_Internet = Get-VirtualPortGroup

			foreach ($data in $InfoDataStore)
			{
				My-Logger "Find the DataStore : $data "
				$Datastore_values = New-Object PSObject
				$Datastore_values = $Datastore_values | Add-Member NoteProperty Name $data.Name -passthru
				$FreeSpace =  [math]::Round(( $data.FreeSpaceGB),2)
				$Datastore_values = $Datastore_values | Add-Member NoteProperty FreeSpaceGB $FreeSpace -passthru	
				$Datastore_values = $Datastore_values | Add-Member NoteProperty CapacityGB $data.CapacityGB -passthru	
				$DataGrid_Datastore.Items.Add($Datastore_values) > $null
				
			}
			foreach ($data in $InfovSwitch)
			{
				My-Logger "Find the vSwitch : $data "
				$vSwitch_values = New-Object PSObject
				$vSwitch_values = $vSwitch_values | Add-Member NoteProperty Name $data.Name -passthru
				$vSwitch_values = $vSwitch_values | Add-Member NoteProperty MTU $data.MTU -passthru	
				$DataGrid_vSwitch.Items.Add($vSwitch_values) > $null

			}
			foreach ($data in $Info_Internet)
			{
				My-Logger "Find the PortGroup : $data "
				$PortGroup_values = New-Object PSObject
				$PortGroup_values = $PortGroup_values | Add-Member NoteProperty Name $data.Name -passthru
				$PortGroup_values = $PortGroup_values | Add-Member NoteProperty VlanId $data.VlanId -passthru	
				$DataGrid_Network.Items.Add($PortGroup_values) > $null

			}

		}
	}

	})


 $Connection_vCenter.add_Click({

	My-Logger "#########################"
	My-Logger "# Connection  To vCenter #"
	My-Logger "#########################"

	$Global:vcenter = $Host_Connection.text.tostring()
	$Global:User= $Utilisateur.text.tostring()
	$Global:pass_value = $PasswordBox.password.tostring()

	My-Logger "User : $Global:User "
	My-Logger "Password : *********  Remove for security"


	$VIcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:User, ($Global:pass_value | ConvertTo-SecureString -AsPlainText -Force)
		Try
		{
			Connect-VIServer $Global:vcenter -Credential $VIcred -WarningAction SilentlyContinue 

			if ( $Global:DefaultVIServer[0].name -ne $null) 
			{
				$vCenter = $Global:DefaultVIServer[0].name
				My-Logger "Connection successfull to vCenter $vCenter "
				$Parametres.Visibility="Visible"
				$Status_Connection_Info.Content = "Connect"
				$Status_Connection_Info.Foreground ="Green"

				$Icon_NC.Visibility="1"
				$Icon_C.Visibility="0"

				[System.Windows.Forms.Application]::DoEvents()
				[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Connection","Vous etes connectez au vCenter $Global:vcenter vous devez maintenant definir les parametres, DataStore, vSwitch et PortGroup permettant d'acceder a Internet. " )
				[System.Windows.Forms.Application]::DoEvents()

			}
			else {
				$Status_Connection_Info.Content = " Not Connected"
				$Status_Connection_Info.Foreground ="Red"
			}

		$InfoDataStore = Get-Datastore
		$InfovSwitch = Get-VirtualSwitch
		$Info_Internet = Get-VirtualPortGroup

				foreach ($data in $InfoDataStore)
				{
					My-Logger "Find the DataStore : $data "
					$Datastore_values = New-Object PSObject
					$Datastore_values = $Datastore_values | Add-Member NoteProperty Name $data.Name -passthru
					$FreeSpace =  [math]::Round(( $data.FreeSpaceGB),2)
					$Datastore_values = $Datastore_values | Add-Member NoteProperty FreeSpaceGB $FreeSpace -passthru	
					$Datastore_values = $Datastore_values | Add-Member NoteProperty CapacityGB $data.CapacityGB -passthru	
					$DataGrid_Datastore.Items.Add($Datastore_values) > $null
					
				}
				foreach ($data in $InfovSwitch)
				{
					My-Logger "Find the vSwitch : $data "
					$vSwitch_values = New-Object PSObject
					$vSwitch_values = $vSwitch_values | Add-Member NoteProperty Name $data.Name -passthru
					$vSwitch_values = $vSwitch_values | Add-Member NoteProperty MTU $data.MTU -passthru	
					$DataGrid_vSwitch.Items.Add($vSwitch_values) > $null

				}
				foreach ($data in $Info_Internet)
				{
					My-Logger "Find the PortGroup : $data "
					$PortGroup_values = New-Object PSObject
					$PortGroup_values = $PortGroup_values | Add-Member NoteProperty Name $data.Name -passthru
					$PortGroup_values = $PortGroup_values | Add-Member NoteProperty VlanId $data.VlanId -passthru	
					$DataGrid_Network.Items.Add($PortGroup_values) > $null

				}

		}
		Catch
		{
			[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Erreur","Impossible de connecter au vCenter $Global:vcenter avec le couple identifiant / mot de passe. " )
		}
			
	

})
$Disconnect_vCenter.add_Click({

	Disconnect-VIServer -Server $Global:vcenter -Force
	My-Logger "You are disconeted form vCenter $Global:vcenter.."
	$Parametres.Visibility="Hidden"

	$Icon_NC.Visibility="0"
	$Icon_C.Visibility="1"

	[System.Windows.Forms.Application]::DoEvents()
	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Deconnection","Vous etes deconnecter du vCenter $Global:vcenter. " )
	[System.Windows.Forms.Application]::DoEvents()


})

$Parametres.add_Click({



	If ($DataGrid_Datastore.SelectedIndex -ne "-1"){

		
		ForEach ($Global:Appli in $DataGrid_Datastore.SelectedItems)
						{						
							
						$Global:My_Values = New-Object -TypeName PSObject -Property @{Name = $Global:Appli.Name} 
										$Global:appli_values = $My_Values | Select-Object Name
										$Global:Name = $appli_values.Name
										$Global:Datastore = $Global:Name						
										My-Logger "The Datastore is set to : $Global:Datastore"
									 #[System.Windows.Forms.MessageBox]::Show($Global:Datastore)									
								
						}


	}

	If ($DataGrid_Network.SelectedIndex -ne "-1"){

		
		ForEach ($Global:Item in $DataGrid_Network.SelectedIndex)
						{						
							
							$Global:My_Net = New-Object -TypeName PSObject -Property @{Name = $DataGrid_Network.SelectedValue} 
							$Global:Net_values = $Global:My_Net | Select-Object Name
							$test= $Global:Net_values.name | Select-Object Name
							$Global:Internet = $test.name					
							My-Logger "The Portgroup for Internet is set to : $Global:Internet"

						 #[System.Windows.Forms.MessageBox]::Show($Global:Internet)									
					
			}

		
	}

	If ($DataGrid_vSwitch.SelectedIndex -ne "-1"){

		
		ForEach ($Global:switch in $DataGrid_vSwitch.SelectedItems)
						{						
							
						$Global:My_sw = New-Object -TypeName PSObject -Property @{Name = $Global:switch.Name} 
						$Global:switch_values = $My_sw | Select-Object Name
										$Global:Name = $switch_values.Name
										$Global:vSwitch_F = $Global:Name						
										My-Logger "The vSwitch is set to : $Global:vSwitch_F"
									 #[System.Windows.Forms.MessageBox]::Show($Global:vSwitch_F)									
								
						}
	}
	
	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Parametres","Vous avez bien appliquez les parametres. " )


})

$Check1.add_Click({
	
	My-Logger "#########################"
	My-Logger "# Check Scenario 1      #"
	My-Logger "#########################"


	$ListeVlan =""
	$Liste_Vlan_SC1.Content = ""
	$Global:list = New-Object System.Collections.ArrayList
	Get-groups -NBgroupe $NB_Grp.value

	 $xvlan = $global:Groupes.Count * $Global:Reseaux_SC1.Count

	$global:Groupes.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
		[INT]$Vlan = $_.Value
		$Global:Reseaux_SC1.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
			[INT]$Vlanr = $_.Value
		[int]$VlanFinal = [INT]$Vlan + [INT]$Vlanr
		
		$Global:list.Add($VlanFinal)|Out-Null
		}
	}
	$ListeVlan = [string]::Join($separator,$Global:list,0,$Global:list.count)	
	My-Logger "All this Vlan must be created $ListeVlan"
	
	
	$NB_Vlan.Content = $xvlan

	$Liste_Vlan_SC1.Content = $ListeVlan

	$Value_Disk =  [math]::Round(( $NB_Grp.value * $SC1_Disque)/1024,2)
	$Value_Ram =  [math]::Round(( $NB_Grp.value * $SC1_Ram)/1024,2)
	$Espace_disk_SC1.Content = " $Value_Disk GB"
	$Besoin_RAM_SC1.Content = "$Value_Ram GB"

	My-Logger "We need  $Value_Disk GB  free space in your DataStore"
	My-Logger "We need  $Value_Ram GB  free in RAM"
	$Export_SC1.Visibility="Visible"
	$Task_SC1.IsExpanded="True"
})

$Export_SC1.add_Click({
	
	My-Logger "Create files for Vlan configuration."
	New-FileConfVlan -Scenario SC1

	foreach ($item in $Global:list)
	{
		
		New-ConfVLan -Scenario SC1
	
	}


})

$Check2.add_Click({
	
	My-Logger "#########################"
	My-Logger "# Check Scenario 2      #"
	My-Logger "#########################"

	$ListeVlan_2 =""
	$Liste_Vlan_SC2.Content = ""
	$Global:list = New-Object System.Collections.ArrayList
	
	Get-Compagny -groupes $NB_Compagnies.value
	Get-CountNetwork -Nbgroupes $NB_Compagnies.value
	
		 $global:Reseaux_SC2.GetEnumerator()| Sort-Object -Property Value | Foreach-Object {
		 $IdVlan =$_.value
		 
		 $Global:list.Add($IdVlan)|Out-Null
		}


		$ListeVlan_2 = [string]::Join($separator,$Global:list,0,$Global:list.count)	
	My-Logger "All this Vlan must be created $ListeVlan_2"

	
	$NB_Vlan_SC2.Content = $Global:NBreseaux

	$Liste_Vlan_SC2.Content = $ListeVlan_2
 
	$Value_Disk =  [math]::Round(( $NB_Compagnies.value * $SC2_Disque),2)
	$Value_Ram =  [math]::Round(( $NB_Compagnies.value* $SC2_Ram),2)
	$Espace_disk_SC2.Content = " $Value_Disk GB"
	$Besoin_RAM_SC2.Content = "$Value_Ram GB"

	My-Logger "We need  $Value_Disk GB  free space in your DataStore"
	My-Logger "We need  $Value_Ram GB  free in RAM"
	$Export_SC2.Visibility="Visible"
	$Task_SC2.IsExpanded="True"

})

$Export_SC2.add_Click({

	My-Logger "Create files for Vlan configuration."

	New-FileConfVlan -Scenario SC2

	foreach ($item in $Global:list)
	{
		
		New-ConfVLan -Scenario SC2
	
	}

})


$Run_Deployment1.add_Click({

	My-Logger "####################################"
	My-Logger "# Starting deployment Scenario 1   #"
	My-Logger "####################################"


	$okAndCancel = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
	# show ok/cancel message
	$result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Accept","Voulez-vous demarrer le deploiement du Scenario 1. ",$okAndCancel)


If ($result -eq "Affirmative"){ 

	
	$StartTime = Get-Date
	My-Logger "The Deployment start at $StartTime" 


	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Demarrage","Le deploiement du scenario 1 a commence a $StartTime ." )
	
	$Working_SC1.Visibility = "0"

	New-FileFolder -NBgroupes $global:Groupes.count -Scenario scenario1
	My-logger "Create vSphere Directory"
	My-Logger "Used the File $Global:pathPanel\scenario1.txt"
	Get-Content "$Global:pathPanel\scenario1.txt" | ForEach-Object {New-FolderFromPath -Path $_}
		

	$Global:VMHost = Get-VMHost
	  
	  [System.Windows.Forms.Application]::DoEvents()
 
	foreach ($item in $Global:VMHost.Name)
	  {
		[System.Windows.Forms.Application]::DoEvents()
		$P1_SC1.Visibility="0"
		$C_P_SC1.Visibility="0"

		$virtualSwitch = Get-VirtualSwitch -VMHost $item -Name $Global:vSwitch_F 
	  
				  $global:Groupes.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
				  $Global:name  = $_.Key
				  [INT]$Vlan = $_.Value
	  
				  $Global:Reseaux_SC1.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
				  $namer  = $_.Key
				  [INT]$Vlanr = $_.Value
	  
				  $nameFinal = $Global:name +"_$namer"
				  [int]$VlanFinal = [INT]$Vlan + [INT]$Vlanr
				$SW =  new-VirtualPortGroup -VirtualSwitch $virtualSwitch -Name "$nameFinal" -VLanId $VlanFinal 
				My-Logger "Create the Virtual PortGroup $nameFinal with the Vlan $VlanFinal in the vSwitch with the name $virtualSwitch" 

				  }
				  }
	  
	  }
	 
	  $Check_PG_SC1.Visibility="0"
	
	$global:Groupes.Keys | ForEach-Object{
	$P2_SC1.Visibility="0"
	$I_App_SC1.Visibility="0"
					$Global:name = '{0}' -f $_
					[INT]$Vlan = '{1}'-f $_, $global:Groupes[$_]

					$Working_SC1.Content = "Deploiement en cours du groupe $Global:name"
					My-Logger "Deploy the VM for the group $Global:name" 
 
					$Check_IA_SC1.Visibility="1"
					$Check_Net_SC1.Visibility="1"
					$Check_Met_SC1.Visibility="1"
		[System.Windows.Forms.Application]::DoEvents()
			$vm_A_Debian = Import-VApp -Source $Appliance_Debian_Company  -Name "$Global:name`_Debian_training_A"  -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin   -Force
			My-Logger "Deploy the VM $Global:name`_Debian_training_A" 
			
		[System.Windows.Forms.Application]::DoEvents()
			$vm_B_Debian = Import-VApp -Source $Appliance_Debian_Company  -Name "$Global:name`_Debian_training_B"  -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin -Force
			My-Logger "Deploy the VM $Global:name`_Debian_training_B" 
			[System.Windows.Forms.Application]::DoEvents()
			$vm_A_SNS_Company = Import-VApp -Source $Appliance_SNS_Company  -Name "$Global:name`_SNS_Company_A"  -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin -Force
			My-Logger "Deploy the VM $Global:name`_SNS_Company_A" 
			[System.Windows.Forms.Application]::DoEvents()	
		$vm_B_SNS_Company = Import-VApp -Source $Appliance_SNS_Company  -Name "$Global:name`_SNS_Company_B" -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin  -Force
		My-Logger "Deploy the VM $Global:name`_SNS_Company_B"
		[System.Windows.Forms.Application]::DoEvents()
			$vm_Trainer_Debian = Import-VApp -Source $Appliance_Debian_Trainer  -Name "$Global:name`_Debian_trainer" -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin -Force
			My-Logger "Deploy the VM $Global:name`_Debian_trainer"
			[System.Windows.Forms.Application]::DoEvents()
			$vm_SNS_Trainer = Import-VApp -Source $Appliance_SNS_Trainer  -Name "$Global:name`_SNS_trainer"  -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin  -Force
			My-Logger "Deploy the VM $Global:name`_SNS_trainer"
			$vm_RTR = Import-VApp -Source $Appliance_RTR_StormShield  -Name "$Global:name`_RTR_StormShield"  -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin  -Force
			My-Logger "Deploy the VM $Global:name`_RTR_StormShield"
			$ToMove = Get-VM -Name "$Global:name`*"

				foreach ($item in $ToMove.name) 
				{
					Move-VM $item -InventoryLocation $Global:name
				}

			$Check_IA_SC1.Visibility="0"
			My-Logger "Import Appliance for The Group  $Global:name is finished"
		[System.Windows.Forms.Application]::DoEvents()	
			$P3_SC1.Visibility="0"
			My-Logger "Starting configure network for the group $Global:name"

			$C_Net_SC1.Visibility="0"
  			Get-VM -Name "$Global:name`_Debian_training_A"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_IN_A" -Confirm:$false   |Out-Null
			Get-VM -Name "$Global:name`_Debian_training_B"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_IN_B" -Confirm:$false      |Out-Null
			Get-VM -Name "$Global:name`_Debian_trainer"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_IN_TRAINER" -Confirm:$false     |Out-Null
			[System.Windows.Forms.Application]::DoEvents()

			Get-VM -Name "$Global:name`_SNS_Company_A"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_FWS" -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_SNS_Company_A"| Get-NetworkAdapter -Name "Network adapter 2" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_IN_A" -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_SNS_Company_A"| Get-NetworkAdapter -Name "Network adapter 3" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_DMZ1_A" -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_SNS_Company_A"| Get-NetworkAdapter -Name "Network adapter 4" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_Gestion" -Confirm:$false     |Out-Null
			[System.Windows.Forms.Application]::DoEvents()
			
			Get-VM -Name "$Global:name`_SNS_Company_B"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_FWS" -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_SNS_Company_B"| Get-NetworkAdapter -Name "Network adapter 2" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_IN_B" -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_SNS_Company_B"| Get-NetworkAdapter -Name "Network adapter 3" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_DMZ1_B" -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_SNS_Company_B"| Get-NetworkAdapter -Name "Network adapter 4" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_Gestion" -Confirm:$false     |Out-Null
			[System.Windows.Forms.Application]::DoEvents()
			
			Get-VM -Name "$Global:name`_SNS_trainer"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_FWS" -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_SNS_trainer"| Get-NetworkAdapter -Name "Network adapter 2" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_IN_TRAINER" -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_SNS_trainer"| Get-NetworkAdapter -Name "Network adapter 3" | Set-NetworkAdapter -NetworkName "$Global:name`_LAN_Gestion" -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_SNS_trainer"| Get-NetworkAdapter -Name "Network adapter 4" | Set-NetworkAdapter -NetworkName $Internet -Confirm:$false     |Out-Null
			[System.Windows.Forms.Application]::DoEvents()

			Get-VM -Name "$Global:name`_RTR_StormShield"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName $Internet -Confirm:$false     |Out-Null
			Get-VM -Name "$Global:name`_RTR_StormShield"| Get-NetworkAdapter -Name "Network adapter 2" | Set-NetworkAdapter -NetworkName  "$Global:name`_LAN_Gestion" -Confirm:$false     |Out-Null
			
			My-Logger "Network configuration for the group $Global:name is finished"

			$Check_Net_SC1.Visibility="0"
			$P4_SC1.Visibility="0"
			$C_Meta_SC1.Visibility="0"
			My-Logger "Add Tag for All objects for the group $Global:name "

			[System.Windows.Forms.Application]::DoEvents()
			$code =@'
			
				Connect-VIServer -Server #Host# -User #User# -Password #Password# -WarningAction SilentlyContinue
			
				$Cat = "StormShield"
			$TagVM = @("Scenario1","Scenario2")
			foreach ($Name in $Cat){
				
				if (-Not(Get-TagCategory -Name $Name -ErrorAction SilentlyContinue)) 
				{
				Write-Host -ForegroundColor Green "The Cat $Cat is created"
				New-TagCategory -Name $Name | Out-Null
				}  
			
				#Create Tag if it doesnt exist 
				$UniqueTag = $TagVM | Get-Unique
				foreach ($I in $UniqueTag) 
				{
				if (-Not(Get-Tag $I -ErrorAction SilentlyContinue)) 
				{
					Write-Host -ForegroundColor Green "The Tag $I is created under the Cat $Name"
					New-Tag -Name $I -Cat $Cat | Out-Null
				}  
				}
	  
	  			}

				$vms = Get-VM #Name#*
				##Write-Host $vms
				$Tagf="Scenario1"
				$vms | New-TagAssignment -Tag $Tagf
				
				$Net=Get-VirtualPortGroup -VirtualSwitch #vSwitch#
				$net | New-TagAssignment -Tag $Tagf

'@
		$codef = $code.Replace('#Host#', $Global:vcenter).Replace('#User#',$Global:User).Replace('#Password#',$Global:pass_value).Replace('#Name#',$Global:name).Replace('#vSwitch#',$Global:vSwitch_F)
		
		
				$PowerShell = [PowerShell]::Create().AddScript($codef)
				$job = $PowerShell.BeginInvoke()
				While (-Not $job.IsCompleted) {}
							
				
				$PowerShell.Dispose()
				My-Logger "All objects are already tag for the group $Global:name "

                $Check_Met_SC1.Visibility="0"
	
		}		
			

			
	$EndTime = Get-Date
	$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,0)
	My-Logger "the deployment lasted $duration minutes #"	

	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Terminez","Le deploiement du scenario 1 est termine. Il a dure $duration minutes." )
	My-Logger "####################################"
	My-Logger "# End Deployment Scenario 1       #"
	My-Logger "####################################"

}


	else{

	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Annulation","Vous pouvez encore modifier des paramètres." )
	My-Logger "####################################"
	My-Logger "# Cancled Deployment Scenario 1    #"
	My-Logger "####################################"


}

})
$clean_SC1.add_Click({
    

	$okAndCancel = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
	# show ok/cancel message
	$result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Accept","Voulez-vous Netttoyer le Scenario 1. (VM et Portgroup) ",$okAndCancel)

	If ($result -eq "Affirmative"){ 
	
		My-Logger "####################################"
		My-Logger "# Starting Clean Scenario 1       #"
		My-Logger "####################################"

            
            $ListeVlan =""
	
			$Global:list = New-Object System.Collections.ArrayList
	    Get-groups -NBgroupe $NB_SC1.value
       
	     $xvlan = $global:Groupes.Count * $Global:Reseaux_SC1.Count

	    $global:Groupes.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
		[INT]$Vlan = $_.Value
		$Global:Reseaux_SC1.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
			[INT]$Vlanr = $_.Value
		[int]$VlanFinal = [INT]$Vlan + [INT]$Vlanr
		
			$Global:list.Add($VlanFinal)|Out-Null
		}
	}
	$ListeVlan = [string]::Join($separator,$Global:list,0,$Global:list.count)	

			$StartTime = Get-Date

			$Global:VMHost = Get-VMHost
			          			
			foreach ($item in $Global:VMHost.Name)
	  {
		
		
		$virtualSwitch = Get-VirtualSwitch -VMHost $item -Name $Global:vSwitch_F 
	            
               
                   $SW= get-VirtualPortGroup -VirtualSwitch $virtualSwitch -Tag "Scenario1"
					 
					Remove-VirtualPortGroup -VirtualPortGroup $SW -Confirm:$false
				   My-Logger "Remove the PortGroup : $SW "

		    		
	    }
	
			$Tagf = "Scenario1"
			$VM = Get-VM | Get-TagAssignment |where{$_.Tag -like "StormShield/$Tagf"} |Select @{N='VM';E={$_.Entity.Name}}
			
			foreach ($item in $VM.VM) {
				try 
			{

				remove-vm $Item -DeleteFromDisk -Confirm:$false |Out-Null
				My-Logger "The VM  $Item  is deleted"

			}
			catch{}
			finally
			{
				

			}
			}

			$EndTime = Get-Date
			$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
			My-Logger "Cleaning phase with duration $duration minutes"

			
			[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Nettoyage Terminez","Le nettoyage du scenario 1 est termine. Il a dure $duration minutes." )

	}
	else
	 {
		[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Abandon","Le nettoyage du scenario 1 a ete annule." )
		My-Logger "####################################"
		My-Logger "# Cancel Clean Scenario 1       #"
		My-Logger "####################################"
	
	}	
})

$Run_Deployment2.add_Click({

	My-Logger "####################################"
	My-Logger "# Starting deployment Scenario 2   #"
	My-Logger "####################################"


	$okAndCancel = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
	# show ok/cancel message
	$result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Accept","Voulez-vous demarrer le deploiement du Scenario 2. ",$okAndCancel)

	If ($result -eq "Affirmative")
		{
			$StartTime = Get-Date
			My-Logger "The Deployment  start at $StartTime" 
				
			[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Demarrage","Le deploiement du scenario 2 a commence a $StartTime ." )
			
			$Working_SC2.Visibility = "0"
			
			New-FileFolder -NB_Compagnies $NB_Compagnies.value -Scenario scenario2
			
			My-logger "Create vSphere Directory"
			My-Logger "Used the File $Global:pathPanel\scenario2.txt"
			Get-Content "$Global:pathPanel\scenario2.txt" | ForEach-Object {New-FolderFromPath -Path $_}
		
			$Global:VMHost = Get-VMHost
	  
	  		[System.Windows.Forms.Application]::DoEvents()
 
			foreach ($item in $Global:VMHost.Name)
			{
				[System.Windows.Forms.Application]::DoEvents()
				$P1_SC2.Visibility="0"
				$C_P_SC2.Visibility="0"

				$virtualSwitch = Get-VirtualSwitch -VMHost $item -Name $Global:vSwitch_F 
	  
	  
				  $Global:Reseaux_SC2.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
				  $name  = $_.Key
				  [INT]$Vlan = $_.Value
	  			
				$SW =  new-VirtualPortGroup -VirtualSwitch $virtualSwitch -Name "$name" -VLanId $Vlan 
				My-Logger "Create the Virtual PortGroup $name with the Vlan $Vlan in the vSwitch with the name $virtualSwitch" 

				}
				  
	  
	  		}
			  $Check_PG_SC2.Visibility="0"

			  $Working_SC2.Content = "Importations des VM Trainer"
		[System.Windows.Forms.Application]::DoEvents()
		$vm_Trainer_Debian = Import-VApp -Source $Appliance_Debian_Trainer  -Name "Debian_trainer" -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin -Force
		My-Logger "Deploy the VM Debian_trainer"
		[System.Windows.Forms.Application]::DoEvents()
		$vm_SNS_Trainer = Import-VApp -Source $Appliance_SNS_Trainer  -Name "SNS_trainer"  -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin  -Force
		My-Logger "Deploy the VM SNS_trainer"
		
		$vm_RTR = Import-VApp -Source $Appliance_RTR_StormShield  -Name "RTR_StormShield"  -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin  -Force
		My-Logger "Deploy the VM RTR_StormShield"

		My-Logger "Configure Network for the VM SNS_trainer"
		[System.Windows.Forms.Application]::DoEvents()
		Get-VM -Name "SNS_trainer"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "LAN_FWS" -Confirm:$false     |Out-Null
		Get-VM -Name "SNS_trainer"| Get-NetworkAdapter -Name "Network adapter 2" | Set-NetworkAdapter -NetworkName "LAN_IN_TRAINER" -Confirm:$false     |Out-Null
		Get-VM -Name "SNS_trainer"| Get-NetworkAdapter -Name "Network adapter 3" | Set-NetworkAdapter -NetworkName "LAN_Gestion" -Confirm:$false     |Out-Null
		Get-VM -Name "SNS_trainer"| Get-NetworkAdapter -Name "Network adapter 4" | Set-NetworkAdapter -NetworkName $Global:Internet -Confirm:$false     |Out-Null
		[System.Windows.Forms.Application]::DoEvents()
		My-Logger "Configure Network for the VM Debian_trainer"
		Get-VM -Name "Debian_trainer"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "LAN_IN_TRAINER" -Confirm:$false     |Out-Null

		Get-VM -Name "RTR_StormShield"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName $Global:Internet -Confirm:$false     |Out-Null
		Get-VM -Name "RTR_StormShield"| Get-NetworkAdapter -Name "Network adapter 2" | Set-NetworkAdapter -NetworkName "LAN_Gestion" -Confirm:$false     |Out-Null

		My-Logger "Network configuration For Trainer is finished"

		[System.Windows.Forms.Application]::DoEvents()
		$Global:Company.Keys | ForEach-Object{
			[System.Windows.Forms.Application]::DoEvents()
			$P2_SC2.Visibility="0"
			$I_App_SC2.Visibility="0"
							$Global:name = '{0}' -f $_
								
							$Working_SC2.Content = "Deploiement en cours de la Compagnie $Global:name"
							My-Logger "Deploy the VM for the Compagny $Global:name" 
		
							$Check_IA_SC2.Visibility="1"
							$Check_Net_SC2.Visibility="1"
							$Check_Met_SC2.Visibility="1"

							[System.Windows.Forms.Application]::DoEvents()
							$vm_Debian = Import-VApp -Source $Appliance_Debian_Company  -Name "Debian_training_$Global:name"  -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin   -Force
							My-Logger "Deploy the VM Debian_training_$Global:name" 

							$vm_A_SNS_Company = Import-VApp -Source $Appliance_SNS_Company  -Name "SNS_Company_$Global:name"  -VMHost $vmhost[0] -Datastore $Global:datastore -DiskStorageFormat thin -Force
							My-Logger "Deploy the VM SNS_Company_$Global:name" 
							[System.Windows.Forms.Application]::DoEvents()	
							$Check_IA_SC2.Visibility="0"
							$P3_SC2.Visibility="0"
							$C_Net_SC2.Visibility="0"
							
							[System.Windows.Forms.Application]::DoEvents()	
							
							My-Logger "Configure Network VM for the Company $Global:name" 

							Get-VM -Name "Debian_training_$Global:name"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "LAN_IN_$Global:name" -Confirm:$false   |Out-Null

							Get-VM -Name "SNS_Company_$Global:name"| Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName "LAN_FWS" -Confirm:$false     |Out-Null
							Get-VM -Name "SNS_Company_$Global:name"| Get-NetworkAdapter -Name "Network adapter 2" | Set-NetworkAdapter -NetworkName "LAN_IN_$Global:name" -Confirm:$false     |Out-Null
							Get-VM -Name "SNS_Company_$Global:name"| Get-NetworkAdapter -Name "Network adapter 3" | Set-NetworkAdapter -NetworkName "LAN_DMZ1_$Global:name" -Confirm:$false     |Out-Null
							Get-VM -Name "SNS_Company_$Global:name"| Get-NetworkAdapter -Name "Network adapter 4" | Set-NetworkAdapter -NetworkName "LAN_Gestion" -Confirm:$false     |Out-Null
							My-Logger "Configure Network VM for the Company $Global:name is finished" 
							$Check_Net_SC2.Visibility="0"
							My-Logger "Add Tag for All objects for the Compagny $Global:name "
							$P4_SC2.Visibility="0"
							$C_Meta_SC2.Visibility="0"
							[System.Windows.Forms.Application]::DoEvents()
							
							Move-VM "Debian_training_$Global:name" -InventoryLocation "Compagnie_$Global:name"
							My-Logger "The VM Debian_training_$Global:name is move to the folder Compagnie_$Global:name"
							Move-VM "SNS_Company_$Global:name" -InventoryLocation "Compagnie_$Global:name"
							My-Logger "The VM SNS_Company_$Global:name is move to the folder Compagnie_$Global:name"

							[System.Windows.Forms.Application]::DoEvents()
$code =@'
						
							Connect-VIServer -Server #Host# -User #User# -Password #Password# -WarningAction SilentlyContinue
						
							$Cat = "StormShield"
						$TagVM = @("Scenario1","Scenario2")
						foreach ($Name in $Cat){
							
							if (-Not(Get-TagCategory -Name $Name -ErrorAction SilentlyContinue)) 
							{
							Write-Host -ForegroundColor Green "The Cat $Cat is created"
							New-TagCategory -Name $Name | Out-Null
							}  
						
							#Create Tag if it doesnt exist 
							$UniqueTag = $TagVM | Get-Unique
							foreach ($I in $UniqueTag) 
							{
							if (-Not(Get-Tag $I -ErrorAction SilentlyContinue)) 
							{
								Write-Host -ForegroundColor Green "The Tag $I is created under the Cat $Name"
								New-Tag -Name $I -Cat $Cat | Out-Null
							}  
							}
				  
							  }
			
							$vms = Get-VM *_#Name#*
							$VMT = Get-VM *trainer
							$VMRTR = GET-VM *_RTR_S* 
							$Tagf="Scenario2"
							$vms | New-TagAssignment -Tag $Tagf
							$VMT | New-TagAssignment -Tag $Tagf
							$VMRTR |New-TagAssignment -Tag $Tagf

							$Net=Get-VirtualPortGroup -VirtualSwitch #vSwitch#
							$net | New-TagAssignment -Tag $Tagf
			
'@
					$codef = $code.Replace('#Host#', $Global:vcenter).Replace('#User#',$Global:User).Replace('#Password#',$Global:pass_value).Replace('#Name#',$Global:name).Replace('#vSwitch#',$Global:vSwitch_F)
					
					
							$PowerShell = [PowerShell]::Create().AddScript($codef)
							$job = $PowerShell.BeginInvoke()
							While (-Not $job.IsCompleted) {}
										
							
							$PowerShell.Dispose()
							My-Logger "All objects are already tag for the group $Global:name "
			
							$Check_Met_SC2.Visibility="0"
			
		}

	$EndTime = Get-Date
	$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,0)
	My-Logger "The deployment lasted $duration minutes #"	

	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Terminez","Le deploiement du scenario 2 est termine. Il a dure $duration minutes." )
	My-Logger "####################################"
	My-Logger "# End Deployment Scenario 2       #"
	My-Logger "####################################"


	}


	else
		{
			[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Annulation","Vous pouvez encore modifier des parametres." )
			My-Logger "####################################"
			My-Logger "# Cancled Deployment Scenario 2    #"
			My-Logger "####################################"
		
		}




})

$clean_SC2.add_Click({
    

	$okAndCancel = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
	# show ok/cancel message
	$result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Accept","Voulez-vous Netttoyer le Scenario 2. (VM et Portgroup) ",$okAndCancel)

	If ($result -eq "Affirmative"){ 
	
		My-Logger "####################################"
		My-Logger "# Starting Clean Scenario 2       #"
		My-Logger "####################################"

		$ListeVlan_2 =""
		$Liste_Vlan_SC2.Content = ""
		$Global:list = New-Object System.Collections.ArrayList
		
		Get-Compagny -groupes $NB_Compagnies.value
		Get-CountNetwork -Nbgroupes $NB_Compagnies.value
		
			 $global:Reseaux_SC2.GetEnumerator()| Sort-Object -Property Value | Foreach-Object {
			 $IdVlan =$_.value
			 
			 $Global:list.Add($IdVlan)|Out-Null
			}
	
	
			$ListeVlan_2 = [string]::Join($separator,$Global:list,0,$Global:list.count)	

			$StartTime = Get-Date

			$Global:VMHost = Get-VMHost
			          			
			foreach ($item in $Global:VMHost.Name)
	  {
		
		
		$virtualSwitch = Get-VirtualSwitch -VMHost $item -Name $Global:vSwitch_F 
	            
               
                   $SW= get-VirtualPortGroup -VirtualSwitch $virtualSwitch -Tag "Scenario2"
					 
					Remove-VirtualPortGroup -VirtualPortGroup $SW -Confirm:$false
				   My-Logger "Remove the PortGroup : $SW "

		    		
	    }
	
			$Tagf = "Scenario2"
			$VM = Get-VM | Get-TagAssignment |where{$_.Tag -like "StormShield/$Tagf"} |Select @{N='VM';E={$_.Entity.Name}}
			
			foreach ($item in $VM.VM)
			 {
				try 
					{

						remove-vm $Item -DeleteFromDisk -Confirm:$false | Out-Null
						My-Logger "The VM  $Item  is deleted"

					}
				catch{}
				finally{}
			}

			$EndTime = Get-Date
			$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
			My-Logger "Cleaning phase with duration $duration minutes"

			
			[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Nettoyage Terminez","Le nettoyage du scenario 1 est termine. Il a dure $duration minutes." )

	}
	else
	{
		[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Abandon","Le nettoyage du scenario 1 a ete annule." )
		My-Logger "####################################"
		My-Logger "# Cancel Clean Scenario 2       #"
		My-Logger "####################################"
	
	}	
})


My-Logger "####################################"
My-Logger "# StormShield PowerCli Starting    #"
My-Logger "####################################"

Test-AutoLogin

$Form.ShowDialog() | Out-Null
