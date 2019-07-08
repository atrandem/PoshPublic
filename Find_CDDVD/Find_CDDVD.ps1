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
	XP - No		08 - No
	7 - No		08R2 - No
	10 - No	    12 - No
	12R2 - No	16 - No
	19 - No
##====================================================================================
	Future Goals
##===================================================================================#

##====================================================================================
	READ-ME
##===================================================================================#



##====================================================================================
	Change Notes
##===================================================================================#

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


<##====================================================================================
	Error Preference
##===================================================================================#>


<##====================================================================================
	SCRIPT GLOBALS
##===================================================================================#>  
$script:ScriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$script:Date= Get-Date -Format "yyyy-MM-dd"
$script:Log = "C:\Scripts\Logs\$Date $script:ScriptName.txt"

<##====================================================================================
   FUNCTIONS
##===================================================================================#>
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
   # Use the following example when you want to log something.
   # Logging102 -Message "First Name - $script:FirstName" -Severity Information -FunctionName $CurrentFunction
   # Use to get the current function you are in.
   #$CurrentFunction = ($MyInvocation.MyCommand)
}

function Test-LogFolder {
   #Put in any folders/files that need to be here before the script begins running

   if (![System.IO.Directory]::Exists($script:LogPath)){
       [System.IO.Directory]::CreateDirectory($script:LogPath)
   }
   
}
function Get-CDDVD {
    $DriveType = [System.IO.DriveInfo]::GetDrives() | Select Name,DriveType

    foreach ($Drive in $DriveType) {
        if ($Drive.DriveType -ne 'Fixed') {
            $Drive.Name | Out-File -FilePath C:\Scripts\Logs\Find_CDDVD.txt
        }
    }
    
}

<##====================================================================================
   CODE
##===================================================================================#>

Test-LogFolder

Get-CDDVD

