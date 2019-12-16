<#
.SYNOPSIS
    Install using Chocolatey or PS/RMM tool. Created By Aaron Trandem
.DESCRIPTION
    This PowerShell script will use Chocolatey to install multiple types of applications or upgrade them.
    To use this correctly you'll need to make sure that a text file exists (BasePrograms.txt) and it has
    numbers in it that associate with the numbers in the switch. Each number should be seperated by a : to
    allow for multi digit numbers. This will get those numbers, run through the switch and install/upgrade
    the application. Currently there are no parameters that will allow user input. In the future this could
    come to be.
.EXAMPLE
    Invoke-Chocolatey.ps1
.INPUTS
    Inputs (if any)
.OUTPUTS
    ChocoLog.log is created in the location that the script is run.
.NOTES
    General notes
#>
#Script Global Variables

$script:ScriptPath = $PSScriptRoot
function Install-ChocoApps {
    $CurrentFunction = ($MyInvocation.MyCommand)
    $PowershellScriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

    #Constant Variables
    $script:Log = "$script:ScriptPath\ChocoLog.log"
    $script:KaseyaNumbers = Get-Content -Path $script:ScriptPath\BasePrograms.txt
    $script:SplitNumbers = $script:KaseyaNumbers -split ":"
    $script:InstallNumbers = $SplitNumbers
    $script:LogDate = Get-Date -Format "yyyy-MM-dd"
    $script:Debug = $false

    #Call other needed Powershell Scripts
    . ./Invoke-Logging

        #Choco needs this, if it doesn't exist, it will not run.
        if (!(Test-Path $profile)) {
            New-Item -Path $profile -ItemType file -Force
            Invoke-Logging -Message "Microsoft-Profile.ps1 is missing, created profile." -Severity Warning -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
    
        }
        else {
            Invoke-Logging -Message "$Profile exists" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
    
        }
        #Check if Choco is installed, if not install it, if so upgrade it
        if(![System.IO.File]::Exists("C:\ProgramData\Chocolatey\choco.exe")){
            
            $1 = "Chocolatey Install"
            Invoke-Logging -Message "Chocolatey is missing, Installing Chocolatey" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
            Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null
            Start-Sleep 60
    
            #Refresh the Envriomental variables
            Invoke-Logging -Message "Starting Envriomental Variable Refresh" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            Invoke-Logging -Message "Envriomental Variable Completed" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log 
        }
        else {
                
                Invoke-Logging -Message "Chocolatey will check for upgrades" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
                choco upgrade chocolatey -y
                Start-Sleep 20
                Invoke-Logging -Message "Upgrading $1 Command finished." -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
        }

    #Logging data given by Kaseya
    Invoke-Logging -Message "Kaseya Numbers are - $script:KaseyaNumbers" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
    Invoke-Logging -Message "Install Numbers are - $script:InstallNumbers" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
    Invoke-Logging -Message "Any Information for logging check Chocolateys auto generated log files C:\ProgramData\Chocolatey" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log

    foreach ($Number in $InstallNumbers) {

        Invoke-Logging -Message "Kaseya Number: $Number " -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
        $NumberCheck = $true
        switch ($Number) {
            "1" {
                $InstallName = "Chocolatey"
                Invoke-Logging -Message "$InstallName was chosen for Install, this is automatically installed or upgraded. 1 is a depricated install"`
                 -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
                 $NumberCheck = $false                             
            }
            "2" {
                $InstallName = "7 Zip"
                $InstallCommand = "7zip"
                
            }
            "3" {
                $InstallName = "Adobe Reader"
                $InstallCommand = "adobereader"
            }
            "4" {
                $InstallName = "Firefox"
                $InstallCommand = "firefox"
            }
            "5" {
                $InstallName = "Firefox ESR"
                $InstallCommand = "firefox esr"
            }
            "6" {
                $InstallName = "Flash Player PPAPI"
                $InstallCommand = "flashplayerppapi"
            }
            "7" {
                $InstallName = "Google Chrome"
                $InstallCommand = "googlechrome"
            }
            "8" {
                $InstallName = "Oracle Java"
                $InstallCommand = "javaruntime"
            }
            "9" {
                $InstallName = "MalwareBytes"
                $InstallCommand = "malwarebytes"
            }
            "10" {
                $InstallName = "Open JDK 12"
                $InstallCommand = "openjdk12"
            }
            "11" {
                $InstallName = "SilverLight"
                $InstallCommand = "silverlight"
            }
            "12" {
                $InstallName = "Team Viewer 14"
                $InstallCommand = "teamviewer"
            }
            "13" {
                $InstallName = "WindirStat"
                $InstallCommand = "windirstat"
            }
            "14" {
                $InstallName = "WizTree"
                $InstallCommand = "wiztree"
            }
            "15" {
                $InstallName = "FortiClient"
                $InstallCommand = "forticlientvpn"
            }
            "16" {
                $InstallName = "Putty"
                $InstallCommand = "putty"
            }
            "17" {
                $InstallName = "VLC"
                $InstallCommand = "vlc"
            }
            "18" {
                $InstallName = "Foxit Reader"
                $InstallCommand = "foxitreader"
            }
            "19" {
                $InstallName = "MXIE PGC"
                $InstallCommand = ""
                $NumberCheck = $false
            }
            "20" {
                $InstallName = "MXIE NTUM"
                $InstallCommand = ""
                $NumberCheck = $false
            }
            "21" {
                $InstallName = "MXIE Supeiror"
                $InstallCommand = ""
                $NumberCheck = $false
            }
            "22" {
                $InstallName = "Office 365 Business Premium"
                $InstallCommand = ""
                $NumberCheck = $false
            }
            "23" {
                $InstallName = "Office 2019 Home and Business"
                $InstallCommand = ""
                $NumberCheck = $false
            }
            "24" {
                $InstallName = "M-Files PGC"
                $InstallCommand = ""
                $NumberCheck = $false
            }
            "25" {
                $InstallName = "CheckPoint 80.10 PGC"
                $InstallCommand = ""
                $NumberCheck = $false
            }
            "26" {
                $InstallName = "Last Pass"
                $InstallCommand = "lastpass"
            }

            Default {
                $NumberCheck = $false
                Invoke-Logging -Message "No matching numbers" -Severity Warning -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
            }
        }
        #Checks if number is $true, if so it will continue to install using choco.
        #If $false, it will either call another PS script or the install relies on another tool
        if ($Numbercheck) {
            Invoke-Logging -Message "$InstallName was chosen for install" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
            Start-process choco -ArgumentList "upgrade $InstallCommand --confirm" -Wait
            Invoke-Logging -Message "$InstallName was chosen, $InstallCommand command finished, check choco logs for details" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
            Clear-Variable -Name "Number","InstallName","InstallCommand","NumberCheck"
        }

        #install Dell Command Update if this is a Dell computer  
        $BIOS = Get-CimInstance -ClassName Win32_BIOS
        $Manufacturer = $BIOS.Manufacturer

        if ($Manufacturer -contains "Dell") {
            Invoke-Logging -Message "This is a Dell Computer, installing/updating Dell Command" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
            Start-Process choco -ArgumentList "upgrade dellcommandupdate --comfirm"
            Invoke-Logging -Message "Dell command choco command has run" -Severity Information -FunctionName $CurrentFunction -PowershellScriptName -$PowershellScriptName -Log $Log
        }

    }
}


Install-ChocoApps

