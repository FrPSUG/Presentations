# First GPO 

New-GPO -Name FirstGPO1 

#Create GPO with comment

New-GPO -Name FirstGPOc -Comment "FirstGPOc"

#Create from GPOStarter

New-GPO -Name FRPSUG_firewall1 -StarterGpoName "Group Policy Remote Update firewall Ports"

New-GPO -Name FRPSUG_firewall2 -StarterGpoName "Group Policy Reporting firewall Ports" 

#Copying GPOs

Copy-GPO -SourceName FirstGPO1 -TargetName 'FirstGPO1_2'


#Removing GPOs

Get-GPO -Name FirstGPO1 | Remove-GPO

## Confirm gone in GPMC

