<# 

Rename a computer based on Serial Number.
Will truncate serial numbers longer that the max computer name length of 15 characters, and will remove spaces.

#>

try {
$tsenv = new-object -comobject Microsoft.SMS.TSEnvironment
    }
catch{
Write-Output "Not in TS"
    }

$Serial = (Get-WmiObject -class:win32_bios).SerialNumber
$ComputerName = $Serial
$ComputerName = $ComputerName -replace '\s',''
$ComputerName = $ComputerName.substring(0, [System.Math]::Min(15, $ComputerName.Length))

Write-Output "========================================================="
Write-Output "Setting OSDComputerName to $ComputerName"
try {
$tsenv.value('OSDComputerName') = $ComputerName
} catch {
Write-Output "Not in TS - Could not set TS variable 'OSDComputerName'"
}
Write-Output "========================================================="
