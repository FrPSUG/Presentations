<#
    Parsing Data Using PowerShell \ Analyse syntaxique de données avec PowerShell
    -Francois-Xavier Cat-
#>

<#################################
#  DEMO 1 - String Manipulation  #
#################################>
# Example 1 (Parsing a file)

# Windows Update log
$file = "C:\lazywinadmin\parsing\WindowsUpdate.log"

<#
    How to read the windowsupdate.log
        https://support.microsoft.com/en-ca/kb/902093
    PROPERTIES Date,Time,PID,TID,Component,Text
#>

# Retrieve the content
$text = Get-Content -Path $file

# The content is read line by line
$text.count

# Show the content
$text

# Test our parsing on one line
$text[32]

# Split on tabulation
$text[32] -split '\t'

# Build an object
$text[32] | Foreach-object -process {
    
    # Store the current line
    $CurrentLine = $_
    
    # Split on the Tabular character
    $Info = $CurrentLine -split '\t'
    
    # Hastable with the interesting data
    $Hashtable = @{
        Date = $info[0]
        Time = $info[1]
        Message = $info[-1]
    }
    
    # Return a PowerShell Object for the current line
    New-Object -TypeName PSObject -Property $Hashtable | Select-Object -Property date,time,message
    
}



# Build an object / Apply to the rest of the file
$text | Foreach-object -process {
    
    # Store the current line
    $CurrentLine = $_
    
    # Split on the Tabular character
    $Info = $CurrentLine -split '\t'
    
    # Hastable with the interesting data
    $Hashtable = @{
        Date = $info[0]
        Time = $info[1]
        Message = $info[-1]
    }
    
    # Return a PowerShell Object for the current line
    New-Object -TypeName PSObject -Property $Hashtable | Select-Object -Property date,time,message
    
} | Out-GridView




# EXAMPLE 2 ( Adding a Filter (Where-Object))

$text |
# Filter on installed patches
Where-Object {$_ -like '*successfully installed*'} |

# Process each line
Foreach-object -process {
    # Store the current line
    $CurrentLine = $_
    
    # Split on the Tab
    $Info = $CurrentLine -split '\t'
    
    # Create a hastable
    $Hashtable = @{
        Date = $info[0]
        Time = $info[1]
        Message = $info[-1] -as [string]
    }
    
    # Return an object
    New-Object -TypeName PSObject -Property $Hashtable | Select-Object -Property date,time,message
    
    
} | Out-Gridview # Show the output



# EXAMPLE 3 (Improve performance, AVOID the pipeline)
$result = foreach ($Currentline in $text)
{
  # use if instead of where-object
  if($Currentline -like '*successfully installed*')
  {
    $info = $Currentline -split '\t'
    
    $Hashtable = @{
      Date = $info[0]
      Time = $info[1]
      Message = $info[-1]
    }
		
    # turn the hashtable into a PowerShell object
    New-Object -TypeName PSObject -Property $Hashtable | Select-Object -Property date,time,message
  }
}
$result | Out-GridView





# EXAMPLE 4 (Add custom property for KB)

# Example - Grabbing the KB using Regex
[void]("Security Update for Skype for Business 2015 (KB3114944) 64-Bit Edition" -match "KB\d+")
$Matches[0]

# Another Regex example
"Security Update for Skype for Business 2015 (KB3114944) 64-Bit Edition" -match "\((?<KB>KB\d+)\)"
$Matches['KB']

####################
$result = foreach ($Currentline in $text)
{
  # use if instead of where-object
  if($Currentline -like '*successfully installed*')
  {
    $info = $Currentline -split '\t'
    
    # Find KB
    [Void]($info[-1] -match 'KB\d+')

    $Hashtable = @{
      Date = $info[0]
      Time = $info[1]
      Message = $info[-1]
      #KB = ($info[-1] -split '\(KB')[1] -replace '\)'
      KB = $Matches[0]
    }
		
    # Output PowerShell object
    New-Object -TypeName PSObject -Property $Hashtable | Select-Object -Property date,time,message,KB
  }
}

# Show output
$result | Out-GridView




# EXAMPLE 5 (Add Link to Microsoft)
$result = foreach ($Currentline in (Get-Content -Path $file))
{
  # use if instead of where-object
  if($Currentline -like '*successfully installed*')
  {
    $info = $Currentline -split '\t'

    # Find KB
    ($info[-1] -match 'KB\d+')|Out-Null
    
    $Hashtable = @{
      Date = $info[0]
      Time = $info[1]
      Message = $info[-1]
      #KB = ($info[-1] -split '\(KB')[1] -replace '\)'
      KB = $Matches[0]
      KBLink = "https://support.microsoft.com/en-us/kb/$($Matches[0] -replace 'KB')"
    }
		
    # Output PowerShell object
    New-Object -TypeName PSObject -Property $Hashtable | Select-Object -Property date,time,message,KB, KBLink
  }
}

# Show output
$result | Out-GridView






# EXAMPLE 6 (Create your own Tools)

function Get-InstalledPatch
{
PARAM($file = "C:\lazywinadmin\parsing\WindowsUpdate.log")
    foreach ($Currentline in (Get-Content -Path $file))
    {
      # use if instead of where-object
      if($Currentline -like '*successfully installed*')
      {
        $info = $Currentline -split '\t'

        # Find KB
        #($info[-1] -match 'KB\d{6}')|Out-Null
        ($info[-1] -match 'KB\d+')|Out-Null
        
    
        $Hashtable = @{
          Date = $info[0]
          Time = $info[1]
          Message = $info[-1]
          #KB = ($info[-1] -split '\(KB')[1] -replace '\)'
          KB = $Matches[0]
          KBLink = "https://support.microsoft.com/en-us/kb/$($Matches[0] -replace 'KB')"
        }
		
        # Output PowerShell object
        New-Object -TypeName PSObject -Property $Hashtable | Select-Object -Property date,time,message,KB, KBLink
      }
    }
}

Get-InstalledPatch|ogv



