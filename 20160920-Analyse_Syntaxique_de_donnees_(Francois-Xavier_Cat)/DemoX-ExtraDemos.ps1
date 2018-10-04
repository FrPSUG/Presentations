<##############################
#  DEMO X - Additional Demos  #
##############################>


# Using Select-String

$VendorListpath = "C:\lazywinadmin\parsing\oui.txt"
$Vendor = '74-F4-13'

$r=Select-String -Path $vendorListPath -Pattern $vendor -context 0,5
$line = $r.Line
$r.context.postcontext|Select-Object -Skip 1


# Using Convert-String (PS v5)

# Format Names
"Francois-Xavier Cat", "Stephane Van Gulick", "Fabien Dibot", "Micky Balladelli", "Emin Atac" |
Convert-String -Example "Francois-Xavier Cat=Cat, F."

# Format Phone Numbers
1..10 | 
   foreach { [math]::Round((get-random -Minimum 1e9 -Maximum 9e9)) } | 
   Convert-String -Example '0123456789=(012) 345-6789'




   
   

# Using ConvertFrom-StringData
$Here = @'
Msg1 = Info1
Msg2 = Info2
Msg3 = Info3
'@
ConvertFrom-StringData -StringData $Here


ConvertFrom-StringData -StringData @'
ScriptName = Disks.ps1

# Category is optional.

Category = Storage
Cost = Free
'@


$TextMsgs = DATA {
ConvertFrom-StringData @'
Text001 = Some Text here1
Text002 = Some Text here2
'@
}
$TextMsgs.Text001
$TextMsgs.Text002


# Using Stream Reader
$FilePath = "C:\LazyWinAdmin\parsing\Archives\largelog01.s"
# Create a StreamReader object
$StreamReader = New-object -TypeName System.IO.StreamReader -ArgumentList (Resolve-Path -Path $FilePath -ErrorAction Stop).Path

while ($StreamReader.Peek() -gt -1) #lire le prochain character sans le consommer
{
    # Read the next line
    #  .ReadLine() method: Reads a line of characters from the current stream and returns the data as a string.
    $Line = $StreamReader.ReadLine()
				
    #  Ignore empty line and line starting with a #
    if ($Line.length -eq 0 -or $Line -match "^#")
    {
	    continue
    }

    # Split the Line
    $result = ($Line -split '\s')

    # Get the domain
    $DomainName = (((($result[6] -split "://")[1] -split '/')[0]) -split '\.')
    $DomainName = $DomainName[-2],$DomainName[-1] -join '.'

    # Generate Object
    New-Object -TypeName PSObject -Property @{
		"TimeStamp" = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($result[0]))
		"ElapseTime" = $result[1] #%e Example: 546
		"ClientIP" = $result[2]
        "DomainName" = $DomainName
        "HttpStatus" = $result[3]
    }
}