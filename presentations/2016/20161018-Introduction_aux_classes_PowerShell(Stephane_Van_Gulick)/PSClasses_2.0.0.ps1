<#

    #What is a constructor?
    #How to create our first constructor?
    #We actually already have been using constructors since the begining
    

#>

#PowerShell classes:Constructors (Basics)

Class Computer {
    [String]$Name
    [String]$Type
    [string]$Description
    [string]$owner
    [string]$Model
    [datetime]$CreationDate
    [int]$Reboots
    
    #Non static can use 'this' (the current instance).
        [void]Reboot(){
            $this.Reboots ++
        
        }

    #static members cannot use 'this' (the current instance).
    static [string] ResetNumberOfReboots(){
        
        #$this.reboots = 0

        return "Nope, I am not going to do that!"
   }


    #constructors

        #A constructor must ALWAYS have the same name as the class. We can create unlimited number of different constructors.
    Computer (){
    
        $this.CreationDate = get-date

    }

}

#In previous example still created an instance without having a constructor
    #time was set too default value --> 1/1/0001 12:00:00 AM

    $d = [computer]::new()

    $d

   