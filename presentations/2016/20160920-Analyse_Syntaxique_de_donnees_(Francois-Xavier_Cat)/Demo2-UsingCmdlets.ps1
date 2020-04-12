<#
    Parsing Data Using PowerShell \ Analyse syntaxique de données avec PowerShell
    -Francois-Xavier Cat-
#>

<##############################
#  DEMO 2 - Using PS cmdlets  #
###############################>




# WindowsUpdate.log
$file = "C:\lazywinadmin\parsing\WindowsUpdate.log"

# Using Import-CSV
Import-CSv -Path $file -Delimiter "`t" |ogv
Import-CSv -Path $file -Delimiter "`t" -Header "Date","Time","PID","TID","Component","Message"|ogv


# Example - Using ConvertFrom-CSV
# create a list of 'dummy headers'
$Properties = "Date","Time","PID","TID","Component","Message"
Get-Content -Path $file |
#where-object {$_ -like...}
ConvertFrom-CSV -Delimiter "`t" -Header $Properties | out-gridview



# Example 4 (Performance using #ReadCount#)
# create a list of 'dummy headers'
$Properties = "Date","Time","PID","TID","Component","Message"
Get-Content -Path $file -ReadCount 0 |
<#
    READCOUNT

    Specifies how many lines of content are sent through the pipeline at a time. The default value is 1. A value of 0 (zero) sends all of the content at one time.
    This parameter does not change the content displayed, but it does affect the time it takes to display the content. As the value of ReadCount increases, the time it takes to return the first line increases, but the total time for the operation decreases. This can make a perceptible difference in very large items.
#>
#where-object {$_ -like...}
ConvertFrom-CSV -Delimiter "`t" -Header $Properties| out-gridview
