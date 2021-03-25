<#
.SYNOPSIS
    Logs off users
.DESCRIPTION
    Logs off users 
.EXAMPLE
    Invoke-Logoff.ps1
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Found this script here just shortened it and took away logging as it was not needed.
    https://gist.github.com/krushnacn/4885c32ef28e3733abb42cd9a57b9564
    Author   : Krishna Nahak
    Edited - Aaron Trandem
#>
function Get-Sessions
{
$queryResults = query session
   $starters = New-Object psobject -Property @{"SessionName" = 0; "UserName" = 0; "ID" = 0; "State" = 0; "Type" = 0; "Device" = 0;}
   foreach ($result in $queryResults)
   {
      try
      {
         if($result.trim().substring(0, $result.trim().indexof(" ")) -eq "SESSIONNAME")
         {
            $starters.UserName = $result.indexof("USERNAME");
            $starters.ID = $result.indexof("ID");
            $starters.State = $result.indexof("STATE");
            $starters.Type = $result.indexof("TYPE");
            $starters.Device = $result.indexof("DEVICE");
            continue;
         }
 
         New-Object psobject -Property @{
            "SessionName" = $result.trim().substring(0, $result.trim().indexof(" ")).trim(">");
            "Username" = $result.Substring($starters.Username, $result.IndexOf(" ", $starters.Username) - $starters.Username);
            "ID" = $result.Substring($result.IndexOf(" ", $starters.Username), $starters.ID - $result.IndexOf(" ", $starters.Username) + 2).trim();
            "State" = $result.Substring($starters.State, $result.IndexOf(" ", $starters.State)-$starters.State).trim();
            "Type" = $result.Substring($starters.Type, $starters.Device - $starters.Type).trim();
            "Device" = $result.Substring($starters.Device).trim()
         }
      } 
      catch 
      {
         $e = $_;
         Write-Log "ERROR: " + $e.PSMessageDetails
      }
   }
}

   $DisconnectedSessions = Get-Sessions | ? {$_.State -match $IncludeStates -and $_.UserName -ne ""} | Select ID, UserName

   foreach ($session in $DisconnectedSessions)
{
   logoff $session.ID
}