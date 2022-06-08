<#
    Name: Set-TSdate-Variable.ps1
    Version: 1.0
    Author: Jeremy Thurgood, DWT
    Date: 2022-06-08
    Command: powershell.exe -executionpolicy bypass -file Set-TSdate-Variable.ps1
    Usage:  Run in MEMCM Task Sequence to set Date/time variable.
            
#>


$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment

$tsenv.Value("TSDate") = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
