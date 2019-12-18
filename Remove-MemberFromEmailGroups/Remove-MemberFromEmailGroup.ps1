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

function Remove-MemberFromEmailGroup {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String[]] 
        $User
    )

    $GroupMembership = Get-ADPrincipalGroupMembership -Identity $User | Select-Object sAMAccountName
    foreach ($Group in $GroupMembership) {
        $ADGroup = Get-ADGroup -Identity $Group.sAMAccountName | Select-Object sAMAccountName, mail

        if ([string]::IsNullOrWhiteSpace($ADGroup.mail)) {
            Write-Host "No Email Address Exists for: " $ADGroup.sAMAccountName
        }
        else {
            Remove-ADGroupMember -Identity $ADgroup.sAMAccountName -Members $User
        }
    }
}
