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

function Invoke-EmailFirstCheckIn {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [String[]]
        $Subject,

        [Parameter(Mandatory=$false)]
        [String[]]
        $SMTPServer,

        [Parameter(Mandatory=$false)]
        [String[]]
        $Sender,

        [Parameter(Mandatory=$false)]
        [String[]]
        $Recipients,

        [Parameter(Mandatory=$false)]
        [String[]]
        $Body,

        [Parameter(Mandatory=$false)]
        [String[]]
        $Attachment,

        [Parameter(Mandatory=$false)]
        [String[]]
        $Port,

        [Parameter(Mandatory=$false)]
        [String[]]
        $UserName,

        [Parameter(Mandatory=$false)]
        [String[]]
        $PWD
    )

    $Password = "$PWD" | ConvertTo-SecureString -AsPlainText -Force

    if ([string]::IsNullOrWhiteSpace($Attachment)) {
        Add-Type -Assembly "system.io.compression.filesystem"
        $Source = Get-ChildItem -Path "$PSScriptRoot\*.log" -Recurse -Force
        $Destination = "$PSScriptRoot\Logs.zip"

        [io.compression.zipfile]::CreateFromDirectory($Source, $Destination)

        $Attachment = $Destination

    }

    if ([string]::IsNullOrWhiteSpace($Body)) {
        $Body = "$env:COMPUTERNAME First Check In Complete, Please Review Logs for details"
    }

    if ([string]::IsNullOrWhiteSpace($Subject)) {
        if (Test-path -Path "$PSScriptRoot\TicketNumber.txt") {
            $TicketNumber = Get-Content -Path "$PSScriptRoot\TicketNumber.txt"
            $Subject = $TicketNumber
        }
        else {
            Subject = "$env:COMPUTERNAME First Check In Complete, No Ticket Found"
        }

    }

    Send-MailMessage -From $Sender -To $Recipients -Subject $Subject -Body $Body -DeliveryNotificationOption OnFailure -SmtpServer $SMTPServer -Credential $UserName$Password


    
}
