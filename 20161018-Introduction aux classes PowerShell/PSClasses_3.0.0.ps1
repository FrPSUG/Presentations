#--> 3.0

<#

    #How to use Enums in conjunction with inheritence

#>
#region Helper Functions

#Showing inheritence for Client

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
        $DisableAccount,

        [String]$ManagedByCN
	)#PARAM

    Begin{
    
    }Process{

        
        if ($DomainDN.Contains('LDAP://')){

            $DomainRoot = $DomainDN.Replace('LDAP://','')

        }else{
            $DomainRoot = $DomainDN
        }

        if (!($OUName.Contains('OU='))){
            $OUName = "OU=" + $OUName
        }

        $OuString = "LDAP://" + $OUName + "," + $DomainRoot
        write-verbose "OU--> $OuString"
        $ComputerOU  = [ADSI]$OuString
        
        $Computer = $ComputerOU.create(“Computer”,”CN=$ComputerName”)     
        $Computer.Put(“Description”,$Description)

        if ($ManagedByCN){
            $Computer.Put("ManagedBy",$ManagedByCN)
        }

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
import-module "C:\System\Scripts\Classes\BPUG-Commands.psm1" -force
#endregion

##Conditional logic based on Enumeration Types Using Inheritence

#region Enums

#Enums


Enum MachineType {
    Server
    Client
}

Enum ClientType{
    Laptop
    WorkStation
    NoteBook
    Tablet
    Phone
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

    [Server]SetOwner([String]$SamAccountName){
    
        
        $UserAccount = Get-ADSIUser -SamAccountName $SamAccountName

        if ($UserAccount){
        
            $this.owner = $UserAccount.DistinguishedName

            return $this

        }else{
            throw "Couldn't find the user account $($SamAccountName)."
        }
        
    }

    [Server]Create([String]$OU){
    
        if (!($This.Name)){
            
            throw "The name parameter cannot be empty"
        }else{
        
            
            if (!($This.owner)){
                throw "The BPUG internal process stipulates that an owner must be set.Use the SetOWner() method to assign an owner and try again." 
            }else{
                New-ADSIComputer -ComputerName $this.Name -Description $this.Description -OUName $OU -ManagedByCN $This.owner
            }

            

            return $this

        }

        
    }

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

    [Client]Create([ClientType]$ClientType){
        $OU=""
        if (!($This.Name)){
            
            throw "The 'name' property cannot be empty.Call The GetNextFreeName() Method and try again."

        }else{
        
            if ($ClientType){
                
                Write-Verbose "Computer is of type: $($ClientType)"
                #If clientype is of type 'Tablet or phone' it will be put into OU=MobileDevices
                    switch($ClientType){
                    'Laptop' {
                        $This.Model = $ClientType
                        $OU='OU=Clients,OU=HQ'
                        Break;
                    }
                    'WorkStation' {
                        $This.Model = $ClientType
                        $OU='OU=Clients,OU=HQ'
                        Break;
                    }
                    'NoteBook' {
                        $This.Model = $ClientType
                        $OU='OU=Clients,OU=HQ'
                        Break;
                    }
                    'Tablet' {
                        $This.Model = $ClientType
                        $OU='OU=MobileDevices,OU=HQ'
                        Break;
                    }
                    'Phone' {
                        $This.Model = $ClientType
                        $OU='OU=MobileDevices,OU=HQ'
                        Break;
                    }
                    default {
                        throw "ClientType is not recognized. Use a value from the [ClientType] enumerator and try again."
                    }
        }#end switch
                
                 Write-Verbose "Creating Computer Account: $($this.Name) Description: $($this.Description) OUName: $($OU) "
                 New-ADSIComputer -ComputerName $this.Name -Description $this.Description -OUName $OU

                return $this
                

            }else{
                throw "Method is missing the parameter 'ClientType'"
            }

        }

    }
}




    $OldVerbosePreference = $VerbosePreference
    $VerbosePreference = 'Continue'

#--> Working With Clients

    #Instantiation
        $Client = [Client]::new()
        
    #Get the next Available computer
        $Client.GetNextFreeName()

    #Set Description
        $Client.Description = "Creation of Tablet computer Account"
        $VerbosePreference = 'Continue'
    #Create in AD
        #Use intelisence to show the two different constructors.
        #Two Constructors, which have different signature (String / ClientType)
        $Client.create([ClientType]::Tablet)

        





    

