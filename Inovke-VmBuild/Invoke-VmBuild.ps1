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
    $CpuCount = 2,

    [Parameter(Mandatory = $true)]
    [int]
    $RamSize = 4,

    [Parameter(Mandatory = $true)]
    [int]
    $DriveSize = 120,

    [Parameter()]
    [string]
    $VmSwitch,

    [Parameter()]
    [string]
    $Generation = 2
)
    #Set Error Action to stop.
    $ErrorActionPreference = "Stop"

    #create C drive vhdx
    $VmCDrive = -join ($VmName,"_C.vhdx")

    #multiple GB of RAM by 1,073,741,824 (bytes)
    $RAM = $RamSize * 1073741824

    #mutliple GB of Drive size by 1,073,741,824 (bytes)
    $VhdSize = $DriveSize * 1073741824

    #Haven't found a good way to use the default vhd path
    try {
        New-VM -Name $VmName -MemoryStartupBytes $RAM -NewVHDPath $VmCDrive -NewVHDSizeBytes $VhdSize -Generation $Generation -SwitchName $VmSwitch
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        Write-Host "This is not a Hyper-v Server, please check if the role is installed"
        Write-Warning $Error[0]
        exit
    }
    catch {
        Write-Warning $Error[0]
        exit
    }

    #Set VM to boot to CD and attach ISO file
    #Add-VMDvdDrive -VMName $VmName -Path $IsoPath
    #Set-VMFirmware -VM $VmName -FirstBootDevice $IsoPath

    #Set CPU Count
    try {
        Set-VM $VmName -ProcessorCount $CpuCount

    }
    catch {
        Write-Warning $Error[0]
        exit
    }

     #Set Dynamic RAM (Currently only to false, future to give the option)
     try {
        Set-VMMemory $VmName -DynamicMemoryEnabled $false
    }
    catch {
        Write-Warning $Error[0]
        exit
    }