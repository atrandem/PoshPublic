<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>


[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Expiration_Days = "7",

    [Parameter()]
    [string]
    $SmtpServer,

    [Parameter()]
    [string]
    $To,

    [Parameter()]
    [string]
    $From,

    [Parameter()]
    [string]
    $CC,

    [Parameter()]
    [string]
    $BCC,

    

)




