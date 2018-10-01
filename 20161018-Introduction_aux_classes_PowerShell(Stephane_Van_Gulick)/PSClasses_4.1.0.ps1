<#
    Demonstration of Polymorphism in action (method create in computer class)
    Added more values to Enum computerType (minimum impact on logic)
    How to create a computer object in predefined OU's dynamically based on the type of computer object to create.
#>


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

function Get-ADSIUser
{
<#
.SYNOPSIS
	This function will query Active Directory for User information. You can either specify the DisplayName, SamAccountName or DistinguishedName of the user

.PARAMETER SamAccountName
	Specify the SamAccountName of the user
	
.PARAMETER DisplayName
	Specify the DisplayName of the user
	
.PARAMETER DistinguishedName
	Specify the DistinguishedName path of the user
	
.PARAMETER Credential
    Specify the Credential to use for the query
	
.PARAMETER SizeLimit
    Specify the number of item maximum to retrieve
	
.PARAMETER DomainDistinguishedName
    Specify the Domain or Domain DN path to use
	
.PARAMETER MustChangePasswordAtNextLogon
	Find user that must change their password at the next logon
	
.EXAMPLE
	Get-ADSIUser -SamAccountName fxcat
	
.EXAMPLE
	Get-ADSIUser -DisplayName "Cat, Francois-Xavier"
	
.EXAMPLE
	Get-ADSIUser -DistinguishedName "CN=Cat\, Francois-Xavier,OU=Admins,DC=FX,DC=local"
	
.EXAMPLE
    Get-ADSIUser -SamAccountName testuser -Credential (Get-Credential -Credential Msmith)
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "SamAccountName")]
	PARAM (
		[Parameter(ParameterSetName = "DisplayName", Mandatory = $true)]
		[String]$DisplayName,
		
		[Parameter(ParameterSetName = "SamAccountName", Mandatory = $true)]
		[String]$SamAccountName,
		
		[Parameter(ParameterSetName = "DistinguishedName", Mandatory = $true)]
		[String]$DistinguishedName,
		
		[Parameter(ParameterSetName = "MustChangePasswordAtNextLogon", Mandatory = $true)]
		[Switch]$MustChangePasswordAtNextLogon,
		
		[Parameter(ParameterSetName = "PasswordNeverExpires", Mandatory = $true)]
		[Switch]$PasswordNeverExpires,
		
		[Parameter(ParameterSetName = "NeverLoggedOn", Mandatory = $true)]
		[Switch]$NeverLoggedOn,
		
		[Parameter(ParameterSetName = "DialIn", Mandatory = $true)]
		[boolean]$DialIn,
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Parameter()]
		[Alias("DomainDN", "Domain")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
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
			$Search.SearchRoot = $DomainDN
			
			If ($PSBoundParameters['DisplayName'])
			{
				$Search.filter = "(&(objectCategory=person)(objectClass=User)(displayname=$DisplayName))"
			}
			IF ($PSBoundParameters['SamAccountName'])
			{
				$Search.filter = "(&(objectCategory=person)(objectClass=User)(samaccountname=$SamAccountName))"
			}
			IF ($PSBoundParameters['DistinguishedName'])
			{
				$Search.filter = "(&(objectCategory=person)(objectClass=User)(distinguishedname=$distinguishedname))"
			}
			
			IF ($DomainDistinguishedName)
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			
			IF ($PSBoundParameters['MustChangePasswordAtNextLogon'])
			{
				$Search.Filter = "(&(objectCategory=person)(objectClass=user)(pwdLastSet=0))"
			}
			
			IF ($PSBoundParameters['PasswordNeverExpires'])
			{
				$Search.Filter = "(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=65536))"
			}
			IF ($PSBoundParameters['NeverLoggedOn'])
			{
				$Search.Filter = "(&(objectCategory=person)(objectClass=user))(|(lastLogon=0)(!(lastLogon=*)))"
			}
			
			IF ($PSBoundParameters['DialIn'])
			{
				$Search.Filter = "(objectCategory=user)(msNPAllowDialin=$dialin)"
			}
			
			foreach ($user in $($Search.FindAll()))
			{
				
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"DisplayName" = $user.properties.displayname -as [string]
					"SamAccountName" = $user.properties.samaccountname -as [string]
					"Description" = $user.properties.description -as [string]
					"DistinguishedName" = $user.properties.distinguishedname -as [string]
					"ADsPath" = $user.properties.adspath -as [string]
					"MemberOf" = $user.properties.memberof
					"Location" = $user.properties.l -as [string]
					"Country" = $user.properties.co -as [string]
					"PostalCode" = $user.Properties.postalcode -as [string]
					"Mail" = $user.properties.mail -as [string]
					"TelephoneNumber" = $user.properties.telephonenumber -as [string]
					"LastLogonTimeStamp" = $user.properties.lastlogontimestamp -as [string]
					"ObjectCategory" = $user.properties.objectcategory -as [string]
					"Manager" = $user.properties.manager -as [string]
					"HomeDrive" = $user.properties.homedrive -as [string]
					"LogonCount" = $user.properties.logoncount -as [string]
					"DirectReport" = $user.properties.l -as [string]
					"useraccountcontrol" = $user.properties.useraccountcontrol -as [string]
                    'LastName' = $user.properties.sn -as [string]
					'FirstName' = $user.Properties["givenName"] -as [string]
					
					<#
					lastlogoff
					codepage
					c
					department
					msexchrecipienttypedetails
					primarygroupid
					objectguid
					title
					msexchumdtmfmap
					whenchanged
					distinguishedname
					targetaddress
					homedirectory
					dscorepropagationdata
					msexchremoterecipienttype
					instancetype
					memberof
					usnchanged
					usncreated
					description
					streetaddress
					directreports
					samaccountname
					logoncount
					co
					msexchpoliciesexcluded
					userprincipalname
					countrycode
					homedrive
					manager
					samaccounttype
					showinaddressbook
					badpasswordtime
					msexchversion
					objectsid
					objectclass
					proxyaddresses
					objectcategory
					extensionattribute3
					givenname
					pwdlastset
					managedobjects
					st
					whencreated
					physicaldeliveryofficename
					legacyexchangedn
					lastlogon
					accountexpires
					useraccountcontrol
					badpwdcount
					postalcode
					displayname
					msexchrecipientdisplaytype
					sn
					mail
					lastlogontimestamp
					company
					adspath
					name
					telephonenumber
					cn
					msexchsafesendershash
					mailnickname
					l
					
					#>
				}#Properties
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}#FOREACH
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END { Write-Verbose -Message "[END] Function Get-ADSIUser End." }
}

Function New-ADSIComputer {
<#
.SYNOPSIS
	
.DESCRIPTION
	

.PARAMETER ComputerName
	Specifies the name(s) of the Computer(s) to query


.PARAMETER DomainDN
	Specifies the path of the Domain to query.
	Examples: 	"FX.LAB"
				"DC=FX,DC=LAB"
				"Ldap://FX.LAB"
				"Ldap://DC=FX,DC=LAB"

.PARAMETER Credential
	Specifies the alternate credentials to use.

.EXAMPLE

    New-ADSIComputer -ComputerName "Client01" -Description "Stephane's test client" -OUName "OU=Test"
	
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
		
        [Parameter(Mandatory=$false)]
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
        try{
            $Computer.setinfo()
            return $Computer
        }catch{
            write-warning $_
        }
    }
    End{
        
    }

}

#endregion

Import-Module "C:\System\Scripts\Classes\BPUG-Commands.psm1"

#Showing inheritence for Server

##Verbose and enums

#region Enums

#Enums


Enum MachineType {
    Server
    Client
}

Enum ComputerType{
    Laptop
    WorkStation
    NoteBook
    Tablet
    Phone
    RackedServer
    VirtualServer
    PhysicalServer
}

#endregion

Class Computer {
    [String]$Name
    [MachineType]$Type
    [ComputerType]$ComputerType
    [string]$Description
    [string]$owner
    [string]$Model
    [datetime]$CreationDate
    [int]$Reboots
    
    [void]Reboot(){
        $this.Reboots ++
        
    }
    
    [Computer] GetNextFreeName () {

        

        $prefix = $this.prefix.toUpper()
        #$AllNames = Get-ADComputer -Filter {name -like "$prefix*"} | select name
        $AllNames = Get-ADSIComputer -ComputerName "$Prefix*" | select Name
        [int]$LastUsed = $AllNames | % {$_.name.trim("$prefix")} | select -Last 1
        Write-Verbose "Lastused number: $LastUsed"
        $Next = $LastUsed+1
        $nextNumber = $Next.tostring().padleft(2,'0')
        write-verbose "Prefix:$($Prefix) Number:$($nextNumber)"
        $NewComputer = $prefix + $nextNumber
        $This.Name = $NewComputer
        write-verbose "Next available value is --> $($NewComputer)"
        

        Return $this
    }

    

    [Computer]Create([String]$OU){
    
        if (!($This.Name)){
            
            throw "The name parameter cannot be empty"
        }else{
        
            
            if (!($This.owner)){
                throw "The BPUG internal process stipulates that an owner must be set.Use the SetOWner() method to assign an owner and try again." 
            }else{
                New-ADSIComputer -ComputerName $this.Name -Description $this.Description -OUName $OU
            }

            

            return $this

        }

        
    }

    [Computer]Create([ComputerType]$ComputerType){
        $OU=""
        if (!($This.Name)){
            
            throw "The 'name' property cannot be empty.Call The GetNextFreeName() Method and try again."

        }else{
        Write-Verbose "ComputerType is of type: $($computerType)"
            if ($ComputerType -ne $null){
                
                Write-Verbose "Computer is of type: $($ComputerType)"
                #If clientype is of type 'Tablet or phone' it will be put into OU=MobileDevices
                    switch($ComputerType){
                    'Laptop' {
                        $This.Model = $ComputerType
                        $OU='OU=Clients,OU=HQ'
                        Break;
                    }
                    'WorkStation' {
                        $This.Model = $ComputerType
                        $OU='OU=Clients,OU=HQ'
                        Break;
                    }
                    'NoteBook' {
                        $This.Model = $ComputerType
                        $OU='OU=Clients,OU=HQ'
                        Break;
                    }
                    'Tablet' {
                        $This.Model = $ComputerType
                        $OU='OU=MobileDevices,OU=HQ'
                        Break;
                    }
                    'RackedServer' {
                        $This.Model = $ComputerType
                        $OU='OU=Servers,OU=HQ'
                        Break;
                    }
                    'Phone' {
                        $This.Model = $ComputerType
                        $OU='OU=Servers,OU=HQ'
                        Break;
                    }
                    'VirtualServer' {
                        $This.Model = $ComputerType
                        $OU='OU=Servers,OU=HQ'
                        Break;
                    }
                    'PhysicalServer' {
                        $This.Model = $ComputerType
                        $OU='OU=Serve,OU=HQ'
                        Break;
                    }
                    default {
                        throw "ClientType is not recognized. Use a value from the [ClientType] enumerator and try again."
                    }
        }#end switch
                
                 Write-Verbose "Creating Computer Account: $($this.Name) Description: $($this.Description) OUName: $($OU) "
                 New-ADSIComputer -ComputerName $this.Name -Description $this.Description -OUName $OU -ManagedByCN $This.owner

                return $this
                

            }else{
                throw "Method is missing the parameter 'ClientType'"
            }

        }

    }

    [computer]SetOwner([String]$SamAccountName){
    
        
        $UserAccount = Get-ADSIUser -SamAccountName $SamAccountName

        if ($UserAccount){
        
            $this.owner = $UserAccount.DistinguishedName

            return $this

        }else{
            throw "Couldn't find the user account $($SamAccountName)."
        }
        
    }

    Computer (){
    
        $this.CreationDate = get-date

    }

    Computer ([String]$Description){
    
        $this.CreationDate = get-date
        $This.Description = $Description

    }


}

Class Server : Computer {

    [MachineType]$Type = [MachineType]::Server
    [String]$Prefix = "SRV"

}

Class Client : Computer {

    [MachineType]$Type = [MachineType]::Client
    [String]$Prefix = "CLT"

        #Override an existing method
    [Client]Create([String]$OU){
    
        if (!($This.Name)){
            
            throw "The 'name' property cannot be empty"
        }else{
        
           if (!($this.owner)){
                
                throw "The 'Owner' property cannot be empty when creating a client Account"
           }else{

                New-ADSIComputer -ComputerName $this.Name -Description $this.Description -OUName $OU

                return $this
            }
        }

        
    }


    
}




    $OldVerbosePreference = $VerbosePreference
    $VerbosePreference = 'Continue'

#--> Working With Servers

#region Server
    #Instantiation
        $BPUGServer = [Server]::new()

    #Set Description
        $BPUGServer.Description = "Provisioning automagically a Server and has a ManagedBy user assigned ;)"

    #Get the next Available computer
        $BPUGServer.GetNextFreeName()

    #Set an owner
        $BPUGServer.SetOwner("klao")

    #Create new server
        $ComputerType = [ComputerType]::VirtualServer

    #Create in AD
        #Use intelisence to show the two different constructors.
        $BPUGServer.Create($ComputerType)
        #$BPUGServer.create('OU=Servers,OU=HQ') <- Old way

#endregion

#region client
    $FRPSUGClient = [Client]::new()

    ###Creating a client machine
    #Set Description
        $FRPSUGClient.Description = "Provisioning automagically a client and has a ManagedBy user assigned ;)"

    #Get the next Available computer
        $FRPSUGClient.GetNextFreeName()
        
    #Set an owner
        $FRPSUGClient.SetOwner("sblade")

    #Create new client
        $Client = [ComputerType]::Laptop
        $FRPSUGClient.Create($Client)


#endregion


    

