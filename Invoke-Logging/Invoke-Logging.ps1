<#
.SYNOPSIS
    Used to standardize logging across your library of scripts
    Created By Unknown (If known contact script adjuster at atrandem@live.com)
    Adjusted By Aaron Trandem
.DESCRIPTION
    This is used to log your library of scripts in a standard way
    Example message would look like this:
    "11/24/2019 17:59:15 - Rename-SMITComputer - Information - The current Computer Name is - BRIDGE"
    Shows date, time, Script Name, Function Name, Severity, Message

    To successfully log your scripts you will need these components within those scripts.
    1st - $PowershellScriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
    This will pick up the powershell script name without an extension to use as the log name
    2nd - $CurrentFunction = ($MyInvocation.MyCommand)
    To be more precise, this will tell you the Current Function the log is coming from to better troubleshoot or follow your scripts processing
    3rd - $Log = "YourChoiceOfLogLocation.log"
    This will direct where to save your logging, and allow you to be flexible where each script logs its files

    You can adjust the Severity level to be Warning, Error. Default is Informational
.EXAMPLE
    Invoke-Logging -Message "First Name - Aaron" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName $PowershellScriptName
    Explanation of what the example does
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    General notes
#>
function Invoke-Logging {
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
        [string]$FunctionName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$PowershellScriptName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Log
    )

    Write-Output "$(Get-Date) - $PowershellScriptName - $FunctionName - $Severity - $Message" | Out-File -FilePath "$Log" -Append -Encoding ascii
    # Use the following example when you want to log something.
    # Invoke-Logging -Message "First Name - $script:FirstName" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName $PowershellScriptName -Log $Log
    # Use the following command(s) to get the current function you are in or you can add these variables into your script params.
    #$CurrentFunction = ($MyInvocation.MyCommand)
    #Use this to get the script name for log name purposes
    #$PowershellScriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
}
