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
    Credit goes to this poster on Reddit, I edited to fit my needs.
	https://www.reddit.com/r/msp/comments/hsglwk/av_removal_script/
#>

[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$Log = "C:Scripts\Logs\MbamUninstallLog.txt"
)

"$env:COMPUTERNAME : Beginning search\uninstall of Malwarebytes" | Out-File $Log

$MbAMCheck = (Resolve-Path -Path C:\Prog*\Malw*).Path
$MbAMCheck += (Resolve-Path -Path C:\Prog*\Malw*\Ant*).Path


if (!([string]::IsNullOrEmpty($MbAMCheck)))
{

	## Checking for all installations of Malwarebytes. Installations have changed paths over version changes. Removing if found.
	if ((Test-Path -Path "C:\Program Files\Malwarebytes' Anti-Malware\unins000.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files\Malwarebytes' Anti-Malware\unins000.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files\Malwarebytes' Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files\Malwarebytes' Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}

	}
	
	elseif ((Test-Path -Path "C:\Program Files (x86)\Malwarebytes' Anti-Malware\unins000.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files (x86)\Malwarebytes' Anti-Malware\unins000.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files (x86)\Malwarebytes' Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files (x86)\Malwarebytes' Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}
	}
	
	elseif ((Test-Path -Path "C:\Program Files\Malwarebytes Anti-Malware\unins000.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files\Malwarebytes Anti-Malware\unins000.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files\Malwarebytes Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files\Malwarebytes Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}
	}
	
	elseif ((Test-Path -Path "C:\Program Files (x86)\Malwarebytes Anti-Malware\unins000.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files (x86)\Malwarebytes Anti-Malware\unins000.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files (x86)\Malwarebytes Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files (x86)\Malwarebytes Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}
	}
	
	elseif ((Test-Path -Path "C:\Program Files\Malwarebytes\Anti-Malware\unins000.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files\Malwarebytes\Anti-Malware\unins000.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files\Malwarebytes\Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files\Malwarebytes\Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}		
	}
	
	elseif ((Test-Path -Path "C:\Program Files (x86)\Malwarebytes\Anti-Malware\unins000.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files\Malwarebytes' Anti-Malware\unins000.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files (x86)\Malwarebytes\Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files (x86)\Malwarebytes\Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}		
	}
	elseif ((Test-Path -Path "C:\Program Files (x86)\Malwarebytes\Anti-Malware\unins001.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files\Malwarebytes' Anti-Malware\unins001.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files (x86)\Malwarebytes\Anti-Malware\unins001.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files (x86)\Malwarebytes\Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}		
	}
	elseif ((Test-Path -Path "C:\Program Files\Malwarebytes\Anti-Malware\unins001.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files\Malwarebytes\Anti-Malware\unins001.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files\Malwarebytes\Anti-Malware\unins001.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files\Malwarebytes\Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}		
	}
	
	elseif ((Test-Path -Path "C:\Program Files (x86)\Malwarebytes\Anti-Malware\mbuns.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files\Malwarebytes' Anti-Malware\unins000.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files (x86)\Malwarebytes\Anti-Malware\mbuns.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files (x86)\Malwarebytes\Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}		
	}
	
	elseif ((Test-Path -Path "C:\Program Files\Malwarebytes\Anti-Malware\mbuns.exe") -eq $true)
	{
		"Found MBAM in: C:\Program Files\Malwarebytes' Anti-Malware\unins000.exe" | Out-File $Log -Append
		Start-Process -FilePath "C:\Program Files\Malwarebytes\Anti-Malware\mbuns.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		#Checking that its been uninstalled. Path may still exist and 2 files would be hanging around.
		if (Test-Path -Path "C:\Program Files\Malwarebytes\Anti-Malware\mbam.exe") {
			"MBAM has FAILED uninstalled, please check manually" | Out-File $Log -Append
		}
		else {
			"MBAM has SUCCESSFULLY uninstalled" | Out-File $Log -Append
		}		
	}
	else {
		"Malwarebytes is installed, but couldn't identify the uninstaller. Contact your Centralised Services specialist." | Out-File $Log -Append
	}
}
else
{
	"No Malwarebytes software found." | Out-File $Log -Append

}


