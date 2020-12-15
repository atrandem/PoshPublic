<#
.SYNOPSIS
    Removes Empty folders in desired folder
.DESCRIPTION
    Removes Empty folders and logs its removal in a default log location unless specified.
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
    
    Remove-EmptyFolders.ps1 -Path C:\temp
    Will run through C:\temp and any empty folders it will log and remove.

    Remove-EmptyFolders.ps1 -Path C:\temp -Log "C:\temp\LogFileName.log"
    Will run through C:\temp and any empty folders it will log the location
    specified and remove the folders.

    .\Remove-EmptyFolders -Path C:\temp -PowershellScriptName "MyScriptName.ps1"
    If you're calling this ps1 file from a another script, it will allow you to rename
    the logging scriptname to match your parent script that is running this child script.

.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Took some of this script from the following link:
    https://community.spiceworks.com/scripts/show/1735-remove-emptyfolders-ps1
#>
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Path,

    [Parameter()]
    [string]
    $Log = "C:\Scripts\Logs\Remove-EmptyFolders.log",

    [Parameter()]
    [string]
    $PowershellScriptName = "Remove-Emptyfolders.ps1",

    [Parameter()]
    [string]
    $CurrentFunction = "Remove-EmptyFolders"

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


#Removal of Empty Folders
try {
    #Create hashtable and recurse through path for folders
    $Folders = @()
    ForEach ($Folder in (Get-ChildItem -Path $Path -Recurse | Where-Object { $_.PSisContainer })) {
        	$Folders += New-Object PSObject -Property @{
                Object = $Folder
                Depth = ($Folder.FullName.Split("\")).Count
            }
    }

    #Sort folders then removes each folder that has a file count of 0
    $Folders = $Folders | Sort-Object Depth -Descending
    ForEach ($Folder in $Folders) {
        If ((Get-ChildItem -Path $Folder.Object.FullName).Count -eq 0) {
            #logging info
            $report = @{
                Severity = 'Information'
                Log = $Log
                Message = "Removing Folder: $($Folder.Object.FullName)"
                FunctionName = $CurrentFunction
                PowershellScriptName = $PowershellScriptName
            }
            Invoke-Logging @report
            #Removes folder
            Remove-Item -Path $Folder.Object.FullName -Force
        }
    }
}
#Catch error from removing folders
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