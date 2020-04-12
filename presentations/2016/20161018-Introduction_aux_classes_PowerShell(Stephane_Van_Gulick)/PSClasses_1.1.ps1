#Region Modifying Existing Objects


    $ComputerName = 'Server01'
##Creating Property Aliases
    $ComputerName | gm #One property called Length, that's it

    #We can create property aliases using AliasProperty
        $ComputerName = $ComputerName | Add-Member -MemberType AliasProperty -Name Size -Value Length -PassThru -force

    $ComputerName | Get-Member -MemberType *prop* # See AliasProperty
    $ComputerName.Length

    $Computername.Size

##

#endregion

##Adding Methods to custom objects

    

    $Properties = @{'Name'=$ComputerName;'Owner'=$ComputerOwner;'Type'=$ComputerType}
    $Computer = new-object psobject -Property $Properties

    $Computer | gm

    $ScriptBlock1 = {

             $Current = [char[]] $this.Name # <-- Notice This 'This'!
             [array]::reverse($Current)
             -join $Current
        
    }
    Add-Member -InputObject $Computer -MemberType ScriptMethod -Name ReverseName -Value $ScriptBlock1 -Force

    $Computer | gm
    
    $Computer.ReverseName()



##Generating a New ComputerName (without assigining it back to the instance)
    $ScriptBlock2 = {
        
        [int]$Suffix = '0'
        Do {
            $Suffix++
            $Prefix = 'SRV'
            $Name = $Prefix + $Suffix
        }While(!($Name))
        return $Name
    }
    Add-Member -InputObject $Computer -MemberType ScriptMethod -Name GenerateComputerName -Value $ScriptBlock2 -Force

    $Computer | gm

    $Computer.GenerateComputerName()

    $Computer
#Generating a New ComputerName AND Assigning it to the existing property (Using $This)

$ScriptBlock3 = {
        
        [int]$Suffix = '0'
        Do {
            $Suffix++
            $Prefix = 'SRV'
            $Name = $Prefix + $Suffix
        }While($this.Name -ne $this.Name)
        $This.Name = $Name #<-- This is the magic!
    }
    Add-Member -InputObject $Computer -MemberType ScriptMethod -Name GenerateStandardComputerName -Value $ScriptBlock3 -Force

    $Computer | gm

    $computer.GenerateStandardComputerName()

    $Computer

    $Computer.GetType() #Is of type --> PSCustomObject