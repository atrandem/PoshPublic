<#
.SYNOPSIS
    Either install or unintall Datto File Protect
.DESCRIPTION
    Long description
.EXAMPLE
    .\Invoke-DattoFileProtect.ps1 -Install -Path C:\Temp
    .\Invoke-DattoFileProtect.ps1 -Uninstall -Path C:\Temp
    .\Invoke-DattoFileProtect.ps1 -Install
    .\Invoke-DattoFileProtect.ps1 -Uninstall
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Created By Aaron Trandem
#>

[CmdletBinding(DefaultParameterSetName='None')]
param (
    [Parameter(Mandatory=$true, ParameterSetName='Install')]
    [Parameter(Mandatory=$true, ParameterSetName='Uninstall')]
    [string[]]
    $Path,

    [Parameter(Mandatory=$true, ParameterSetName='Install')]
    [string[]]
    $Install,

    [Parameter(Mandatory=$true, ParameterSetName='Uninstall')]
    [string[]]
    $Uninstall
)

Invoke-WebRequest -Uri "https://us.fileprotection.datto.com/update/aeb/DattoFileProtectionSetup_v8.1.0.59.exe" -OutFile "$Path\DattoFileProtect.exe" -UseBasicParsing

if ($PSCmdlet.ParameterSetName -eq 'Install') {
    Write-Output "Installing with path: $Path"
    Start-Process -FilePath "$Path\DattoFileProtect.exe" -ArgumentList "/install /quiet /norestart" -Wait
}

if ($PSCmdlet.ParameterSetName -eq 'Uninstall') {
    Write-Output "Uninstalling with path: $Path"
    Start-Process -FilePath "$Path\DattoFileProtect.exe" -ArgumentList "/uninstall /quiet /norestart" -Wait
}

#End