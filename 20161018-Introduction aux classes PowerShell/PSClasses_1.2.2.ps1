<#
    -> What is a Method?
    -> How to create a method?
    -> How to call a method?
    -> what is [void]?
    -> what is $this?


#>
#PowerShell classes:Methods

#1: What is a method?
    #A method is an action that DOES something

#2: How to create a method?

#Method Syntax
    <#
     [returnType] MethodName ([string]$name,[int]$number){
        #CodeBlock
      }
    #if nothing need to be returned, then use [void]
    #>


Class Computer {
    [String]$Name
    [String]$Type
    [string]$Description
    [string]$owner
    [string]$Model
    [datetime]$CreationDate
    [int]$Reboots
    
   #Methods
    [void]Reboot(){
        $this.Reboots ++ #notice the keyword $this
        
    }

    
}


#What is Void? --> Void is nothing!

$c = [Computer]::new()
$c.name = 'c'
$c

$c.Reboot() #Notice that it didn't returned anything

$c.Reboots # the reboots property has been incremented (the use of $this)

for($i=1; $i -le 10; $i++){
    $c.Reboot()
}

$c

#let's create a new instance of our computer
    $second = [Computer]::new()

#and add 42 reboots to it
    for($i=1; $i -le 42; $i++){
        $second.Reboot()
    }

$second.Name = 'second'
$second #<-42
$c #<- 11

#$this allows to reference the 'current instance'