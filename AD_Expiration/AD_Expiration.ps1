<#
##====================================================================================
	Version Number
##===================================================================================#
1.4.1
Creator Aaron Trandem
##====================================================================================
	Instructions
##===================================================================================#
For this script to run successfully, please put it in C:\Scripts
To use this script you will need to fill in the following variables:
# Test Variables
Test, TestAdmin, TestRecipient, TestSender, TestSMTPServer
#Email Variables
BCC, Recipients, SMTPServer, Admin, Sender, HelpDesk
#Script Variables
ReportDate
#Company Info Variables
PhoneNumber, CompanyName, MSP

It is important to put a logo.png in C:\scripts for the HTML Report.
It should shrink it down to a 120 width x 500 height

I run this script in task scheduler with the following directions
* Create New Task
** Give it a Name
** Run whether user is logged on or not, run with the highest privledges
*Triggers: Set it to run daily (even the weekend) at whatever time you want. I like 9 AM
*Actions: Browse to C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
** Argument: ./AD_Expiration.ps1
** Start in "C:\Scripts"

Please make sure to test this in your enviroment before releasing into the production
Testing is set to True, set to $False when implementing into production
##====================================================================================
	Modules Needed
##===================================================================================#

    Active Directory - To connect to AD

#>

#Modules
Import-Module ActiveDirectory


#Test Variables
#Set Testing to True for troubleshooting problems
$script:Test = $True
$script:TestAdmin = ""
$script:TestRecipient = ""
$script:TestSender = ""
$script:TestSMTPServer = ""

#Email Variables
$script:Subject = "User Password Expiration Report"
$script:Recipients = "Report Email address(es) Here"
$script:BCC = "HelpDesk Email Here"

$script:SMTPServer = "STMP Server FQDN or IP Address Here"
$script:Admin = "Admin Email adddress here"
$script:Sender = "NoReply@domainName.com change domain name"
$script:HelpDesk = "HelpDesk Email Here"

#Script Variables
[string]$script:RootLog = "C:\Scripts\Logs"
[string]$script:LogDate = Get-Date -Format "yyyy-MM-dd"
[string]$script:LogPath = "C:\Scripts\Logs\PwExp"
[string]$script:ArchivePath = "C:\Scripts\Logs\PwExp\Archive"
[string]$script:HTMLPath = "C:\Scripts\Logs\PwExp\User Password Expiration Report.htm"
$script:Expired = @()
$script:1Day = @()
$script:7Day = @()
$script:14Day = @()
$script:90Day = @()
[string]$script:Log = "C:\Scripts\Logs\PwExp\PW_Expiration_$script:LogDate.txt"
$script:ReportDate = "Monday"

#Company Info Variables
$script:MSP = "MSP name here"
$script:CompanyName = "Company Name Here"
$script:PhoneNumber = "Enter Help Desk Phone Number"

function Get-ADUserInfo {
    [int]$iExpired = "1"
    [int]$i1 = "1"
    [int]$i7 = "1"
    [int]$i14 = "1"
    [int]$i90 =  "1"
    [datetime] $TodayTicks = (Get-Date).ToShortDateString()
    [datetime] $1Ticks = (Get-Date).AddDays(1).ToShortDateString()
    [datetime] $7Ticks = (Get-Date).AddDays(7).ToShortDateString()
    [datetime] $14Ticks = (Get-Date).AddDays(14).ToShortDateString()
    


    Get-ADUser -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $True} -Properties "Name", "PwdLastSet" `
        | Select-Object -Property "Name",@{Name="PwdLastSet";Expression={[datetime]::FromFileTime($_."PwdLastSet")}} | Sort-Object -Property "PwdLastSet" `
        |  Export-Csv "$script:LogPath\Users With Passwords That Do Not Expire.csv" -NoTypeInformation 

    $Users = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties "Name", "mail", "msDS-UserPasswordExpiryTimeComputed" `
        | Select-Object "Name", "mail", @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").ToShortDateString() }}

    ForEach ($User in $Users) {

        [datetime] $ConvertDate = $User.ExpiryDate
        [datetime] $ExpireDate = $ConvertDate.ToShortDateString()
        $ExpireTicks = $ExpireDate.Ticks
        
        If ($ExpireTicks -eq $14Ticks.Ticks) {
            $script:14Day += New-Object -TypeName PSObject -Property @{Key = $i14; Name=$User.Name; Email=$User.mail; ExpiryDate=$User.ExpiryDate}
            $i14++
            "$(Get-Date) PW Exp Found: 14 Day $User.Name" | Out-File -FilePath $script:Log -Append -Encoding ascii
        }

        elseIf ($ExpireTicks -eq $7Ticks.Ticks) {
            $script:7Day += New-Object -TypeName PSObject -Property @{Key = $i7; Name=$User.Name; Email=$User.mail; ExpiryDate=$User.ExpiryDate}
            $i7++
            "$(Get-Date) PW Exp Found: 7 Day $User.Name" | Out-File -FilePath $script:Log -Append -Encoding ascii
        }

        elseIf ($ExpireTicks -eq $1Ticks.Ticks) {
            $script:1Day += New-Object -TypeName PSObject -Property @{Key = $i1; Name=$User.Name; Email=$User.mail; ExpiryDate=$User.ExpiryDate}
            $i1++
            "$(Get-Date) PW Exp Found: 1 Day $User.Name" | Out-File -FilePath $script:Log -Append -Encoding ascii
        }

        elseIf ($ExpireTicks -lt $TodayTicks.Ticks) {
            $script:Expired += New-Object -TypeName PSObject -Property @{Key = $i1; Name=$User.Name; Email=$User.mail; ExpiryDate=$User.ExpiryDate}
            $iExpired++
            "$(Get-Date) PW Exp Found: $User.Name" | Out-File -FilePath $script:Log -Append -Encoding ascii
        }
        
        else {
            $script:90Day += New-Object -TypeName PSObject -Property @{Key = $i90; Name=$User.Name; Email=$User.mail; ExpiryDate=$User.ExpiryDate}
            $i90++
        }
    }
}
function Get-HTMLReport {
    #set your own default graphic or delete default value
[string]$ImagePath = "C:\Scripts\Logo.png"

$CSVS = Get-ChildItem -Name "C:\Scripts\Logs\PwExp\*.csv"

$fragments = @()
 
if (Test-Path $ImagePath) {
    #insert a graphic
    $ImageBits =  [Convert]::ToBase64String((Get-Content $ImagePath -Encoding Byte))
    $ImageFile = Get-Item $ImagePath
    $ImageType = $ImageFile.Extension.Substring(1) #strip off the leading .
    $ImageTag = "<Img src='data:image/$ImageType;base64,$($ImageBits)' Alt='$($ImageFile.Name)' style='float:left' width='500' height='120' hspace=10>"
    "$(Get-Date) Image File Found" | Out-File -FilePath $script:Log -Append -Encoding ascii
}
else {
    "$(Get-Date) Could not find image file $ImagePath" | Out-File -FilePath $script:Log -Append -Encoding ascii
}

#CSS/HTML Settings

$top = @"
<table class = "tableheader">
<tr>
<td class='transparent'>$ImageTag</td><td class='transparent'><H1>User Password Expiration Report</H1></td>
</tr>
</table>
"@

$bottom = @"
<script>
var coll = document.getElementsByClassName("collapsible");
var i;

for (i = 0; i < coll.length; i++) {
  coll[i].addEventListener("click", function() {
    this.classList.toggle("active");
    var content = this.nextElementSibling;
    if (content.style.display === "block") {
      content.style.display = "none";
    } else {
      content.style.display = "block";
    }
  });
}
</script>
"@

$head = @"
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
.collapsible {
    background-color: #777;
    color: white;
    cursor: pointer;
    padding: 18px;
    width: 100%;
    border: none;
    text-align: left;
    outline: none;
    font-size: 15px;
}

.active, .collapsible:hover {
    background-color: #555;
}

.content {
    padding: 0 18px;
    display: none;
    overflow: hidden;
    transition: max-height 0.2s east-out;
    background-color: #f1f1f1;
}
    
.collapsible:after {
    content: '\02795'; /* Unicode character for "plus" sign (+) */
    font-size: 13px;
    color: white;
    float: right;
    margin-left: 5px;
}

.active:after {
    content: "\2796"; /* Unicode character for "minus" sign (-) */
}

td, th { 
    border:0px solid black; 
    border-collapse:collapse;
    white-space:pre; 
}
th { 
    color:white;
    background-color:black;
}
table, tr, td, th { 
    padding: 2px;
    margin: 0px ;
    white-space:pre;
}
tr:nth-child(odd) {
background-color: lightgray;
}

table.tableheader {}
table.tableheader tr {
    border: none;
    background: transparent;
}
table.tablehearder {}

</style>
 
"@ 


#First Fragment
$fragments+=$top


ForEach ($CSV in $CSVS)

{

$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($CSV)

#Creates Collapsable Button
$fragments+= "<button class=""collapsible"">$BaseName</button>"

#Start <div>
$fragments+= "<div class = ""content"">"
#Imports the CSV into a HTML Table Fragment
$fragments+= Import-Csv "$script:LogPath\$CSV" | ConvertTo-Html -Fragment

#End </div>
$fragments+= "</div>"

}


#Always LAST fragment
$fragments+=$bottom


$convertParams = @{ 
  head = $head 
  body = $fragments
}
 
convertto-html @convertParams | out-file -FilePath $HTMLPath
    
}
function Test-LogFolder {
    "$(Get-Date) Log Folder: Checking if Log folders are present" | Out-File -FilePath $script:Log -Append -Encoding ascii
    if (![System.IO.Directory]::Exists($RootLog)){
        [System.IO.Directory]::CreateDirectory($RootLog)
        "$(Get-Date) Log Folder: Created Log File" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }
    else {
        "$(Get-Date) Log Folder: Exists" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }
    if (![System.IO.Directory]::Exists($script:LogPath)){
        [System.IO.Directory]::CreateDirectory($script:LogPath)
        "$(Get-Date) CSV Path: Created CSV Path" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }
    else {
        "$(Get-Date) CSV Path: Exists" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }
    if (![System.IO.Directory]::Exists("$script:ArchivePath")) {
        [System.IO.Directory]::CreateDirectory("$script:ArchivePath")
        "$(Get-Date) Archive Path: Created Archive Path" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }
    else {
        "$(Get-Date) Archive Path: Exists" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }
    
}
function Send-EmailReport {

$Body = @"

Attached is your user password expiration report for $script:CompanyName.
If you have any questions, please follow up with $script:MSP via $HelpDesk.


- $script:MSP IT Team

"@

if ($Test -eq $True) {
    Send-MailMessage -From $script:TestSender -To $script:TestAdmin -Subject $Subject -Body $Body -Attachment $HTMLPath -DeliveryNotificationOption onFailure -SmtpServer $script:SMTPServer
}
else {
    Send-MailMessage -From $script:Sender -To $Recipients -Bcc $script:BCC -Subject $Subject -Body $Body -Attachment $HTMLPath -DeliveryNotificationOption onFailure -SmtpServer $script:SMTPServer
}

}
function Export-ToCSV {
    if ($script:14Day.Count -gt 0){
        $script:14Day | Select-Object -Property Name, ExpiryDate | Sort-Object ExpiryDate | Export-Csv -Path "$script:LogPath\14 Days Before Password Expiration.csv" -NoTypeInformation -Append
        "$(Get-Date) Export CSV: 14 Day" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }    
    if ($script:7Day.Count -gt 0) {
        $script:7Day | Select-Object -Property Name, ExpiryDate | Sort-Object ExpiryDate | Export-Csv -Path "$script:LogPath\7 Days Before Password Expiration.csv" -NoTypeInformation -Append
        "$(Get-Date) Export CSV: 7 Day" | Out-File -FilePath $script:Log -Append -Encoding ascii        
    }
    if ($script:1Day.Count -gt 0){
        $script:1Day | Select-Object -Property Name, ExpiryDate | Sort-Object ExpiryDate | Export-Csv -Path "$script:LogPath\1 Day Before Password Expiration.csv" -NoTypeInformation -Append
        "$(Get-Date) Export CSV: 1 Day" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }
    if ($script:Expired.Count -gt 0){
        $script:Expired | Select-Object -Property Name, ExpiryDate | Sort-Object ExpiryDate | Export-Csv -Path "$script:LogPath\Password Expired.csv" -NoTypeInformation -Append
        "$(Get-Date) Export CSV: Expired" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }  
    if ($script:90Day.Count -gt 0) {
        $script:90Day | Select-Object -Property Name, ExpiryDate | Sort-Object ExpiryDate | Export-Csv -Path "$script:LogPath\All Password Expiration.csv" -NoTypeInformation -Append
        "$(Get-Date) Export CSV: 90 Day" | Out-File -FilePath $script:Log -Append -Encoding ascii
             
    }
}
function Start-Cleanup {
    Remove-Item -Path $script:LogPath -Include *.csv -Recurse -Verbose | Out-File -FilePath $script:Log -Append -Encoding ascii

    if ([System.IO.File]::Exists("$Script:HTMLPath")) {
        "$(Get-Date) Delete Item: HTML Report" | Out-File -FilePath $script:Log -Append -Encoding ascii   
        Remove-Item -Path "$Script:HTMLPath"
        if ([System.IO.File]::Exists("$Script:HTMLPath")) {
            "$(Get-Date) Delete Item: HTML Report Still Exists" | Out-File -FilePath $script:Log -Append -Encoding ascii
        }
        else {
            "$(Get-Date) Delete Item: HTML Report was Deleted" | Out-File -FilePath $script:Log -Append -Encoding ascii
        }
    }
}
function Send-EmailIndividual  {
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $Users
    )

    foreach ($User in $Users) {
        #Variables
        $Name = $User.Name
        $Recipients = $User.Email
        $ExpiryDate = $User.ExpiryDate
        $Subject = "Password Expiration Warning"
        $Body = @"
    
        Hello $Name. This is $script:MSP letting you know that your Windows password will expire on the following date: $Expirydate.
        If you let your password expire, you will temporarily lose access to your PC desktop, email (including phone email), file access and more.
            
        To change your password, 
            1. Press Ctrl+Alt+Delete, and then click Change a password. (Remote Desktop Users Press Ctrl+Alt+End)
            2. Type your old password followed by a new password as indicated, and then type the new password again to confirm it.
            3. Press Enter.
        For remote users, please log into your VPN and change your password using the RDS server and use the instructions 1-3.

        If you have any questions, please email $HelpDesk or feel free to call us at $PhoneNumber

        - $script:MSP IT Team    
    
"@
       #For Easier Testing
        if ($Test -eq $True) {
            Write-Host "Hi, can you see me?"
            Write-Host "$Recipients"
            Write-Host "$Subject"
            Write-Host "$Name"
            Write-Host "$ExpiryDate"
            Write-Host "$Recipients"
            Write-Host "$Body"
            Send-MailMessage -From $script:TestSender -To $script:TestRecipient -Subject $Subject -Body $Body -DeliveryNotificationOption OnFailure -SmtpServer $script:TestSMTPServer
        }
        else {
            #Write-Host "Test Not True"
            Send-MailMessage -From $script:Sender -To $Recipients -Bcc $script:HelpDesk -Subject $Subject -Body $Body -DeliveryNotificationOption onFailure -SmtpServer $script:SMTPServer
        }
    }   
}
function Start-Archive {
    $Day = (Get-Date).Day
    $LastMonth = (Get-Date).AddMonths(-1).Month
    $Year = (Get-Date).Year
    $EOM = [DateTime]::DaysInMonth($Year, $LastMonth)
    if ($Day -eq "1") {
        $AM = "$Year-$LastMonth"
        [DateTime] $StartDate = "$LastMonth/1/$Year"
        [DateTime] $EndDate = "$LastMonth/$EOM/$Year"
        $txts = Get-ChildItem -Name "$LogPath\*txt"

        "$(Get-Date) Archive Logs: End of Month Begin Archival" | Out-File -FilePath $script:Log -Append -Encoding ascii
        New-Item -Path "$LogPath" -ItemType Directory -Name "$AM"
        "$(Get-Date) Archive Logs: $AM Directory Made" | Out-File -FilePath $script:Log -Append -Encoding ascii

        foreach ($txt in $txts) {
            $txtCL = Get-ItemProperty -Path "$LogPath\$txt" | Select-Object -ExpandProperty CreationTime

            if ($txtCl -ge $startDate -and $txtCL -le $EndDate) {
                #"$(Get-Date) Archive Logs: Moving $txt to $AM " | Out-File -FilePath $script:Log -Append -Encoding ascii
                Move-Item -Path "$LogPath\$txt" -Destination "$LogPath\$AM"
                #"$(Get-Date) Archive Logs: Moved $txt to $AM " | Out-File -FilePath $script:Log -Append -Encoding ascii
            }
            else {
                #Write-Host "It's out of the date range"
            }
        }

        Compress-Archive -Path "$LogPath\$AM" -DestinationPath "$ArchivePath\$AM" |Out-Null
        #"$(Get-Date) Archive Logs: Created Zipped File in $ArchivePath\$AM" | Out-File -FilePath $script:Log -Append -Encoding ascii
        if ([System.IO.Directory]::Exists("$LogPath\$AM")) {
            #"$(Get-Date) Log Folder: Zipped File Exists, Removing $AM Folder" | Out-File -FilePath $script:Log -Append -Encoding ascii
            Remove-Item -Path "$LogPath\$AM" -Recurse
            #"$(Get-Date) Log Folder: Remove $AM Folder" | Out-File -FilePath $script:Log -Append -Encoding ascii
        }
        else {
            #"$(Get-Date) Log Folder: MISSING $AM Folder" | Out-File -FilePath $script:Log -Append -Encoding ascii
        }
    }
    else {
        "$(Get-Date) Log CleanUp: Not a new month" | Out-File -FilePath $script:Log -Append -Encoding ascii
    }
}
<##====================================================================================
    Begin Code
##===================================================================================#>

Test-LogFolder

Get-ADUserInfo

if ((Get-Date).DayOfWeek -eq "$script:ReportDate") {
    Export-ToCSV
    Get-HTMLReport
    Send-EmailReport
}

if ($script:14Day.Count -gt 0) {
    Send-EmailIndividual -Users $script:14Day
}
if ($script:7Day.Count -gt 0) {
    Send-EmailIndividual -Users $script:7Day
    
}
if ($script:1Day.Count -gt 0) {
    Send-EmailIndividual -Users $script:1Day
}


Start-Cleanup
Start-Archive
