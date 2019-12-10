.<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

function Invoke-DattoFileProtect {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string[]]
        $Path = "C:\kworking\DattoFileProtect"
    )
    
    if(![System.IO.Directory]::Exists($Path)) {
        New-Item -Path $Path -ItemType Directory
    }

    Invoke-WebRequest -Uri "https://us.fileprotection.datto.com/update/aeb/DattoFileProtectionSetup_v8.1.0.59.exe" -OutFile "$Path\DattoFileProtect.exe" -UseBasicParsing
    
    Start-Process -FilePath "$Path\DattoFileProtect.exe" -ArgumentList "/install /quiet /norestart" -WhatIf -Wait

}


