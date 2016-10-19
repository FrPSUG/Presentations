<#

    -> What is a static method?
    -> Limitations of a static method?
    -> Why use a static method?

#>

#PowerShell classes:Static Methods 

Class Computer {
    [String]$Name
    [String]$Type
    [string]$Description
    [string]$owner
    [string]$Model
    [datetime]$CreationDate
    [int]$Reboots
    
    #Non static can use '$this' (A reference to the current instance).
        [void]Reboot(){
            $this.Reboots ++
        
        }

    #static members CANNOT use '$this' (A reference to the current instance).
    static [string] ResetNumberOfReboots(){
        
        #$this.reboots = 0

        return "Nope, I am not going to do that!"
   }



}

#All methods are public (Can be seen / used from anywhere).

#A static method is not called using the .<Name>() but ::<Name>.()

#Calling static method
    [Math]::PI

#Calling our custom build Static method
    [Computer]::ResetNumberOfReboots()

    #this does not work since static methods cannot access instances of an object 

<#
    #Why use a static method then?
        We will use a static method each time we want to access a method without having the need to create an instance.
        A good use case would be in the constructor for example
#>  
    