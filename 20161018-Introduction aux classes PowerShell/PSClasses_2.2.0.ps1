<#

    #What is an Enum?
    #How can we create an Enum?
    #What are the limitations of our Enums?
    #We will modify our existing methods to be based on enums, and not simple strings anymore

#>
#Enums and Streams (verbosity) --> 2.2.0

#region Helper Functions

Function Get-ADSIComputer
{
<#
.SYNOPSIS
	The Get-DomainComputer function allows you to get information from an Active Directory Computer object using ADSI.

.DESCRIPTION
	The Get-DomainComputer function allows you to get information from an Active Directory Computer object using ADSI.
	You can specify: how many result you want to see, which credentials to use and/or which domain to query.

.PARAMETER ComputerName
	Specifies the name(s) of the Computer(s) to query

.PARAMETER SizeLimit
	Specifies the number of objects to output. Default is 100.

.PARAMETER DomainDN
	Specifies the path of the Domain to query.
	Examples: 	"FX.LAB"
				"DC=FX,DC=LAB"
				"Ldap://FX.LAB"
				"Ldap://DC=FX,DC=LAB"

.PARAMETER Credential
	Specifies the alternate credentials to use.

.EXAMPLE
	Get-DomainComputer

	This will show all the computers in the current domain

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation001"

	This will query information for the computer Workstation001.

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation001","Workstation002"

	This will query information for the computers Workstation001 and Workstation002.

.EXAMPLE
	Get-Content -Path c:\WorkstationsList.txt | Get-DomainComputer

	This will query information for all the workstations listed inside the WorkstationsList.txt file.

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -Verbose

	This will query information for computers starting with 'Workstation0', but only show 10 results max.
	The Verbose parameter allow you to track the progression of the script.

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -Verbose -DomainDN "DC=FX,DC=LAB" -Credential (Get-Credential -Credential FX\Administrator)

	This will query information for computers starting with 'Workstation0' from the domain FX.LAB with the account FX\Administrator.
	Only show 10 results max and the Verbose parameter allows you to track the progression of the script.

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	
	[CmdletBinding()]
	PARAM (
		[Parameter(ValueFromPipelineByPropertyName = $true,
				   ValueFromPipeline = $true)]
		[Alias("Computer")]
		[String[]]$ComputerName,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100',
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain")]
		[String]$DomainDN = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)#PARAM
	
	PROCESS
	{
		IF ($ComputerName)
		{
			Write-Verbose -Message "One or more ComputerName specified"
			FOREACH ($item in $ComputerName)
			{
				TRY
				{
					# Building the basic search object with some parameters
					Write-Verbose -Message "COMPUTERNAME: $item"
					$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcher
					$Searcher.Filter = "(&(objectCategory=Computer)(name=$item))"
					$Searcher.SizeLimit = $SizeLimit
					$Searcher.SearchRoot = $DomainDN
					
					# Specify a different domain to query
					IF ($PSBoundParameters['DomainDN'])
					{
						IF ($DomainDN -notlike "LDAP://*") { $DomainDN = "LDAP://$DomainDN" }#IF
						Write-Verbose -Message "Different Domain specified: $DomainDN"
						$Searcher.SearchRoot = $DomainDN
					}#IF ($PSBoundParameters['DomainDN'])
					
					# Alternate Credentials
					IF ($PSBoundParameters['Credential'])
					{
						Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
						$Domain = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $($Credential.UserName), $($Credential.GetNetworkCredential().password) -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCred
						$Searcher.SearchRoot = $Domain
					}#IF ($PSBoundParameters['Credential'])
					
					# Querying the Active Directory
					Write-Verbose -Message "Starting the ADSI Search..."
					FOREACH ($Computer in $($Searcher.FindAll()))
					{
						Write-Verbose -Message "$($Computer.properties.name)"
						New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutput -Property @{
							"Name" = $($Computer.properties.name)
							"DNShostName" = $($Computer.properties.dnshostname)
							"Description" = $($Computer.properties.description)
							"OperatingSystem" = $($Computer.Properties.operatingsystem)
							"WhenCreated" = $($Computer.properties.whencreated)
							"DistinguishedName" = $($Computer.properties.distinguishedname)
                            "ManagedBy"= $($Computer.properties.managedby)
                            "Location" = $($Computer.properties.Location)
                            "SID"= $($Computer.Properties.objectsid)
						}#New-Object
					}#FOREACH $Computer
					
					Write-Verbose -Message "ADSI Search completed"
				}#TRY
				CATCH
				{
					Write-Warning -Message ('{0}: {1}' -f $item, $_.Exception.Message)
					IF ($ErrProcessNewObjectSearcher) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object" }
					IF ($ErrProcessNewObjectCred) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object" }
					IF ($ErrProcessNewObjectOutput) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object" }
				}#CATCH
			}#FOREACH $item
			
			
		}#IF $ComputerName
		
		ELSE
		{
			Write-Verbose -Message "No ComputerName specified"
			TRY
			{
				# Building the basic search object with some parameters
				Write-Verbose -Message "List All object"
				$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcherALL
				$Searcher.Filter = "(objectCategory=Computer)"
				$Searcher.SizeLimit = $SizeLimit
				
				# Specify a different domain to query
				IF ($PSBoundParameters['DomainDN'])
				{
					$DomainDN = "LDAP://$DomainDN"
					Write-Verbose -Message "Different Domain specified: $DomainDN"
					$Searcher.SearchRoot = $DomainDN
				}#IF ($PSBoundParameters['DomainDN'])
				
				# Alternate Credentials
				IF ($PSBoundParameters['Credential'])
				{
					Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
					$DomainDN = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $Credential.UserName, $Credential.GetNetworkCredential().password -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCredALL
					$Searcher.SearchRoot = $DomainDN
				}#IF ($PSBoundParameters['Credential'])
				
				# Querying the Active Directory
				Write-Verbose -Message "Starting the ADSI Search..."
				FOREACH ($Computer in $($Searcher.FindAll()))
				{
					TRY
					{
						Write-Verbose -Message "$($Computer.properties.name)"
						New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutputALL -Property @{
							"Name" = $($Computer.properties.name)
							"DNShostName" = $($Computer.properties.dnshostname)
							"Description" = $($Computer.properties.description)
							"OperatingSystem" = $($Computer.Properties.operatingsystem)
							"WhenCreated" = $($Computer.properties.whencreated)
							"DistinguishedName" = $($Computer.properties.distinguishedname)
						}#New-Object
					}#TRY
					CATCH
					{
						Write-Warning -Message ('{0}: {1}' -f $Computer, $_.Exception.Message)
						IF ($ErrProcessNewObjectOutputALL) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object" }
					}
				}#FOREACH $Computer
				
				Write-Verbose -Message "ADSI Search completed"
				
			}#TRY
			
			CATCH
			{
				Write-Warning -Message "Something Wrong happened"
				IF ($ErrProcessNewObjectSearcherALL) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object" }
				IF ($ErrProcessNewObjectCredALL) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object" }
				
			}#CATCH
		}#ELSE
	}#PROCESS
	END { Write-Verbose -Message "Script Completed" }
}

function Get-ADSIObject
{
<#
.SYNOPSIS
	This function will query any kind of object in Active Directory

.DESCRIPTION
	This function will query any kind of object in Active Directory

.PARAMETER  SamAccountName
	Specify the SamAccountName of the object.
	This parameter also search in Name and DisplayName properties
	Name and Displayname are alias.

.PARAMETER  DistinguishedName
	Specify the DistinguishedName of the object your are looking for
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER $DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
	Get-ADSIObject -SamAccountName Fxcat

.EXAMPLE
	Get-ADSIObject -Name DC*
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "SamAccountName")]
		[Alias("Name", "DisplayName")]
		[String]$SamAccountName,
		
		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain", "DomainDN", "SearchRoot", "SearchBase")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			
			IF ($PSBoundParameters['SamAccountName'])
			{
				$Search.filter = "(|(name=$SamAccountName)(samaccountname=$SamAccountName)(displayname=$samaccountname))"
			}
			IF ($PSBoundParameters['DistinguishedName'])
			{
				$Search.filter = "(&(distinguishedname=$DistinguishedName))"
			}
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
				Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			
			foreach ($Object in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"DisplayName" = $Object.properties.displayname -as [string]
					"Name" = $Object.properties.name -as [string]
					"ObjectCategory" = $Object.properties.objectcategory -as [string]
					"ObjectClass" = $Object.properties.objectclass -as [string]
					"SamAccountName" = $Object.properties.samaccountname -as [string]
					"Description" = $Object.properties.description -as [string]
					"DistinguishedName" = $Object.properties.distinguishedname -as [string]
					"ADsPath" = $Object.properties.adspath -as [string]
					"LastLogon" = $Object.properties.lastlogon -as [string]
					"WhenCreated" = $Object.properties.whencreated -as [string]
					"WhenChanged" = $Object.properties.whenchanged -as [string]
				}
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIObject End."
	}
}

Function New-ADSIComputer {
<#
.SYNOPSIS
	The Get-DomainComputer function allows you to get information from an Active Directory Computer object using ADSI.

.DESCRIPTION
	The Get-DomainComputer function allows you to get information from an Active Directory Computer object using ADSI.
	You can specify: how many result you want to see, which credentials to use and/or which domain to query.

.PARAMETER ComputerName
	Specifies the name(s) of the Computer(s) to query

.PARAMETER SizeLimit
	Specifies the number of objects to output. Default is 100.

.PARAMETER DomainDN
	Specifies the path of the Domain to query.
	Examples: 	"FX.LAB"
				"DC=FX,DC=LAB"
				"Ldap://FX.LAB"
				"Ldap://DC=FX,DC=LAB"

.PARAMETER Credential
	Specifies the alternate credentials to use.

.EXAMPLE
	Get-DomainComputer

	This will show all the computers in the current domain

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation001"

	This will query information for the computer Workstation001.

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation001","Workstation002"

	This will query information for the computers Workstation001 and Workstation002.

.EXAMPLE
	Get-Content -Path c:\WorkstationsList.txt | Get-DomainComputer

	This will query information for all the workstations listed inside the WorkstationsList.txt file.

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -Verbose

	This will query information for computers starting with 'Workstation0', but only show 10 results max.
	The Verbose parameter allow you to track the progression of the script.

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -Verbose -DomainDN "DC=FX,DC=LAB" -Credential (Get-Credential -Credential FX\Administrator)

	This will query information for computers starting with 'Workstation0' from the domain FX.LAB with the account FX\Administrator.
	Only show 10 results max and the Verbose parameter allows you to track the progression of the script.

.NOTES
	Stéphane van Gulick
    http://PowerShellDistrict.com
    @stephanevg
#>
	
	[CmdletBinding()]
	PARAM (
		[Parameter(ValueFromPipelineByPropertyName = $true,
				   ValueFromPipeline = $true,
                   Mandatory=$true
                   )]
		[Alias("Computer")]
		[String[]]$ComputerName,
		
		[Alias("OrganisationalUnitPath","OU")]
		[String]$OUName='CN=Computers',
		
        [Parameter(Mandatory=$true)]
        [String]
        $Description,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain")]
		[String]$DomainDN = $(([adsisearcher]"").Searchroot.distinguishedName),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,

        [Switch]
        $DisableAccount
	)#PARAM

    Begin{
    
    }Process{

        
        if ($DomainDN.Contains('LDAP://')){

            $DomainRoot = $DomainDN.Replace('LDAP://','')

        }

        if (!($OUName.Contains('OU='))){
            $OUName = "OU=" + $OUName
        }

        $OuString = "LDAP://" + $OUName + "," + $DomainRoot
        write-verbose "OU--> $OuString"
        $ComputerOU  = [ADSI]$OuString
        
        $Computer = $ComputerOU.create(“Computer”,”CN=$ComputerName”)     
        $Computer.Put(“Description”,$Description)
        [string]$SamAccountName = $ComputerName.Trim() + '$'
        $Computer.Put("sAMAccountName",$SamAccountName)
        if (!($DisableAccount)){
            $Computer.put(“userAccountControl”,4128)
        }

        
        write-verbose "Adding $($ComputerName) to OU $($ComputerOU.Path)" 
        $Computer.setinfo()
    }
    End{
    
    }

}

#endregion

import-module "C:\System\Scripts\Classes\BPUG-Commands.psm1" -force


#region Enums

#Enum Syntax
<#

    Enum <EnumName>{
    
        <Property1>
        <Property2>
        

    }

#>
#Enums can only be constants. They start at 0 

#Enums are of their 'own type'

#Is like a typed ValidateSet

Enum MachineType {
    Server
    Client
 
}



#endregion

Class Computer {
    [String]$Name 
    [MachineType]$Type
    [string]$Description
    [string]$owner
    [string]$Model
    [datetime]$CreationDate
    [int]$Reboots
    [String]$Prefix
    
    [void]Reboot(){
        $this.Reboots ++
        
    }
    
    #GetNextFreeName doesn't Require a String Anymore
    [Computer] GetNextFreeName () {

        
        $pref = $this.Prefix.ToUpper()
        #$AllNames = Get-ADComputer -Filter {name -like "$prefix*"} | select name
        $AllNames = Get-ADSIComputer -ComputerName "$pref*" | select Name
        [int]$LastUsed = $AllNames | % {$_.name.trim("$pref")} | select -Last 1
        Write-Verbose "Lastused number: $LastUsed"
        $Next = $LastUsed+1
        $nextNumber = $Next.tostring().padleft(2,'0')
        write-verbose "Prefix:$($pref) Number:$($nextNumber)"
        $NewComputer = $pref + $nextNumber
        $This.Name = $NewComputer
        write-verbose "Next available value is --> $($NewComputer)"

        Return $this
    }

    [Computer]Create(){
    $OU=""
        if (!($This.Name)){
            
            throw "The name parameter cannot be empty"
        }else{
        
            switch($this.Type){
                "Server" {$OU="OU=Servers,OU=HQ"}
                "Client" {$OU="OU=Clients,OU=HQ"}
                Default {$OU="CN=Computers"}
            }

            New-ADSIComputer -ComputerName $this.Name -Description $this.Description -OUName $OU

            return $this

        }

        
    }

    Computer (){
    
        $this.CreationDate = get-date

    }

    Computer ([MachineType]$Type,[String]$Description){
    
        $This.Type = $Type

        switch ($This.Type){

                'Server' {$this.Prefix = 'SRV'}
                'Client' {$this.Prefix = 'CLT'}
        
        
        }

        $this.CreationDate = get-date
        $This.Description = $Description

    }


}

$VerbosePreference = 'Continue'
#Same code, but Cleaned constructor. added verbosity.

#Enums can only hold constants

[MachineType] #is of type 'MachineType' (Name)

$enumType = [MachineType]::Server
$enumType
$enumType | gm #Is of type 'MAchine Type', not a string!

#Enums are of base type Integer
$enumType.GetType()

[MachineType]0
[MachineType]1

    
    #Code has been adapated to check on Type, not on strings anymore.
    $d = [computer]::new($enumType,"Woopy")

    $d

#Verbosity
    # No -Verbose possible. It has to be managed directly with the environment variables
    
    #$VerbosePreference = 'silentlyContinue'
    

    $d.GetNextFreeName()

    #$VerbosePreference = 'Continue'

    $d.GetNextFreeName()

    #Creating Object in AD
    $d.Create()

    

#Using the same code, we can easily generate other results specifying the Client Enum
    $ClientEnum = [MachineType]::Client
    $Client = [computer]::new($ClientEnum,"Client PC")
    $Client
    $Client.GetNextFreeName()
    $Client.Create()

    $VerbosePreference = 'SilentlyContinue'

    

#Back to mind map for Inheritance
