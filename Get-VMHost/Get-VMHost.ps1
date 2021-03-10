<#
.SYNOPSIS
    Finds Hyper-V VM's host from Registry
.DESCRIPTION
    Gets the host name of a VM searching a registry key. This only works for Hyper-V. If run on a VM under VMware,
    it will state that it cannot find the key and might be VMware.
    The result will be dropped into a txt file called "VM-Host.txt". Default location is C:\Scripts\Logs, but can be changed
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Created by Aaron Trandem
#>


[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $VMName,

    [Parameter()]
    [String]
    $LogPath = "C:\Scripts\Logs"
)

#script block if reaching out to VM
$ScriptBlock = 
{
    try {
        if (Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters') {
            $Output = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters\' | Select-Object 'PhysicalHostName' | Format-Table -HideTableHeaders | Out-String).Trim()        
        }
        else {
            Write-Host "Inside 2nd ELSE"
            $Output = "VMware or No Key"
        }
        $Output
    }
    catch {
        $Output = "Error"
    }
}

#Checks VMName, if its NOT empty, it will try to make a Remote Connection to run the command and it will dump the file in
if ($VMName) {

    try {
        $result = Invoke-Command -ComputerName "$VMName" -ScriptBlock $ScriptBlock -ErrorAction Stop
        $result | Out-File -FilePath "$Log\VM-Host.txt"
        }
    catch {
        $Output = "Connection Error" | Out-File -FilePath "$LogPath\VM-Host.txt"
    }
}
else {
    if (Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters') {
        
        $Output = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters\' | Select-Object 'PhysicalHostName' | Format-Table -HideTableHeaders | Out-String).Trim()        
    }
    else {
        $Output = "VMware or No Key"
    }
    $Output | Out-File -FilePath "$LogPath\VM-Host.txt"
}






