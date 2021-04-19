<#
.SYNOPSIS
    Installs MXIE
.DESCRIPTION
    This will check if MXIE is installed, uninstall it and then install the new version.
    This will remove the signin settings in MXIE
.EXAMPLE
    .\Start-MxieUpdate.ps1 -msi 'PathToMSI.msi"
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Created by: Aaron Trandem
    Created on: 4/8/2021
    Changes Made:
#>


[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $msi,

    [Parameter()]
    [string]
    $WanPath,

    [Parameter()]
    [string]
    $LanPath,

    [Parameter()]
    [swtich]
    $32 = $false

)

if (Test-Path -Path "$LanPath") {
    #Copy the file from the path
}
else {
    #Copy the path from external
    Invoke-WebRequest
}
#Check if MXIE is isntalled
$mxie = Get-WMIObject -Class Win32_Product | Where-Object {$_.Name -eq "MXIE"}

if ([string]::IsNullOrWhiteSpace($mxie)) {
    #Cant find install of MXIE. Run install
    Write-Host "in if"
    msiexec.exe /i $msi /quiet /qn
}
else {
    #MXIE installed, will uninstall then install
    Write-Host "in else"
    #uninstalling
    $mxie.Uninstall()
    
    #installing mxie
    msiexec.exe /i $msi /quiet /qn
}