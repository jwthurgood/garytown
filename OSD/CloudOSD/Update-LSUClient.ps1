<#  

Install LSUClient PowerShell Module

#>

$WorkingDir = $env:TEMP

#LSUClient from PSGallery URL
if (!(Get-Module -Name LSUClient)){
    $PowerShellGetURL = "https://www.powershellgallery.com/api/v2/package/LSUClient/1.4.1"
    Invoke-WebRequest -UseBasicParsing -Uri $PowerShellGetURL -OutFile "$WorkingDir\LSUClient.1.4.1.zip"
    $Null = New-Item -Path "$WorkingDir\1.4.1" -ItemType Directory -Force
    Expand-Archive -Path "$WorkingDir\LSUClient.1.4.1.zip" -DestinationPath "$WorkingDir\1.4.1"
    $Null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\LSUClient" -ItemType Directory -ErrorAction SilentlyContinue
    Move-Item -Path "$WorkingDir\1.4.1" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\LSUClient\1.4.1"
    }
