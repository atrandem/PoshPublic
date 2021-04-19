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
    Created By: Aaron Trandem
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $LanPath,

    [Parameter()]
    [switch]
    $OutputText = $false,

    [Parameter()]
    [string]
    $LogPath

)


#Check if lan path is true or not
if (Test-Path "$LanPath") {
    #Path exists now output
    if ($OutputText) {
        #we output to text file
        "true" | Out-File -FilePath "$LogPath"
    }
    else {
        return $true
    }
}
else {
    if ($OutputText) {
        #we output to text file
        "false" | Out-File -FilePath "$LogPath"
    }
    else {
        return $false
    }
}