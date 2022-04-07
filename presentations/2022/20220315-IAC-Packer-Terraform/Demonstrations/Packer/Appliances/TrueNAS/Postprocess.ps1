Param(
    [Parameter(Position=1)]
    [string]$version

)

#Find Directory script execution
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

#Load Generic TrueNas-Appliance
[XML]$file = Get-Content "$ScriptPath/TrueNas-Appliance.xml"

#Find VMName and Disk appliance size
$DiskSize = ((Get-ChildItem $ScriptPath/output_directory *.vmdk)[0]).Length
$Name = ((Get-ChildItem $ScriptPath/output_directory *.ovf).Name).Split(".")[0]

#Replace Name Disk in generic file
for ($i = 0; $i -lt ($file.Envelope.References.File).count; $i++) {

    $Text = "#File$i#-disk-$i.vmdk" -replace(("#File$i#"),"$Name")
    $file.Envelope.References.FiLe[$i].href = $Text#
}

$file.Envelope.References.FiLe[0].size = $DiskSize
$Text = "TrueNas Appliance version: #Version# @JM2K69" -replace(("#Version#"),"$version")
$file.Envelope.VirtualSystem.AnnotationSection.Annotation = $Text
$file.Envelope.VirtualSystem.ProductSection.Version = $version

#Remove the first OVF File
Remove-Item "$ScriptPath/output_directory/$Name.ovf"
$file.Save("$ScriptPath/output_directory/$Name.ovf")

#Export to an OVA
ovftool "$ScriptPath/output_directory/$Name.ovf" "$ScriptPath/output_directory/$Name.ova"

#Move to a Folder
New-item -Name "$Name" -Path "$ScriptPath/output_directory/" -ItemType Directory | out-null
move-item  -Path "$ScriptPath/output_directory/$Name.ova" -Destination "$ScriptPath/output_directory/$Name/$Name.ova"

#Clean Directory
Get-ChildItem -Path "$ScriptPath/output_directory/" -File | Remove-Item -Force 
