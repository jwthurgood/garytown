<# Default Windows User Profile Images
Gary Blok @gwblok Recast Software

Used with OSDCloud Edition OSD

Grabs User Images from GitHub Repo and replaces default ones.
Just replace the RootURL with your own upload location

#>


try {$tsenv = new-object -comobject Microsoft.SMS.TSEnvironment}
catch{Write-Output "Not in TS"}
if ($tsenv){$InWinPE = $tsenv.value('_SMSTSInWinPE')}

if ($InWinPE -ne "TRUE"){
$InstallPath = "$env:ProgramData\Microsoft\User Account Pictures"
}

if ($InWinPE -eq "TRUE"){
$InstallPath = "c:\ProgramData\Microsoft\User Account Pictures"
}

$RootURL = "https://raw.githubusercontent.com/gwblok/garytown/master/OSD/CloudOSD/UserPics/"
$Files = @(
"guest.png"
"user-192.png"
"user-200.png"
"user-32.png"
"user-40.png"
"user-48.png"
"user.png"
)

#Clear Folder Contents
Get-ChildItem -Path $InstallPath | Remove-Item -Force

#Replace Contents with my Contents
foreach ($File in $Files){
    Write-Output "Downloading $RootURL/$File"
    Invoke-WebRequest -UseBasicParsing -Uri "$RootURL/$File" -OutFile "$env:TEMP\$File"
    Write-Output "Running Command: Copy-Item $($env:TEMP)\$File $InstallPath\$file -Force -Verbose"
    Copy-Item "$env:TEMP\$file" -Destination "$InstallPath\$file" -Force -Verbose
    }
