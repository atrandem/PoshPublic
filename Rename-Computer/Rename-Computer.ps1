<#
.SYNOPSIS
    Renames Computer using the Superior Managed IT common practices.
    Created By Aaron Trandem
.DESCRIPTION
    Ranmames the local computer using Superior Managed IT common practices.
    DT or NB or Desktop and Notebook
    Windows Major Version: Win10 or Win7
    2 digit year and 2 digit month YYMM
    A single letter in the case there are multiple builds per customer per month. A B C
    Put all together an example would be DT-Win10-1911A or NB-Win7-1911B

    If you decide to put in your own name, it does not check if it's in use or not. This is at your
    own risk

    This function requires that the Invoke-Logging and Get-Chassis are in the same directory. These
    two scripts create a log file and also help determine if a computer is a Desktop or Laptop
.EXAMPLE
    This can be run two ways. With a manual entry of a new computer name or it will auto generate
    If you want to have the name autogenerated:
    ./Rename-Computer.ps1
    or if you're calling this from another script
    Rename-Computer
    If you want to manually add the new PC name
    ./Rename-Computer.ps1 -NewName "ComputerNewName"
    or if you're calling this from another script
    Rename-Computer -NewName "ComputerNewName"
.INPUTS
    NewName - What you would like to rename the computer to, otherwise it will create it's own.

.OUTPUTS
    Outputs to log
.NOTES
    General notes
#>
function Rename-Computer {

    [CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [String[]]
    $NewName
)
$PowershellScriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$CurrentFunction = ($MyInvocation.MyCommand)
$script:ScriptPath = $PSScriptRoot
$script:Log = "$script:ScriptPath\$PowershellScriptName.log"

#Calling Custom Powershell Functions
. .\Invoke-Logging.ps1
. .\Get-Chassis.ps1

$ComputerName = $env:COMPUTERNAME
Invoke-Logging -Message "The current Computer Name is - $ComputerName" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName

if (!([string]::IsNullOrEmpty($NewName))) {
    Invoke-Logging -Message "Manually renaming computer to - $NewName" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
}
else {
    #This gets the chassis type, example laptop, NUC, Desktop
    Get-Chassis
    If($isLaptop) { 
        $Chassis = "NB"
        Invoke-Logging -Message "$env:COMPUTERNAME is a Notebook" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
    }
    elseif ($isNuc) {
        $Chassis = "NUC"
        Invoke-Logging -Message "$env:COMPUTERNAME is a Nuc" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
    }
    else { 
        $Chassis = "DT"
        Invoke-Logging -Message "$env:COMPUTERNAME is a Desktop" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
    }

    #Grab the last two digits of the year the two digit month, example - 1912 (2019/December(12))
    $DateName = Get-Date -Format "%y%M"

    # Starting with the number 1 as the last digit of the computer name.
    [int] $LastNumber = 1

    #Get the list of names that Kaseya has given and make sure nothing is matching. If it does, we need to increment the last number
    #Quick check that machName.txt exists, if it doesn't, we stop the renaming script
    if (!(Test-Path -Path "$script:ScriptPath\RawNames.txt")) {
        Invoke-Logging -Message "The RawNames.txt file is missing. Renaming the machine will stop, manual renaming will need to be done"`
         -Severity Error -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
        $host.Exit()
    }
    else {
        Invoke-Logging -Message "RawNames.txt was found" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
    }
    #Currently, Kaseya drops a text file that is not how we need it to be to read it correctly
    #This is where we will adjust and create an readable list of machine names
    #Collects the raw data of names Kaseya created
    $RawNames = Get-Content "$script:ScriptPath\RawNames.txt"
    #Splits each name into its own line using the splitting by ", "
    $FullName = $RawNames -split (", ")

    Invoke-Logging -Message "Starting foreach loop" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
    foreach ($a in $FullName) {
    #Takes all characters before the first "." and appends it to a file.
    $a.Substring(0,$a.IndexOf(".")) | Out-File -FilePath "$script:ScriptPath\machNames.txt" -Append
    }
    Invoke-Logging -Message "Finished foreach loop" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
    #Clear $a for reuse
    Clear-Variable -Name "a"
    Invoke-Logging -Message "Cleared Variable a" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
    #Grab the list of readable names.
    $machName = Get-Content -Path "$ScriptPath\machNames.txt"
    #Compare the name we created to the list of names from machNames.txt
    Invoke-Logging -Message "Starting do until Loop" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
    $NameCheck = $false
    do {
        Invoke-Logging -Message "Inside do until Loop" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
        $NewName = "$Chassis-$DateName-$LastNumber"
        Invoke-Logging -Message "New Name: $NewName" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName

        if (!($machName -match "$NewName")) {
            Invoke-Logging -Message "Using Number: $LastNumber Succeded, Using name: $NewName" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
            $NameCheck = $true
            Break;
        }
        else {
            Invoke-Logging -Message "Using Number: $LastNumber failed trying next number" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
            $LastNumber++
        }
        
    } until ($NameCheck -eq $true)

    Invoke-Logging -Message "Autobot chose computer name - $NewName" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName

}

#Rename's computer no reboot / also does one last check to make sure all variables exist
if (!([string]::IsNullOrEmpty($NewName))) {
    Rename-Computer -NewName "$NewName"
    Invoke-Logging -Message "Computer has been renamed to $NewName" -Severity Information -Log $script:Log -FunctionName $CurrentFunction -$PowershellScriptName
}


}

Rename-Computer
