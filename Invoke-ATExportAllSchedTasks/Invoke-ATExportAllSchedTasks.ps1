<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Script was developed from this website. 
    https://powershelladministrator.com/2017/06/27/exporting-all-scheduled-tasks/
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>



$LogFile = "C:\Superior\ScheduledTasks\ExportScheduledTasks.log"
$BackupPath = "C\Superior\ScheduledTasks\ExportTasks"
$TaskFolders = (Get-ScheduledTask).TaskPath | Where { ($_ -notmatch "Microsoft") -and ($_ -notmatch "OfficeSoftware") } | Select -Unique
Start-Transcript -Path $LogFile
Write-Output "Start exporting of scheduled tasks."

If(Test-Path -Path $BackupPath)
{
Remove-Item -Path $BackupPath -Recurse -Force
}
md $BackupPath | Out-Null

Foreach ($TaskFolder in $TaskFolders)
{
Write-Output "Task folder: $TaskFolder"
If($TaskFolder -ne "\") { md $BackupPath$TaskFolder | Out-Null }
$Tasks = Get-ScheduledTask -TaskPath $TaskFolder -ErrorAction SilentlyContinue
Foreach ($Task in $Tasks)
{
$TaskName = $Task.TaskName
If(($TaskName -match "User_Feed_Synchronization") -or ($TaskName -match "Optimize Start Menu Cache Files"))
{
}
Else
{
$TaskInfo = Export-ScheduledTask -TaskName $TaskName -TaskPath $TaskFolder
$TaskInfo | Out-File "$BackupPath$TaskFolder$TaskName.xml"
Write-Output "Saved file $BackupPath$TaskFolder$TaskName.xml"
}
}
}

Write-Output "Exporting of scheduled tasks finished."
Stop-Transcript