<#
    Parsing Data Using PowerShell \ Analyse syntaxique de données avec PowerShell
    -Francois-Xavier Cat-
#>
<####################################
#  DEMO 4 - ConvertFrom-String  #
####################################>

$SourceFile = "c:\lazywinadmin\parsing\oui36.txt"

Gc $SourceFile

$template = @"
{mac*:E0-43-DB}   (hex)		Shenzhen ViewAt Technology Co.,Ltd. 
E043DB     (base 16)		Shenzhen ViewAt Technology Co.,Ltd. 
				9A,Microprofit,6th Gaoxin South Road, High-Tech Industrial Park, Nanshan, Shenzhen, CHINA.
				shenzhen  guangdong  518057
				{country:CN}

{mac*:24-05-F5}   (hex)		Integrated Device Technology (Malaysia) Sdn. Bhd.
2405F5     (base 16)		Integrated Device Technology (Malaysia) Sdn. Bhd.
				Phase 3, Bayan Lepas FIZ
				Bayan Lepas  Penang  11900
				{country:MY}

{mac*:2C-30-33}   (hex)		NETGEAR
2C3033     (base 16)		NETGEAR
				350 East Plumeria Drive
				San Jose  null  95134
				{country:US}
"@

Get-Content $SourceFile|
Select-Object -first 100 |
ConvertFrom-String -TemplateContent $template -ErrorAction Stop