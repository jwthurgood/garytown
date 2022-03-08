<# Default Windows User Profile Images
Gary Blok @gwblok Recast Software

Used with OSDCloud Edition OSD

Grabs User Images from GitHub Repo and replaces default ones.
Just replace the RootURL with your own upload location

#>
$InstallPath = "$env:ProgramData\Microsoft\User Account Pictures"
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

foreach ($File in $Files){
    Write-Output "Downloading $RootURL/$File"
    Invoke-WebRequest -UseBasicParsing -Uri "$RootURL/$File" -OutFile "$env:TEMP\$File"
    Write-Output "Running Command: Copy-Item $($env:TEMP)\$File $InstallPath\$file -Force -Verbose"
    Copy-Item "$env:TEMP\$file" -Destination "$InstallPath\$file" -Force -Verbose
    }