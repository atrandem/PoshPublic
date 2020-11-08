<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>



[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $VmName,

    [Parameter(Mandatory = $true)]
    [string]
    $OsVersion,

    <#future?
    [Parameter(Mandatory = $true)]
    [int]
    $NumberOfDrives,
    #>

    [Parameter(Mandatory = $true)]
    [int]
    $RAM,

    [Parameter(Mandatory = $true)]
    [array]
    $DriveSize,

    [Parameter()]
    [string]
    $VmSwitch
)

   
    #create c_drive vhdx
    $VmCDrive = -join ($VmName,"_C.vhdx")

    New-VM -Name $VmName -MemoryStartupBytes "$RAM""GB" -BootDevice CD -VHDPath $VmCDrive  -Generation 2 -SwitchName $VmSwitch

    #Attach ISO file
    #Add-VMDvdDrive -VMName $VmName -Path $IsoPath
    
