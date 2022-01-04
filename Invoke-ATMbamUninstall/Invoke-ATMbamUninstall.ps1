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

$MbAMCheck = (Resolve-Path -Path C:\Prog*\Malw*).Path
$MbAMCheck += (Resolve-Path -Path C:\Prog*\Malw*\Ant*).Path

if (!([string]::IsNullOrEmpty($MbAMCheck)))
{
	Write-Host "Found Malwarebytes software..." -ForegroundColor Green
	Write-Host "Checking for Malwarebytes Uninstaller..." -ForegroundColor Yellow
	if ((Test-Path -Path C:\Temp\mbstcmd.exe) -eq $true)
	{
		Write-Host "Found Command line Malwarebytes Uninstaller." -ForegroundColor Green
		Write-Host "Running Command line Malwarebytes Uninstaller Silently..." -ForegroundColor Yellow
		Start-Process -FilePath C:\Temp\mbstcmd.exe -ArgumentList "/y", "/cleanup", "/noreboot" -Wait
		Write-Host "Removed Malwarebytes." -ForegroundColor Green
		Write-Host "Checking for any other installations..." -ForegroundColor Yellow
	}
	else
	{
		Write-Host "Uninstaller not found! Manually checking for other installations..." -ForegroundColor Yellow
	}
	
	## Checking for all installations of Malwarebytes. Installations have changed paths over version changes. Removing if found.
	if ((Test-Path -Path "C:\Program Files\Malwarebytes' Anti-Malware\unins000.exe") -eq $true)
	{
		Write-Host "Found Malwarebytes..." -ForegroundColor Green
		Write-Host "Removing Malwarebytes..." -ForegroundColor Yellow
		Start-Process -FilePath "C:\Program Files\Malwarebytes' Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		Write-Host "Removed Malwarebytes." -ForegroundColor Green
	}
	
	if ((Test-Path -Path "C:\Program Files (x86)\Malwarebytes' Anti-Malware\unins000.exe") -eq $true)
	{
		Write-Host "Found Malwarebytes..." -ForegroundColor Green
		Write-Host "Removing Malwarebytes..." -ForegroundColor Yellow
		Start-Process -FilePath "C:\Program Files (x86)\Malwarebytes' Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		Write-Host "Removed Malwarebytes." -ForegroundColor Green
	}
	
	if ((Test-Path -Path "C:\Program Files\Malwarebytes Anti-Malware\unins000.exe") -eq $true)
	{
		Write-Host "Found Malwarebytes..." -ForegroundColor Green
		Write-Host "Removing Malwarebytes..." -ForegroundColor Yellow
		Start-Process -FilePath "C:\Program Files\Malwarebytes Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		Write-Host "Removed Malwarebytes." -ForegroundColor Green
	}
	
	if ((Test-Path -Path "C:\Program Files (x86)\Malwarebytes Anti-Malware\unins000.exe") -eq $true)
	{
		Write-Host "Found Malwarebytes..." -ForegroundColor Green
		Write-Host "Removing Malwarebytes..." -ForegroundColor Yellow
		Start-Process -FilePath "C:\Program Files (x86)\Malwarebytes Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		Write-Host "Removed Malwarebytes." -ForegroundColor Green
	}
	
	if ((Test-Path -Path "C:\Program Files\Malwarebytes\Anti-Malware\unins000.exe") -eq $true)
	{
		Write-Host "Found Malwarebytes..." -ForegroundColor Green
		Write-Host "Removing Malwarebytes..." -ForegroundColor Yellow
		Start-Process -FilePath "C:\Program Files\Malwarebytes\Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		Write-Host "Removed Malwarebytes." -ForegroundColor Green
	}
	
	if ((Test-Path -Path "C:\Program Files (x86)\Malwarebytes\Anti-Malware\unins000.exe") -eq $true)
	{
		Write-Host "Found Malwarebytes..." -ForegroundColor Green
		Write-Host "Removing Malwarebytes..." -ForegroundColor Yellow
		Start-Process -FilePath "C:\Program Files (x86)\Malwarebytes\Anti-Malware\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		Write-Host "Removed Malwarebytes." -ForegroundColor Green
	}
	
	if ((Test-Path -Path "C:\Program Files (x86)\Malwarebytes\Anti-Malware\mbuns.exe") -eq $true)
	{
		Write-Host "Found Malwarebytes..." -ForegroundColor Green
		Write-Host "Removing Malwarebytes..." -ForegroundColor Yellow
		Start-Process -FilePath "C:\Program Files (x86)\Malwarebytes\Anti-Malware\mbuns.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		Write-Host "Removed Malwarebytes." -ForegroundColor Green
	}
	
	if ((Test-Path -Path "C:\Program Files\Malwarebytes\Anti-Malware\mbuns.exe") -eq $true)
	{
		Write-Host "Found Malwarebytes..." -ForegroundColor Green
		Write-Host "Removing Malwarebytes..." -ForegroundColor Yellow
		Start-Process -FilePath "C:\Program Files\Malwarebytes\Anti-Malware\mbuns.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
		Write-Host "Removed Malwarebytes." -ForegroundColor Green
	}
	
	if ((Get-Package -Name Malwarebytes*) -eq $true)
	{
		Write-Host "Found Malwarebytes..." -ForegroundColor Green
		Write-Host "Removing Malwarebytes..." -ForegroundColor Yellow
		Get-Package -Name Malwarebytes* | Uninstall-Package -AllVersions -Force
	}
	Write-Host "Malwarebytes removal completed." -ForegroundColor Green
}
else
{
	Write-Host "No Malwarebytes software found." -ForegroundColor Yellow
	Write-Host "Continuing..." -ForegroundColor Green
}
