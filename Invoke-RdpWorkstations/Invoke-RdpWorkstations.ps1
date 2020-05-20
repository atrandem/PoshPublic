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

param (
    [Parameter(Mandatory=$false)]
    [String[]]
    $Member
    )


$CurrentValue = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"

if ($CurrentValue -eq 1) {
    #Setting RDP Access
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
    #Setting Firewall Rule
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    if (!([string]::IsNullOrWhiteSpace($Member))) {
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member "$Member"
    }
}