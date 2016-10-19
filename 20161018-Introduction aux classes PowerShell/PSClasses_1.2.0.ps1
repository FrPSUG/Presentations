<#
    --> How to create our first Class?
    --> How to declare properties?
    --> What is an instance and how to create one?
    --> How to assign properties?
#>

$VerbosePreference = "silentlycontinue"
#PowerShell classes: --> Basics: Properties

Class frpsug {
    
 

}

[frpsug]


#Create an instance

    [frpsug]::new()

    New-Object frpsug

#Creating our first class with properties

    #Notice there are no comas in between the parameters and they are typed.

Class Computer {
    [String]$Name = "Undefined"
    [String]$Type
    [string]$Description
    [string]$owner
    [string]$Model
    [datetime]$CreationDate
    [int]$Reboots

}

#To create an object, you need to 'Instanciate the class.'

#Class instanciation

    $a = [computer]::new()
    $a
#Closer look on the type


$a.GetType() #BaseType System.Object

$a.GetType().fullname #is of type "Computer"

#Accessing properties
$a.Name

#Property assignements

$a.name = 'FRPSUG'

$a