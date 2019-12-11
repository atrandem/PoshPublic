<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.PARAMETER Path
    Specifies a path to one or more locations.
.PARAMETER LiteralPath
    Specifies a path to one or more locations. Unlike Path, the value of LiteralPath is used exactly as it
    is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose
    it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
    characters as escape sequences.
.PARAMETER InputObject
    Specifies the object to be processed.  You can also pipe the objects to this command.
.EXAMPLE
    C:\PS>
    Example of how to use this cmdlet
.EXAMPLE
    C:\PS>
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>


$script:LogDate = Get-Date -Format "yyyy-MM-dd"
$script:ScriptPath = $MyInvocation.PSScriptRoot
$script:Log = "$script:ScriptPath\ChocoLog.log"
$script:Debug = $false
function Start-Refresh {
    $CurrentFunction = ($MyInvocation.MyCommand)
    Invoke-Logging -Message "Starting Envriomental Variable Refresh" -Severity Information -FunctionName $CurrentFunction
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Invoke-Logging -Message "Envriomental Variable Completed" -Severity Information -FunctionName $CurrentFunction 
}
function Install-Chocolatey {
    if(![System.IO.Directory]::Exists("C:\ProgramData\Chocolatey")){
        $1 = "Chocolatey Install"
        Invoke-Logging -Message "Chocolatey is missing, Installing Chocolatey" -Severity Information -FunctionName $CurrentFunction
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null
        Start-Sleep 60
    }
    else {
            
            Invoke-Logging -Message "Chocolatey will check for upgrades" -Severity Information -FunctionName $CurrentFunction
            choco upgrade chocolatey -y --log-file $script:Log | Out-Null
            Start-Sleep 20
            Invoke-Logging -Message "Upgrading $1 Command finished." -Severity Information -FunctionName $CurrentFunction
    }
    
}
function Install-ChocoApps {
    $CurrentFunction = ($MyInvocation.MyCommand)

    $script:KaseyaNumbers = Get-Content -Path C:\Scripts\Logs\BasePrograms.txt
    $script:SplitNumbers = $script:KaseyaNumbers -split ":"
    $script:InstallNumbers = $SplitNumbers

    Invoke-Logging -Message "Kaseya Numbers are - $script:KaseyaNumbers" -Severity Information -FunctionName $CurrentFunction
    Invoke-Logging -Message "Install Numbers are - $script:InstallNumbers" -Severity Information -FunctionName $CurrentFunction

    foreach ($Number in $InstallNumbers) {

        Invoke-Logging -Message "Kaseya Number: $Number " -Severity Information -FunctionName $CurrentFunction

        switch ($Number) {
            "1" {
                $1 = "Chocolatey"
                Invoke-Logging -Message "$1 was chosen for Install, this is automatically installed or upgraded. 1 is a depricated install"`
                 -Severity Information -FunctionName $CurrentFunction                                
            }
            "2" {
                $2 = "7 Zip"
                Invoke-Logging -Message "$2 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade 7zip -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $2 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
                
            }
            "3" {
                $3 = "Adobe Reader"
                Invoke-Logging -Message "$3 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade adobereader -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $3 Command finished" -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "4" {
                $4 = "Firefox"
                Invoke-Logging -Message "$4 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade firefox -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $4 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "5" {
                $5 = "Firefox ESR"
                Invoke-Logging -Message "$5 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade firefox esr -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $5 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "6" {
                $6 = "Flash Player PPAPI"
                Invoke-Logging -Message "$6 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade flashplayerppapi -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $6 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "7" {
                $7 = "Google Chrome"
                Invoke-Logging -Message "$7 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade googlechrome -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $7 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "8" {
                $8 = "Oracle Java"
                Invoke-Logging -Message "$8 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade javaruntime -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $8 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "9" {
                $9 = "MalwareBytes"
                Invoke-Logging -Message "$9 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade malwarebytes -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $9 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "10" {
                $10 = "Open JDK 12"
                Invoke-Logging -Message "$10 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade openjdk12 -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $10 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "11" {
                $11 = "SilverLight"
                Invoke-Logging -Message "$11 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade silverlight -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $11 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "12" {
                $12 = "Team Viewer 14"
                Invoke-Logging -Message "$12 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade teamviewer -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $12 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "13" {
                $13 = "WindirStat"
                Invoke-Logging -Message "$13 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade windirstat -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $13 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "14" {
                $14 = "WizTree"
                Invoke-Logging -Message "$14 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade wiztree -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $14 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "15" {
                $15 = "FortiClient"
                Invoke-Logging -Message "$15 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade forticlientvpn -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $15 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "16" {
                $16 = "Putty"
                Invoke-Logging -Message "$16 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade forticlientvpn -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $16 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "17" {
                $17 = "VLC"
                Invoke-Logging -Message "$17 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade vlc -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $17 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }
            "18" {
                $17 = "Foxit Reader"
                Invoke-Logging -Message "$17 was chosen for install" -Severity Information -FunctionName $CurrentFunction
                choco upgrade foxitreader -y --log-file "$script:Log" | Out-Null
                Invoke-Logging -Message "Install $17 Command finished." -Severity Information -FunctionName $CurrentFunction
                Clear-Variable -Name "Number"
            }

            Default {Invoke-Logging -Message "No matching numbers" -Severity Warning -FunctionName $CurrentFunction}
        }
    }
}

. ./Invoke-Logging.ps1
Install-Chocolatey
Start-Refresh
Install-ChocoApps

#For purposes of My RMM tool, this is for me to recognize when it needs to go next. Not needed otherwise.
Out-File -FilePath $script:Log -Append -InputObject "Aaron says go next!"
