<#
.SYNOPSIS
    Determines if the chassis is a Desktop or Laptop/Notebook
    Created By Aaron Trandem
.DESCRIPTION
    Determinise if a computer is a laptop/Notebook or a Desktop. Mainly used for other
    scripts to call upon to determine specific settings to use for a type of computer.
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    
#>

Function Get-Chassis
{
        [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [String[]] 
        $Computer = $env:COMPUTERNAME
    )

    $script:isLaptop = $false
    $script:isNUC = $false

    if (!([string]::IsNullOrEmpty($Computer))) {
        #The chassis is the physical container that houses the components of a computer. Check if the machine’s chasis type is 9.Laptop 10.Notebook 14.Sub-Notebook
        if(Get-WmiObject -Class win32_systemenclosure -ComputerName $Computer | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14})
        { 
            $script:isLaptop = $true
        }
        #Shows battery status , if true then the machine is a laptop.
        if(Get-WmiObject -Class win32_battery -ComputerName $Computer)
        {
            $script:isLaptop = $true
        }
        $CheckNUC = Get-ComputerInfo -Property "CsManufacturer"
        if($CheckNUC.CsManufacturer -like "Intel*"){
            $script:isNUC = $true
            $script:isLaptop = $false
        }
    }
    else {
        #The chassis is the physical container that houses the components of a computer. Check if the machine’s chasis type is 9.Laptop 10.Notebook 14.Sub-Notebook
        if(Get-WmiObject -Class win32_systemenclosure | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14})
        { 
            $script:isLaptop = $true
        }
        #Shows battery status , if true then the machine is a laptop.
        if(Get-WmiObject -Class win32_battery)
        {
            $script:isLaptop = $true
        }
        $CheckNUC = Get-ComputerInfo -Property "CsManufacturer"
        if($CheckNUC.CsManufacturer -like "Intel*"){
            $script:isNUC = $true
            $script:isLaptop = $false
        }
    }
    $script:isLaptop
    $script:isNUC
}