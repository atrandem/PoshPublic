<#
.SYNOPSIS
    Updates Win 7 to Win 10 using the extracted contents from Win 10 iso.
.DESCRIPTION
    This script updates Win 7 to Win 10 using the extracted contents from a Windows 10 iso. LanCache variable should be filled out to pull the files from
    It will, place these files locally and call the setup.exe. I highly recommend that you make sure that PowerShell 3.0 or higher is installed on the Win 7
    machine. If you do not call LANcache it will look for a text file called "Lancache.txt" with the path to the files needed. This script does allow it to
    reboot the computer when it's ready. I do use three other scripts, Invoke-Logging, Invoke-KasperskyUninstall and Invoke-AdobeReaderUninstall.  
.EXAMPLE
    Run with a manually entered Win 10 cache location:
    Invoke-Win10Upgrade -LanCache "\\Path\To\Files"
    Run using the LanCache.txt file for Win 10 cache location:
    Invoke-Win10Upgrade
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

function Invoke-Win10Upgrade {
    param (
        [Parameter(Mandatory=$false)]
        [String[]]
        $LanCache
    )

    #Version 3.0

    #Script Name/Function Name variables
    $CurrentFunction = ($MyInvocation.MyCommand)
    $PowershellScriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

    # Variables
    $script:Log = "$script:PSScriptRoot\$PowershellScriptName.log"

    #Call other needed Powershell Scripts
    $ExternalMethod = $PSScriptRoot + ".\Invoke-Logging.ps1"
    .$ExternalMethod

    if ($LanCache) {
        Invoke-Logging -Message "LanCache Was manually set: $LanCache" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $script:Log
    }
    else {
        Invoke-Logging -Message "Searching For LanCache.txt" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $script:Log
        if (Test-Path -Path "$PSScriptRoot\LanCache.txt") {
            $LanCache = Get-Content -Path "$PSScriptRoot\LanCache.txt"
            Invoke-Logging -Message "LanCache was set: $LanCache" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $script:Log
        }
        else {
            Invoke-Logging -Message "LanCache wasn't found, exiting script" -Severity Warning -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $script:Log
            Exit-PSSession
        }   
    }
    
    #Adobe Reader will break. Uninstalling it.
    Invoke-Logging -Message "Uninstalling Adobe Reader" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $script:Log
    $ExternalMethod = $PSScriptRoot + ".\Invoke-AdobeReaderUninstall.ps1"
    .$ExternalMethod

    #KAV Will Stop The Upgrade. Uninstalling it.
    Invoke-Logging -Message "Uninstalling Adobe Reader" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $script:Log
    $ExternalMethod = $PSScriptRoot + ".\Invoke-KasperskyUninstall.ps1"
    .$ExternalMethod

    #Copying Win10 to local computer
    Invoke-Logging -Message "Begin Copying Win10 Folder from $LanCache" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $script:Log
    Copy-Item -Path "$LanCache\Win10" -Destination "$PSScriptSession\Win10" -Recurse

    #Run the setup file, accepting defaults and EULA's.
    Invoke-Logging -Message "Running Win 10 Upgrade, A reboot will Happen" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $script:Log
    Start-Process -FilePath "setup.exe" -WorkingDirectory "$PSScriptRoot\Win10" -ArgumentList "/Auto Upgrade /Quiet /DynamicUpdate Disable"
    Invoke-Logging -Message "Finished, Win 10 Upgrade still might be processing" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $script:Log
}