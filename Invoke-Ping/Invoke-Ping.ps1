<#
.SYNOPSIS
    Pings a given host in Ping-Host.txt continuously and records the
    failures in Ping-Results.txt.
.DESCRIPTION
    Pings a given host in Ping-Host.txt continuously and records the
    failures in Ping-Results.txt. Both txt defaults look in C:\temp
    Script will first import text files for data input and then begin
    looping until the console is closed or CTRL + C to break the
    script

.EXAMPLE
    PS C:\> .\Invoke-Ping.ps1
    Runs script with defaults
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Modified by Aaron Trandem
    Original concept credit to:
    briantist: https://stackoverflow.com/questions/32637785/powershell-try-catch-with-test-connection
    DethSilvermane: https://community.spiceworks.com/topic/2216374-powershell-script-to-continuously-ping-hosts-and-log-failures-with-timestamps
#>
param (
  [String]
  $InputFile = "C:\temp\Ping-Hosts.txt",
  [String]
  $ReportPath = "C:\temp\Ping-Results.txt"
)

filter timestamp {"$(Get-Date -Format G): $_"}
function Test-Ping ($target) {
  if (!(Test-Connection -ComputerName $target -Count 1 -ErrorAction "Stop" -Quiet)) {
    Write-Output "$target failed ping" | timestamp | Out-File -FilePath $ReportPath -Append
  }
}

While ($true) {
  ForEach ($target in Get-Content -Path $InputFile) {
    Test-Ping $target
  }
}