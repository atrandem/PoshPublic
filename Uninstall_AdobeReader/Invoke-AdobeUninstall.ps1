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
        $AppID = (Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty | Where-Object{$_.DisplayName -like "*adobe*reader*"}).PSChildName
        if ($AppID) {
            Start-Process -FilePath msiexec -ArgumentList "/X $($AppID) /qn /norestart" -Wait -PassThru
        }
    }
}

