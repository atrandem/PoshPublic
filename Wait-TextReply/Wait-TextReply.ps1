
function Wait-TextReply {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [String[]]
        $Text = "Aaron says go next!",

        [Parameter(Mandatory=$true)]
        [String[]]
        $Document,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$Time = 10

    )

    [int]$a = 1
    $Kill = $false

    do {
        Write-Host "Start Looping"
        $TextFound = Get-Content -Path "$Document"

        if (!($TextFound -eq $Text)) {
            $Kill = $false
        }
        else {
            $Kill = $true
        }
    } until ($Time -le $a -or $Kill -eq $true)

}