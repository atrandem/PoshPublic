<#
.SYNOPSIS
    This script will search Autotask for a offline ticket and Update/Close the ticket
.DESCRIPTION
    Kaseya monitoring will use this script when a monitored computer that is offline becomes
    online again. Kaseya Agent Procedure pass the computer name variable and more to the script.
    Using the Autotask API, it will begin to search for the affiliated ticket and update/close it
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



[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $ComputerName,

    [Parameter(Mandatory = $true)]
    [string]
    $AutomationEmail,

    [Parameter(Mandatory = $true)]
    [string]
    $KaseyaAdmins,

    [Parameter(Mandatory = $true)]
    [string]
    $SmtpServer,

    [Parameter()]
    [int]
    $LoopLimit = 15,

    [Parameter()]
    [int]
    $LoopCount = 1,

    [Parameter()]
    [int]
    $RetryTimer = 120,

    [Parameter(Mandatory = $true)]
    [string]
    $psDirectory,

    [Parameter()]
    [string]
    $Fun = "Autobots, Roll Out!"

)

#Change directory to proper location
Set-Location $psDirectory

#Here we begin the logging process for optimal troubleshooting
function Invoke-Logging {
    
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName= 'Message',Mandatory=$true)]
        [string]
        $message,

        [Parameter(ParameterSetName)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('INFO','WARNING','ERROR','DEBUG')]
        [string]$Severity = 'INFO'
    )
    [CmdletBinding(DefaultParameterSetName = 'Message')]

    $logdate = Get-Date -UFormat "%m-%d-%Y"

    Add-Content $psDirectory\logs\Kaseya-Online_$logdate.txt -Value "$Serverity $message"

}

#Logging Important Date
Invoke-Logging -message "$ComputerName : Start Logging"

#Start timing of script:
$Date = Get-Date -UFormat %D
#Due to Daylight savings we may need to add an hour...
if ((Get-Date).IsDaylightSavingTime()) {
    $StartTime = (Get-Date).AddHours(1) | Get-Date -UFormat %T
    Invoke-Logging -message "$ComputerName : Adjusting for Daylight Savings, adding 1 hour."
}
else {
    $StartTime = (Get-Date).ToUniversalTime() | Get-Date -UFormat %T
}
Invoke-Logging -message "Time Start: $StartTime"

#Here we test the ComputerName make sure its not "Empty or Null"
if ([string]::IsNullOrWhiteSpace($ComputerName)) {
    #we are going to exit the program after logging and sending an email to Script Admins
    Invoke-Logging -message "Computer name is null or white, ComputerName: $ComputerName"
    #here we send email
    $Subject = "Kaseya Online Automation Failure" 
    $Body = "Kaseya Online Failed Variable ComputerName is Null or empty. Output: $ComputerName"
    Send-MailMessage -To "$KaseyaAdmins" -From "$AutomationEmail" -Subject $Subject -Body $Body -SmtpServer $SmtpServer
    
    #here we exit script
    Exit

}

#Here Access Autotask API (Call API Script)
. ./Invoke-Autotask
Invoke-AutotaskModule

#Here we search Autotask API for Ticket Title "$ComputerName is offline"
$StatusName = @("New","10% Complete","25% Complete","50% Complete","75% Complete","90% Complete","Awaiting Parts","Awaiting Response","Follow Up","Help Desk","Postponed","To Be Assigned","Waiting Customer")

Invoke-Logging -message "$ComputerName : Searching for Title: $ComputerName is offline"
do {
    
    Invoke-Logging -message "$ComputerName : Starting Do Loop: $LoopCount"

    #for loop to go through each ticket status (except complete)
    foreach ($Status in $StatusName) {
        $TicketLookup = Get-AtwsTicket -Title "$ComputerName is offline" -Status "$Status"
        if ([string]::IsNullOrWhiteSpace($TicketLookup)) {
            #Log that it was empty
            Invoke-Logging -message "$ComputerName : No Offline ticket found with status: $Status"
        }
        else {
            #set ticket number
            $TicketNumber = $TicketLookup.TicketNumber
            $ID = $ticketLookup.ID
            #log that the ticket number:
            Invoke-Logging -message "$ComputerName : Offline Ticket Ticket Number: $TicketNumber"

            #break the loop
            Break
        }
    }

    #if all Ticketnumber is Null or Whitespace after loop Create a ticket and notify Kaseya Admins to check integrity of ticket
    if ([string]::IsNullOrWhiteSpace($TicketLookup)) {
        #we are going to exit the program after logging and sending an email to Script Admins
        Invoke-Logging -message "$ComputerName : Could not Find a ticket number, Loop Count: $LoopCount"

        Start-Sleep -Seconds $RetryTimer

    }
} while ($LoopCount -eq $LoopLimit -or [string]::IsNullOrWhiteSpace($TicketLookup))


#Check if the loop count was exceeded
if ([string]::IsNullOrWhiteSpace($TicketLookup)) {
    #we are going to exit the program after logging and sending an email to Script Admins
    Invoke-Logging -message "$ComputerName : Could not Find a ticket number"
    #here we send email
    $Subject = "Kaseya Online Automation Integrity" 
    $Body = "Kaseya Online Did not find a ticket for $ComputerName, please check integrity of ticket search. Loop count: $LoopCount "
    Send-MailMessage -To "$KaseyaAdmins" -From "$AutomationEmail" -Subject $Subject -Body $Body -SmtpServer $SmtpServer
    
    #here we exit script
    Exit

}

#Here we close the ticket or update the ticket depending on if a resource has accepted the ticket
if ([string]::IsNullOrWhiteSpace($TicketLookup.AssignedResourceID)) {
    #We will enter the API's time and then close the ticket.
    Invoke-Logging -message "Ticket has a NO Resource assigned, closing ticket."
    #We need at minimum of 1 minute, this ensures one minute is tacked onto the ticket.
    if ((Get-Date).IsDaylightSavingTime()) {
        $EndTime = (Get-Date).AddHours(1).AddMinutes(1) | Get-Date -UFormat %T
        Invoke-Logging -message "$ComputerName Adjusting for Daylight Savings, adding 1 hour."
    }
    else {
        $EndTime = (Get-Date).ToUniversalTime() | Get-Date -UFormat %T
    }
    New-AtwsTimeEntry -TicketID $ID -ResourceID "30713082" -SummaryNotes "$ComputerName is Online, closing ticket." -DateWorked $Date -RoleID "29683340" -StartDateTime "$StartTime" -EndDateTime "$EndTime" -InternalNotes "$Fun"
    Set-AtwsTicket -Id $ID -Status "Complete"
    
}
else {
    #Someone has the ticket, we will enter time, but we will leave it open for the Resource to close
    $ID = $ticketLookup.ID
    $Resource = $TicketLookup.AssignedResourceID
    #We need at minimum of 1 minute, this ensures one minute is tacked onto the ticket.
    if ((Get-Date).IsDaylightSavingTime()) {
        $EndTime = (Get-Date).AddHours(1).AddMinutes(1) | Get-Date -UFormat %T
        Invoke-Logging -message "$ComputerName : Adjusting for Daylight Savings, adding 1 hour."
        Invoke-Logging -message "$ComputerName : End time: $EndTime"
    }
    else {
        $EndTime = (Get-Date).ToUniversalTime() | Get-Date -UFormat %T
        Invoke-Logging -message "$ComputerName : End time: $EndTime"
    }
    Invoke-Logging -message "$ComputerName : Ticket has a resource assinged: $Resource"
    New-AtwsTimeEntry -TicketID $ID -ResourceID "30713082" -SummaryNotes "$ComputerName is Online." -DateWorked $Date -RoleID "29683340" -StartDateTime "$StartTime" -EndDateTime "$EndTime" -InternalNotes "$Fun"

}