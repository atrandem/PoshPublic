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


Import-Module MSOnline
Import-Module CredentialManager

$Creds = Get-StoredCredential -Target 'admin@microsoft.com'

Connect-MsolService -Credential $Creds

$ExchangeOnlineKiosk = (Get-MSolAccountSku | Where-Object {$_.AccountSkuID -like "*EXCHANGEDESKLESS"}) | Select-Object ActiveUnits, WarningUnits, ConsumedUnits
$Microsoft365BusinessStandard = (Get-MSolAccountSku | Where-Object {$_.AccountSkuID -like "*O365_BUSINESS_PREMIUM"}) | Select-Object ActiveUnits, WarningUnits, ConsumedUnits
$ExchangeOnlinePlan1 = (Get-MsolAccountSku | Where-Object {$_.AccountSkuID -like "*ExchangeStandard"}) | Select-Object ActiveUnits, WarningUnits, ConsumedUnits


