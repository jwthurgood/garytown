


$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment

$tsenv.Value("TSDate") = Get-Date -format "yyyyMMdd-hhmm"
