##A history of objects --> creating objects in Powershell prior to Classes.

#To add
    #Create an instance of a class using a hash table
    #Methods and constructor Overloads
    #Methods override

#region Introduction

$ComputerName = 'Server01'
$ComputerOwner = 'Stephane van Gulick'
$ComputerType = 'Standard Server'

#what is an object?
    $ComputerName
    $ComputerName | gm

    #Fundamentally? Data (Properties)

        $ComputerName | gm -MemberType Property

        #Returns information
        $ComputerName.Length

    #Methods
        $ComputerName | gm -MemberType Methods

        #Does Something
        $ComputerName.ToUpper()

#endregion

#Creating synthetic objects

$Directories = dir C:\system\scripts | Select-Object -Property Name,Length

$Directories

#Modifying existing object
    $SelectedObjects = dir C:\system\scripts | Select-Object -Property Name,Length, @{Name="Folder";Expression={$_.PsIsContainer}}

    $SelectedObjects

    $SelectedObjects | gm #Folder is of type NoteProperty

    #We can select select this specefic property
    $SelectedObjects[1]
    $SelectedObjects[1].Folder

    #Fundamentally, everything in PowerShell, is an object (!)

    $SelectedObjects[1].GetType()

#Creation of objects:

#PowerShell Version 1:
$Comp = New-Object –TypeName PSObject

Add-Member -InputObject $Comp -Type NoteProperty -Name Name -Value $ComputerName
Add-Member -InputObject $Comp -Type NoteProperty -Name Owner -Value $ComputerOwner
Add-Member -InputObject $Comp -Type NoteProperty -Name Type -Value $ComputerType

$Comp
#Everything is an object

$Comp | Get-Member #(PsCustomObject))
$comp.GetType()

#region PowerShell version 2:

$Properties = @{'Name'=$ComputerName;'Owner'=$ComputerOwner;'Type'=$ComputerType}
$Computer = new-object psobject -Property $Properties

$Computer

#Shorter way (My preffered way):

$Props = @{}
$Props.Name = $ComputerName
$Props.Owner = $ComputerOwner
$Props.Type = $ComputerType

$Computer2 = new-object psobject -Property $Props

$Computer2.GetType()

$Computer2

#endregion

#region PowerShell Version 3

    #Creating Objects using the PSCustomObject Accelerator
        $Computer3 = [PSCustomObject] @{'Name'=$ComputerName;'Owner'=$ComputerOwner;'Type'=$ComputerType}

        $Computer3
        $Computer3.GetType()

    #Creating Objects had one draw back (sometimes): The order
        $Properties2 = @{'Name'=$ComputerName;'Owner'=$ComputerOwner;'Type'=$ComputerType;'Property1'='Woop';'Property2'='Plop';'Property3'='Woopidipoopi'}
        $Computer4 = [PSCustomOBject]$Properties2
        $Computer4
        $Computer4.GetType()

    #Is resolved when using Accelerator [Ordered]
        $Properties3 = [Ordered]@{'Name'=$ComputerName;'Owner'=$ComputerOwner;'Type'=$ComputerType;'Property1'='Woop';'Property2'='Plop';'Property3'='Woopidipoopi'}
        $Computer5 = [PSCustomObject]$Properties3
        $Computer5

        $Computer5.GetType()

        $COmputer5 | gm #Is of type PSCustomObject

#endregion

psedit .\PSClasses_1.1
#PowerShell Version