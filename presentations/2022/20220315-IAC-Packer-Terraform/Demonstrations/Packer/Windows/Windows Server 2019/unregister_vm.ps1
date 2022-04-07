Param(
    [Parameter(Position=1)]
    [string]$VISERVER,

    [Parameter(Position=2)]
    [string]$VIUSERNAME,

    [Parameter(Position=3)]
    [string]$VIPASSWORD,

    [Parameter(Position=4)]
    [string]$VMNAME
)

Connect-VIServer -Server "$VISERVER" -User "$VIUSERNAME" -Password "$VIPASSWORD"
Get-VM "$VMNAME" | remove-VM -DeletePermanently -confirm:$false
Disconnect-VIServer * -Confirm:$false