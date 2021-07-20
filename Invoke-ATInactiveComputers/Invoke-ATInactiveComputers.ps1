<#
.SYNOPSIS
    Disables 60+ days computers (no disabled)
    Removes 90+ days computers (already disabled)

.DESCRIPTION
    Looks for computers that are NOT disabled 60+ days old and will disable them.
    After being disabled it will move them to a disabled OU that it either finds
    or creates. Also can remove computers disabled and 90+ days of age.
.EXAMPLE
    .\Invoke-InactiveComputers.ps1 -Disable -Remove -SMTPServer "your smtp server" -From "from address" -Recipients "recipients"
.NOTES
    Created by Alex Bickford and Aaron Trandem
    Revisions:

#>

[CmdletBinding()]
param (
    [Parameter(ParameterSetName = "SendMail")]
    [switch]
    $SendMail,

    [Parameter(ParameterSetName = "SendMail")]
    [string]
    $SMTPServer,

    [Parameter(ParameterSetName = "SendMail")]
    [string]
    $From,

    [Parameter(ParameterSetName = "SendMail")]
    [string]
    $Recipients,

    [Parameter(ParameterSetName = "SendMail")]
    [string]
    $Port = "25",

    [Parameter()]
    [switch]
    $Disable,

    [Parameter()]
    [switch]
    $Remove,

    [Parameter()]
    [switch]
    $NoClean,

    [Parameter()]
    [string]
    $LogPath = 'C:\Scripts\Logs\AD-Reports'

)

Import-Module ActiveDirectory

#60 Day Variables 
$60DaysInactive = 60
$Time60 = (Get-Date).Adddays(-($60DaysInactive)) 
$60DayComp = "$LogPath\60-DayInactiveComputers.csv"

#90 Day Variables
$90DaysInactive = 90
$Time90 = (Get-Date).Adddays(-($90DaysInactive)) 
$90DayComp = "$LogPath\90-DayInactiveComputers.csv"

#SMTP Variables
$Subject = "$env:USERDOMAIN Inactive Computers"
$Body = @"
Attached is a report of Computers that are 60 days (enabled) and 90 days (disabled) old.

If the disable switch has been enabled it will disable any computers 60 days old that are still enabled and move them
to a disabled OU that either was found or created.
If the remove switch has been enabled it will remove any computers 90 days old that are disabled in AD are removed.

Disable 60 Day Computers Enabled: $Disable
Remove 90 Day Computers Enabled: $Remove
"@

#Create AD-Reports Folder
If ((Test-Path C:\Scripts\Logs\AD-Reports) -eq $false)
{
New-Item -ItemType Directory -Path C:\Scripts\Logs -Name AD-reports
}

#Get 60 Day Inactive Computers Report
$60DayList = Get-ADComputer -Filter {(LastLogonTimeStamp -lt $Time60) -and (Enabled -eq $true)} -Properties LastLogonTimeStamp |
Select-Object Name,@{Name="LastLogonDate"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | 
Sort-Object -Property Name

#Get 90 Day Inactive Computers Report
$90DayList = Get-ADComputer -Filter {(LastLogonTimeStamp -lt $Time90) -and (Enabled -eq $false)} -Properties LastLogonTimeStamp |
Select-Object Name,@{Name="LastLogonDate"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | 
Sort-Object -Property Name

#export lists to Csv
$60DayList | Export-Csv $60DayComp -NoTypeInformation -Force
$90DayList | Export-Csv $90DayComp -NoTypeInformation -Force

#If the Disable switch is true it will disable computers and move them into the Disabled OU that either was found or created.
if ($Disable) {
    
    #Checking for a OU with the name disbaled in it. Will use the first found or if non create one called Disabled Objects
    $DisabledOU = Get-ADOrganizationalUnit -Filter 'Name -like "*Disable*"' | Select-Object -ExpandProperty DistinguishedName -First 1
    If (([string]::IsNullOrWhiteSpace($DisabledOU)))
    {
        #Could not find an OU with the word disabled in it. Creating one
        New-ADOrganizationalUnit -Name "Disabled Objects"
        $DisabledOU = Get-ADOrganizationalUnit -Filter 'Name -like "Disabled Objects"' | Select-Object -ExpandProperty DistinguishedName

    }
    #Disable 60DayList Computers
    foreach ($comp in $60DayList) {
        #Disables and moves Computers to Disbaled OU
        Get-ADComputer $comp.Name | Disable-ADAccount -PassThru | Move-ADObject -TargetPath $DisabledOU
    }
}

#If the Remove switch is true it will remove computers that are older than 90 days from its last communication with AD.
if ($Remove) {
    foreach ($comp in $90DayList) {
        #Removes accounts in 90DayList
        Get-ADComputer $comp.Name| Remove-ADComputer -Confirm:$false
    }
}
#Send Email to IT Contact
if ($SendMail) {
    Send-MailMessage -From $From -To $Recipients -Body $Body -Subject $Subject -SmtpServer $SMTPServer -Attachments $60DayComp,$90DayComp -Port $Port   
}

#Clean up - Because its important!
if (!($NoClean)) {
    Remove-Item "$90DayComp"
    Remove-Item "$60DayComp"
}