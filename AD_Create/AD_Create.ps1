<#
##====================================================================================
	Creator
##===================================================================================#
Aaron Trandem
##====================================================================================
	Current Version #
##===================================================================================#
Version 1.0
##====================================================================================
	Supported OS's
##===================================================================================#
	Windows XP - No		Server 2008 - No
	Windows 7 - No		Server 2008R2 - No
	Windows 10 - Yes	Server 2012 - No
	Server 2012R2 - No	Server 2016 - No
	Server 2019 - No
##====================================================================================
	Future Goals
##===================================================================================#

Assign o365 license if available - give options for type of license 
to assign?
Group Add
Mirror Another User

##====================================================================================
	READ-ME
##===================================================================================#
The objective of this script is to create the AD user properly and sync it to O365 or 
let that naturally happen. Company specifics have been added to this script, OU user 
placement, UPN suffix/Email suffix, AD Azure Sync Server, and Email relay.

For security, TLS connectors in o365 should be setup for this to keep the email from 
being sent in plain text.

##====================================================================================
	Change Notes
##===================================================================================#
* 06/11/2019 Scripts inception
* 06/14/2019 Finished up version 1.0 Further changes will change versioning after this
** point.
* 06/17/2019 Added in a preReq function to load modules and check for the log path.
* 06/17/2019 Began adding in the SSH console to allow me to get details from csv file
* 07/03/2019 Cleaned up information prepped for public git.


##====================================================================================
	Bugs
##===================================================================================#


##====================================================================================
	Modules Needed
##===================================================================================#

    Active Directory - To connect to AD

#>
<##====================================================================================
	Testing Variable
##===================================================================================#>
$Debug = $true

<##====================================================================================
	Error Preference
##===================================================================================#>


<##====================================================================================
	SCRIPT GLOBALS
##===================================================================================#>  


#For "security" I will import from a csv data so this does not have hard coded customer info
$script:PickupInfo = Import-Csv C:\Scripts\Logs\InfoPickup\AdCreatePickupInfo.csv


$script:LogPath "C:\Scripts\Logs"
$script:O365SyncServer = $script:PickupInfo.ADSyncServer
$script:OuPath = $script:PickupInfo.OuPath
$script:LogDate = Get-Date -Format "yyyy-MM-dd"
$script:ScriptName = $MyInvocation.MyCommand.Name
$script:Log = "$script:ScriptName.txt"



<##====================================================================================
	FUNCTIONS
##===================================================================================#>
function PreReq {
	#check for existence of LogPath
	if (![System.IO.Directory]::Exists($script:LogPath)){
        [System.IO.Directory]::CreateDirectory($script:LogPath)
	}
	#check for modules
	if (!(Get-Module -Name ActiveDirectory)) {
		Install-Module ActiveDirectory
	}
	if (!(Get-Module -Name Posh-SSH)) {
		Install-Module -Name Posh-SSH
	}
	Import-Module ActiveDirectory
	Import-Module Posh-SSH
}
function DataPull {
	
	New-SFTPSession -ComputerName smitsftp.getsuperiorit.com -Credential ()
}
function Logging102 {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FunctionName
	)
	
	Write-Output "$(Get-Date) - $FunctionName - $Severity - $Message" | Out-File -FilePath "C:\Scripts\Logs\$script:Log" -Append -Encoding ascii
	if ($Debug -eq $True) {
		Write-Host $script:ScriptName
		Write-Host $script:Log
	}
}
function Get-BasicInfo {

	$CurrentFunction = ($MyInvocation.MyCommand)

	#This doesn't fully do what I want, but it will ensure the first byte is a letter a-z	
	do {
			$FirstName = Read-Host -Prompt "Enter First Name"
		
	} until ($FirstName -match '^[a-zA-Z]' -eq "True")
		
	do {
		$LastName = Read-Host -Prompt "Enter Last Name"
	} until ($LastName -match '^[a-zA-Z]' -eq "True")

	do {
		$MI = Read-Host -Prompt "Enter Middle Initial"
	} until ($MI -match '^[a-zA-Z]' -eq "True")

	if ($MI.Length -gt 1) {
		$MiddleName = $MI.Substring(0,1)
	}


	#dumb but I had to set the param variables to the script variables after.
	#Using this chance to keep it clean by capatilizing first letters... Cause you know, people...
	$script:FirstName = (Get-Culture).TextInfo.ToTitleCase($FirstName)
	$script:LastName = (Get-Culture).TextInfo.ToTitleCase($LastName)
	$script:MiddleName = (Get-Culture).TextInfo.ToTitleCase($MiddleName)

	

	Logging102 -Message "First Name - $script:FirstName" -Severity Information -FunctionName $CurrentFunction
	Logging102 -Message "Middle Initial - $script:MiddleName" -Severity Information -FunctionName $CurrentFunction
	Logging102 -Message "Last Name - $script:LastName" -Severity Information -FunctionName $CurrentFunction

	$script:FullName = "$script:FirstName $script:LastName"
	Logging102 -Message "Full Name - $script:FullName" -Severity Information -FunctionName $CurrentFunction

	$script:UserName = $script:FirstName.Substring(0,1)+$script:LastName
	Logging102 -Message "UserName - $script:UserName" -Severity Information -FunctionName $CurrentFunction

	$script:Email = "$script:UserName@$script:Domain"
	Logging102 -Message "Email - $script:Email" -Severity Information -FunctionName $CurrentFunction

	$script:BckUpUserName = $script:FirstName.Substring(0,1)+$script:MiddleName+$script:LastName
	$script:BckUpEmail = "$script:BckUpUserName@$script:Domain"
	Logging102 -Message "Backup UserName - $script:BckUpUserName" -Severity Information -FunctionName $CurrentFunction
	Logging102 -Message "Backup Email - $script:BckUpEmail" -Severity Information -FunctionName $CurrentFunction
}

function Invoke-AdMagic {

	$CurrentFunction = ($MyInvocation.MyCommand)

	#Check for AD for duplicate
	$ADUserCheck = Get-ADUser -Filter "sAMAccountName -eq '$script:UserName'"
	$BuAdUserCheck = Get-ADUser -Filter "sAMAccountName -eq '$script:BckUpUserName'"
	if ($ADUserCheck) {
		Logging102 -Message "Duplicate $script:UserName Exists - $script:BckUpEmail" -Severity Warning -FunctionName $CurrentFunction
		Write-Host "$script:UserName Has been taken, Checking $script:BckUpUserName" -BackgroundColor Red
		$ADCheck = $True
	}
	elseif ($BuAdUserCheck) {
		Write-Host "Both $script:UserName and $script:BckUpUserName are taken. Please manually create this user." -BackgroundColor Red
		Logging102 -Message "Both $script:UserName and $script:BckUpUserName are taken. Please manually create this user." `
		-Severity Error -FunctionName $CurrentFunction
		Read-Host -Prompt "Press Enter to Exit Script"
		Exit
	}
	else {
		"$(Get-Date): AdMagic: $script:UserName Does Not Exist" | Out-File -FilePath $script:Log -Append -Encoding ascii
		Logging102 -Message "$script:UserName Does not exist" -Severity Information -FunctionName $CurrentFunction
		$ADCheck = $False
	}

	#Creates Password for User
    Add-Type -AssemblyName System.Web
    $script:PW = [System.Web.Security.Membership]::GeneratePassword(8,2)
    $script:SecurePass = $PW | ConvertTo-SecureString -AsPlainText -Force

	#Create AD User (if the user already exists it will take account and set the backup UN to the variable $UserName)
	switch ($ADCheck) {
		$True {
			# We will use the backup Username if ADCheck is True
			Write-Host "Username: $script:UserName already exists. We will use $script:BckUpUserName instead" -BackgroundColor Yellow -ForegroundColor Black
			if (Read-Host -Prompt "Press Enter to Continue, otherwise hit Q to exit AD setup.") {
				Logging102 -Message "User Decided to quit script" -Severity Information -FunctionName $CurrentFunction
				Exit
			}
			#Make things easier further down the road, I'm replacing backup username/email and setting to the standard variables.
			$script:UserName = $script:BckUpUserName
			$script:Email = $script:BckUpEmail

			New-ADUser -Name $script:FullName -AccountPassword $SecurePass -SamAccountName $script:BckUpUserName -DisplayName $script:FullName -GivenName $script:FirstName `
            -PasswordNeverExpires $False -ChangePasswordAtLogon $true -Surname $script:LastName -Enabled $true -Path $OUPath  -UserPrincipalName $script:BckUpEmail `
            -Initials $script:MiddleName -EmailAddress $script:BckUpEmail -WhatIf
			Logging102 -Message "$script:UserName has been created in AD" -Severity Information -FunctionName $CurrentFunction
		 }
		 $False {
			# Create Username with standard UserName
			New-ADUser -Name $script:FullName -AccountPassword $SecurePass -SamAccountName $script:UserName -DisplayName $script:FullName -GivenName $script:FirstName `
            -PasswordNeverExpires $False -ChangePasswordAtLogon $true -Surname $script:LastName -Enabled $true -Path $OUPath  -UserPrincipalName $script:Email `
            -EmailAddress $script:Email -WhatIf
			Logging102 -Message "$script:UserName has been created in AD" -Severity Information -FunctionName $CurrentFunction
		}
		Default {
			Write-Host "Something went wrong Call Tech Support"
			Logging102 -Message "Something went wrong, told Karen to call us." -Severity Error -FunctionName $CurrentFunction
			Read-Host -Prompt "Press Enter to Exit"
			Exit
		}
	}
		#Display information for Person inputing info
		Write-Host "Following User Info"
		Write-Host "Full Name: $script:FirstName $script:LastName"
		Write-Host "UN: $script:UserName"
		Write-Host "PW: $script:PW"
		Write-Host "Email: $script:Email"

	
}

function O365Sync {

	if ($0365 -eq $True) {
		Logging102 -Message "Syncing AD to O365" -Severity Information -FunctionName $CurrentFunction
		Invoke-Command $O365SyncServer {Start-ADSyncSyncCycle -PolicyType Delta} | Select-Object Result
		if ($_.Result -eq "Success") {
			Logging102 -Message "Syncing has begun, 2 Minute Delay" -Severity Information -FunctionName $CurrentFunction
			Write-Host "Syncing to O365 has begun, waiting 2 minutes for sync to complete" -BackgroundColor Green -ForegroundColor Black
			Start-Sleep -Seconds 120
		}
		else {
			Write-Host "Syncing Failed, Call Tech Support" -BackgroundColor Red -ForegroundColor Black
			Logging102 -Message "Syncing Failed, Call Tech Suppoert" -Severity Error -FunctionName $CurrentFunction

		}

	}
	else {
		Logging102 -Message "This Customer doesn't use O365." -Severity Information -FunctionName $CurrentFunction
	}
	
}

function SendEmail {
	#Email Variables
	$Subject = "New User: $script:FullName"
	$SMTPServer = $script:PickupInfo.SmtpRelay
	$Sender = $script:PickupInfo.Sender
	$Admin = $script:PickupInfo.Admin
	$Recipients = $script:PickupInfo.Recipients

	if (debug -eq $True) {
		$Sender = $script:PickupInfo.Sender
		$Subject = "New User: $script:FullName -Debug"
		$Recipients = $script:PickupInfo.Admin
	}

	$Body =@"
	$script:FullName
	UN: $script:Username
	EMail: $script:Email
	Password: $script:PW
"@ 
	Send-MailMessage -From $Sender -To $Recipients -Cc $Admin -Subject $Subject -Body $body -DeliveryNotificationOption onFailure -SmtpServer $SMTPServer
}


<##====================================================================================
	CODE
##===================================================================================#>


Import-Module ActiveDirectory
#Import-Module ADSync


Get-BasicInfo
Invoke-AdMagic
