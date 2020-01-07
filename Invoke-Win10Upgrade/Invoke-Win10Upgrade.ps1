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