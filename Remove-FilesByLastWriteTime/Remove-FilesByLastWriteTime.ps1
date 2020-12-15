<#
.SYNOPSIS
    Removes files that are older than date specified
.DESCRIPTION
    Removes files that are older than x amount of days old given when you run
    this script. This looks at the LastWriteTime of the file. It will log the 
    files that it will remove before removing them.
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does

    Remove-FilesByLastWriteTime.ps1 -Path C:\temp -Days '30'
    Will run through C:\temp and remove files older than 30 days. Uses Default
    logging location to log files that are removed

    Remove-FilesByLastWriteTime.ps1 -Path -Days '30' C:\temp -Log "C:\temp\LogFileName.log"
    Will run through C:\temp and remove files older than 30 days. Uses new logging location 
    to log files that are removed.

    .\Remove-FilesByLastWriteTime -Path C:\temp -Days '30' -PowershellScriptName "MyScriptName.ps1"
    If you're calling this ps1 file from a another script, it will allow you to rename
    the logging scriptname to match your parent script that is running this child script. Also
    will run through C:\temp and remove files older than 30 days. Uses Default
    logging location to log files that are removed.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Took some of this script from this link
    https://community.spiceworks.com/topic/360837-delete-files-older-than-30-days
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $Days,

    [Parameter(Mandatory= $true)]
    [string]
    $Path,

    [Parameter()]
    [string]
    $Log = "C:\Scripts\Logs\Remove-FilesByLastWriteTime.log",

    [Parameter()]
    [string]
    $PowershellScriptName = "Remove-FilesByLastWriteTime.ps1",

    [Parameter()]
    [string]
    $CurrentFunction = "Remove-FilesByLastWriteTime"

)

$ErrorActionPreference = 'Stop'

#Make sure invoke-logging is available
if (!(Get-ChildItem -Path Function:\Invoke-Logging -ErrorAction SilentlyContinue)) {
    $Location = Get-Location
    #checks if invoke-logging is in the directory to load if not, it will download it from github
    if (!(Test-Path -Path $Location\invoke-logging.ps1)) {
        Invoke-RestMethod -Uri https://raw.githubusercontent.com/atrandem/PoshPublic/master/Invoke-Logging/Invoke-Logging.ps1 -OutFile "$Location\Invoke-Logging.ps1"
    }
    . .\invoke-Logging.ps1
}

#Gets files in $Path from the last write time of $Days parameter
try {
    $Files = Get-ChildItem -Path $Path -Recurse -File | Where-Object {!$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-$Days)}
    
    $report = @{
        Severity = 'Information'
        Log = $Log
        Message = "These Files are past $Days : $Files"
        FunctionName = $CurrentFunction
        PowershellScriptName = $PowershellScriptName
    }

    Invoke-Logging @report

    $Files | Remove-Item
}
#Catch errors in Try
catch [System.Exception] {
    #Logging info
    $report = @{
        Severity = 'Error'
        Log = $Log
        Message = $Error[0]
        FunctionName = $CurrentFunction
        PowershellScriptName = $PowershellScriptName
    }
    Invoke-Logging @report
}