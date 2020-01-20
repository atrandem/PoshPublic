<#
.SYNOPSIS
    Uninstall Symantec End Point Protection (AV)
.DESCRIPTION
    This will uninstall adobe reader I took the information from https://www.reddit.com/r/PowerShell/comments/8h1s2u/powershell_script_to_uninstall_software/
    and built a function out of it. You can pass the GUID or let it search the registry for it.
.EXAMPLE
    Invoke-AdobeReaderUninstall
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Credit goes to these fine people on reddit https://www.reddit.com/r/PowerShell/comments/8h1s2u/powershell_script_to_uninstall_software/
#>

function Invoke-AdobeReaderUninstall {
    param (
    [Parameter(Mandatory=$false)]
    [String[]]
    $AppID
    )
    
    if($AppID) {
        Start-Process -FilePath msiexec -ArgumentList "/X $($AppID) /qn /norestart" -Wait -PassThru
    }
    else {
        $AppID = (Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty | Where-Object{$_.DisplayName -like "*Symantec*"}).PSChildName
        if ($AppID) {
            Start-Process -FilePath msiexec -ArgumentList "/X $($AppID) /qn /norestart" -Wait -PassThru
        }
    }
}

