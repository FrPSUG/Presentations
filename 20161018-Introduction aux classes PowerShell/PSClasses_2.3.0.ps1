<#

    #Inheritence
    #We will use the same code written in Computer class in two different child classes
    #Computer is the parent Class
        #Client and Server are child classes
    #
#>

#All of this was cool, but It can be optimized using Class inheritence
#Overriding Methods

#region Helper Functions
import-module "C:\System\Scripts\Classes\BPUG-Commands.psm1" -force

#endregion

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
    
    #Setting properties which are unique to a Server
    #Added new method into child class
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
}

Class Client : Computer {

    #Setting properties which are unique to a Client
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

    [Client]Create([String]$OU,[ClientType]$ClientType){
        
        if (!($This.Name)){
            
            throw "The 'name' property cannot be empty.Call The GetNextFreeName() Method and try again."

        }else{
        
            if ($ClientType){
                

                #If clientype is of type 'Tablet or phone' it will be put into OU=MobileDevices
                switch($ClientType){
                    {[ClientType]::Laptop} {
                        $This.Model = $ClientType
                        $OU='OU=Clients'
                        Break
                    }
                    {[ClientType]::WorkStation} {
                        $This.Model = $ClientType
                        $OU='OU=Clients'
                        Break
                    }
                    {[ClientType]::NoteBook} {
                        $This.Model = $ClientType
                        $OU='OU=Clients'
                        Break
                    }
                    {[ClientType]::Tablet} {
                        $This.Model = $ClientType
                        $OU='OU=MobileDevices'
                        Break
                    }
                    {[ClientType]::Phone} {
                        $This.Model = $ClientType
                        $OU='OU=MobileDevices'
                        Break
                    }
                    default {
                        throw "ClientType is not recognized. Use a value from the [ClientType] enumerator and try again."
                    }
                    
                   

                }#end switch
                
                 New-ADSIComputer -ComputerName $this.Name -Description $this.Description -OUName $OU

                return $this
                

            }else{
                throw "Method is missing the parameter 'ClientType'"
            }

        }

    }
}



#All of this can be optimized using inheritence! 
    #Prefix is directly set in each inherited class
    #the proparty Type is speceficly and directly set in each inherited class

    #It is possible to implement very easily another workflow to create an object using the same base code for each inherited class.
    #Add a owner to the object.

    $OldVerbosePreference = $VerbosePreference
    $VerbosePreference = 'Continue'

#--> Working With Servers

    #Instantiation
        $w = [Server]::new() # Creating a [Server] object Not [Computer]
        $w.GetType() #Is of type server with basetype Computer

    #Get the next Available computer
        $w.GetNextFreeName()

    #Set Description
        $W.Description = "Provisioning test"

    #Create in AD
        $w.create("OU=Servers,OU=HQ") # --> Will fail Since Owner is not yet set

    #Set Owner
        $w.SetOwner('klao')

    #Create in AD 2
        $w.create("OU=Servers,OU=HQ")
        #Create the ad object, but does not set the owner (yet)



    

