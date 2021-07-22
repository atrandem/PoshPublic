<#
.SYNOPSIS
    Disables 60+ days users (no disabled)
    Removes 90+ days users (already disabled)

.DESCRIPTION
    Looks for users that are NOT disabled 60+ days old and will disable them.
    After being disabled it will move them to a disabled OU that it either finds
    or creates. Also can remove users disabled and 90+ days of age.
.EXAMPLE
    .\Invoke-InactiveUsers.ps1 -Disable -Remove -SMTPServer "your smtp server" -From "from address" -Recipients "recipients"
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
$60DayUser = "$LogPath\60-DayInactiveUsers.csv"

#90 Day Variables
$90DaysInactive = 90
$Time90 = (Get-Date).Adddays(-($90DaysInactive)) 
$90DayUser = "$LogPath\90-DayInactiveUsers.csv"

#SMTP Variables
$Subject = "$env:USERDOMAIN Inactive Users"
$Body = @"
Attached is a report of Users that are 60 days (enabled) and 90 days (disabled) old.

If the disable switch has been enabled it will disable any users 60 days old that are still enabled and move them
to a disabled OU that either was found or created.
If the remove switch has been enabled it will remove any users 90 days old that are disabled in AD are removed.

Disable 60 Day Users Enabled: $Disable
Remove 90 Day Users Enabled: $Remove
"@

#Create AD-Reports Folder
If ((Test-Path C:\Scripts\Logs\AD-Reports) -eq $false)
{
New-Item -ItemType Directory -Path C:\Scripts\Logs -Name AD-reports
}

#Get 60 Day Inactive Users Report
$60DayList = Get-ADUser -Filter {(LastLogonTimeStamp -lt $Time60) -and (Enabled -eq $true)} -Properties LastLogonTimeStamp |
Select-Object Name,@{Name="LastLogonDate"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | 
Sort-Object -Property Name

#Get 90 Day Inactive Users Report
$90DayList = Get-ADUser -Filter {(LastLogonTimeStamp -lt $Time90) -and (Enabled -eq $false)} -Properties LastLogonTimeStamp |
Select-Object Name,@{Name="LastLogonDate"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | 
Sort-Object -Property Name

#export lists to Csv
$60DayList | Export-Csv $60DayUser -NoTypeInformation -Force
$90DayList | Export-Csv $90DayUser -NoTypeInformation -Force

#If the Disable switch is true it will disable users and move them into the Disabled OU that either was found or created.
if ($Disable) {
    
    #Checking for a OU with the name disbaled in it. Will use the first found or if non create one called Disabled Objects
    $DisabledOU = Get-ADOrganizationalUnit -Filter 'Name -like "*Disable*"' | Select-Object -ExpandProperty DistinguishedName -First 1
    If (([string]::IsNullOrWhiteSpace($DisabledOU)))
    {
        #Could not find an OU with the word disabled in it. Creating one
        New-ADOrganizationalUnit -Name "Disabled Objects"
        $DisabledOU = Get-ADOrganizationalUnit -Filter 'Name -like "Disabled Objects"' | Select-Object -ExpandProperty DistinguishedName

    }
    #Disable 60DayList Users
    foreach ($user in $60DayList) {
        #Disables and moves Users to Disbaled OU
        Get-ADUser $user.Name | Disable-ADAccount -PassThru | Move-ADObject -TargetPath $DisabledOU
    }
}

#If the Remove switch is true it will remove users that are older than 90 days from its last communication with AD.
if ($Remove) {
    foreach ($user in $90DayList) {
        #Removes accounts in 90DayList
        Get-ADUser $user.Name| Remove-ADUser -Confirm:$false
    }
}
#Send Email to IT Contact
if ($SendMail) {
    Send-MailMessage -From $From -To $Recipients -Body $Body -Subject $Subject -SmtpServer $SMTPServer -Attachments $60DayComp,$90DayComp -Port $Port   
}

#Clean up - Because its important!
if (!($NoClean)) {
    Remove-Item "$90DayUser"
    Remove-Item "$60DayUser"
}