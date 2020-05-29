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

[CmdletBinding()]
param (
    [Parameter(ParameterSetName = 'ExpirationDate')]
    [datetime]
    $date = (Get-Date -UFormat "%m/%d/%Y"),

    [Parameter(ParameterSetName = 'NotificationDates')]
    [string]
    $numbers = "1,7,14",

    [Parameter(ParameterSetName = 'IT')]
    [string]
    $it_department = "your IT Department",

    [Parameter(ParameterSetName = 'Phone')]
    [string]
    $phone_number = "your IT Departments phone number",

    [Parameter(ParameterSetName = 'Test')]
    [string]
    $test = $true,

    [Parameter(ParameterSetName ='Helpdesk')]
    [string]
    $helpdesk_email = "Helpdesk@Company.com",
    
    [Parameter(ParameterSetName = 'From')]
    [string]
    $no_reply = "NoReply@Company.com",

    [Parameter(ParameterSetName ='SMTP',Mandatory = $true)]
    [string]
    $smtp,

    [Parameter(ParameterSetName ='SMTP',Mandatory = $true)]
    [string]
    $subject = "Password Expiration Notice"
)

#imports the AD module, needed if this is not running on an AD server
Import-Module ActiveDirectory

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

    Add-Content -Path .\logs\PW_Expiration_$logdate.txt -Value "$Serverity $message"

}




#Body of the email
$Body = @"
Hello $UserName. This is $it_department letting you know that your Windows password will expire on the following date: $Expirydate.
If you let your password expire, you will temporarily lose access to your PC desktop, email (including phone email), file access and more.
    
To change your password, 
    1. Press Ctrl+Alt+Delete, and then click Change a password. (Remote Desktop Users Press Ctrl+Alt+End)
    2. Type your old password followed by a new password as indicated, and then type the new password again to confirm it.
    3. Press Enter.
For remote users, please log into your VPN and change your password using the RDS server and use the instructions 1-3.

If you have any questions, please email $helpdesk_email or feel free to call us at $phone_number

- $it_department Team    
"@



#Get users with password that DO expire and are ENABLED / This also converts the PW expiration from ticks to an actual date
$Users = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties "Name", "mail", "msDS-UserPasswordExpiryTimeComputed" | Select-Object "Name", "mail", @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").ToShortDateString() | Get-Date }}

#sets the $numbers variable to an integer(s) to allow for comparing numbers
$numbers = [int[]]($numbers -split ',')

#foreach loop to go through all users and 
foreach ($User in $Users) {

    $UserName = $User.Name
    $Expirydate = $User.ExpiryDate
    $email = $User.mail
    #Log Username that its checking it
    Invoke-Logging "Checking $UserName"
    
    #foreach loop to go through numbers of expiration dates
    foreach ($num in $numbers) {
        
        #if statement to check if the number of days before pw expiration hits, send email
        if ($date - $Expirydate -eq $num) {
            
            Invoke-Logging "$UserName EXPIRES in $num days, sending email to user at $email" -Severity "WARNING"
            if (!($Test)) {
                #Send-MailMessage -To $email -From $no_reply -Bcc $helpdesk_email -Subject $subjet -Body $Body -SmtpServer $smtp
                Write-Host "inside If, this would send ane email to $username to $email"
            }
            else {
                Invoke-Logging "$UserName - $email - $Expirydate - $no_reply - $helpdesk_email - $num - $it_department - $phone_number - $date "
            }

        }
        else {
            #Log that it did not meet the $num requirement
            Invoke-Logging "$Username Does Not Expire in $num days"

        }

    }

}




