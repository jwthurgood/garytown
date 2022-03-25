$action = New-ScheduledTaskAction -Execute "C:\windows\system32\Sysprep\sysprep.exe" -Argument "/OOBE /REBOOT"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings
Register-ScheduledTask T1 -InputObject $task -User SYSTEM
