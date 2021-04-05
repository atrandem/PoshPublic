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
    [TypeName]
    $ParameterName
)


Import-Module MSOnline
Import-Module CredentialManager
$LicenseArray = @{}
$Creds = Get-StoredCredential -Target 'admin@microsoft.com'

Connect-MsolService -Credential $Creds

# Get licenses that are commonly used accross orgs.
$ExchangeOnlineKiosk = (Get-MSolAccountSku | Where-Object {$_.AccountSkuID -like "*EXCHANGEDESKLESS"}) | Select-Object ActiveUnits, WarningUnits, ConsumedUnits
$Microsoft365BusinessStandard = (Get-MSolAccountSku | Where-Object {$_.AccountSkuID -like "*O365_BUSINESS_PREMIUM"}) | Select-Object ActiveUnits, WarningUnits, ConsumedUnits
$ExchangeOnlinePlan1 = (Get-MsolAccountSku | Where-Object {$_.AccountSkuID -like "*ExchangeStandard"}) | Select-Object ActiveUnits, WarningUnits, ConsumedUnits

#Add licensing to array
$LicenseArray.Add("Exchange Online Kiosk",$ExchangeOnlineKiosk)
$LicenseArray.Add("Microsoft 365 Business Standard",$Microsoft365BusinessStandard)
$LicenseArray.Add("Exchange Online (Plan 1)",$ExchangeOnlinePlan1)



