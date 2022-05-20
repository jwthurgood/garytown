<#Sysinternals Suite Installer
Gary Blok @gwblok Recast Software

Used with OSDCloud Edition OSD

Downloads the Sysinternal Suite directly from Microsoft
Expands to ProgramFiles\SysInternalsSuite & Adds to Path

Creates shortcut in Start Menu for the items in $Shortcuts Variable
Shortcut Variable based on $_.VersionInfo.InternalName of the exe file for the one you want a shortcut of.


#>



$ScriptName = "Sysinternals-Suite"
$ScriptVersion = "22.03.07.01"

$LogFolder = "C:\Windows\Logs\Software"
if (!(Test-Path -path $LogFolder)){$Null = new-item -Path $LogFolder -ItemType Directory -Force}

$LogFile = "$LogFolder\Sysinternals-Suite_$(Get-Date -format yyyy-MM-dd-HHmm).log"

#Create Shortcuts for:
$ShortCuts = @("Process Explorer", "Process Monitor", "RDCMan.exe", "ZoomIt")

#Download & Extract to Program Files
$FileName = "SysinternalsSuite.zip"
$InstallPath = "$env:ProgramFiles\SysInternalsSuite\"
$ExpandPath = "$env:TEMP\SysInternalsSuiteExpanded"



function CMTraceLog {
         [CmdletBinding()]
    Param (
		    [Parameter(Mandatory=$false)]
		    $Message,
		    [Parameter(Mandatory=$false)]
		    $ErrorMessage,
		    [Parameter(Mandatory=$false)]
		    $Component = "$ComponentText",
		    [Parameter(Mandatory=$false)]
		    [int]$Type,
		    [Parameter(Mandatory=$true)]
		    $LogFile = "$LogFolder\Sysinternals-Suite_$(Get-Date -format yyyy-MM-dd-HHmm).log"
	    )
    <#
    Type: 1 = Normal, 2 = Warning (yellow), 3 = Error (red)
    #>
	    $Time = Get-Date -Format "HH:mm:ss.ffffff"
	    $Date = Get-Date -Format "MM-dd-yyyy"
	    if ($ErrorMessage -ne $null) {$Type = 3}
	    if ($Component -eq $null) {$Component = " "}
	    if ($Type -eq $null) {$Type = 1}
	    $LogMessage = "<![LOG[$Message $ErrorMessage" + "]LOG]!><time=`"$Time`" date=`"$Date`" component=`"$Component`" context=`"`" type=`"$Type`" thread=`"`" file=`"`">"
	    $LogMessage.Replace("`0","") | Out-File -Append -Encoding UTF8 -FilePath $LogFile
    }




CMTraceLog -Message  "--------------------------------------------------------" -Type 1 -LogFile $LogFile
CMTraceLog -Message  "Running Script: $ScriptName | Version: $ScriptVersion" -Type 1 -LogFile $LogFile
CMTraceLog -Message  "--------------------------------------------------------" -Type 1 -LogFile $LogFile

$URL = "https://download.sysinternals.com/files/$FileName"
$DownloadTempFile = "$env:TEMP\$FileName"

CMTraceLog -Message  "Downloading $URL to $DownloadTempFile" -Type 1 -LogFile $LogFile

$progresspreference = 'silentlyContinue'
$Download = Invoke-WebRequest $URL -OutFile $DownloadTempFile
$progressPreference = 'Continue'


#Write-Output "Downloaded Version Newer than Installed Version, overwriting Installed Version"
CMTraceLog -Message  "Downloaded Version Newer than Installed Version, overwriting Installed Version" -Type 1 -LogFile $LogFile
CMTraceLog -Message  "Expanding to $InstallPath" -Type 1 -LogFile $LogFile

$progresspreference = 'silentlyContinue'
Expand-Archive -Path $env:TEMP\$FileName -DestinationPath $InstallPath -Force
$progressPreference = 'Continue'

#ShortCut Folder
if (!(Test-Path -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SysInternals")){$NULL = New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SysInternals" -ItemType Directory}

$Sysinternals = get-childitem -Path $InstallPath
foreach ($App in $Sysinternals)#{}
    {
            $AppInternalName = $App.VersionInfo.InternalName
            $AppName = $App.VersionInfo.ProductName
            $AppFileName = $App.Name
            if ($AppInternalName -in $ShortCuts)
                {
                #Write-Output $AppName
                #Write-Output $AppInternalName
                #Write-Output $AppFileName
                if ($App.Name -match "64")
                    {
                    if ($AppName -match "Sysinternals"){
                        $AppName = $AppName.Replace("Sysinternals ","")
                        }
                    CMTraceLog -Message  "Create Shortcut for $($App.Name)" -Type 1 -LogFile $LogFile
                    #Write-Host "Create Shortcut for $($App.Name)" -ForegroundColor Green
                    #Build ShortCut Information
                    $SourceExe = $App.FullName
                    $ArgumentsToSourceExe = "/AcceptEULA"
                    $DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SysInternals\$($AppName).lnk"

                    #Create Shortcut
                    $WshShell = New-Object -comObject WScript.Shell
                    $Shortcut = $WshShell.CreateShortcut($DestinationPath)
                    $Shortcut.TargetPath = $SourceExe
                    $Shortcut.Arguments = $ArgumentsToSourceExe
                    $Shortcut.Save()
                    }
                else
                    {
                    $64BigVersion = $Sysinternals | Where-Object {$_.Name -match "64" -and $_.VersionInfo.ProductName -match $AppName}
                    if ($64BigVersion){
                        #Write-Output "Found 64Bit Version: $($64BigVersion.Name), Using that instead"
                        }
                    else {
                        if ($AppName -match "Sysinternals"){
                            $AppName = $AppName.Replace("Sysinternals ","")
                            }
                        #Write-Output "No 64Bit Version, use 32bit"
                        #Write-Host "Create Shortcut for $($App.Name)" -ForegroundColor Green
                        CMTraceLog -Message  "Create Shortcut for $($App.Name)" -Type 1 -LogFile $LogFile
                        #Build ShortCut Information
                        $SourceExe = $App.FullName
                        $ArgumentsToSourceExe = "/AcceptEULA"
                        $DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SysInternals\$($AppName).lnk"
                        #Create Shortcut
                        $WshShell = New-Object -comObject WScript.Shell
                        $Shortcut = $WshShell.CreateShortcut($DestinationPath)
                        $Shortcut.TargetPath = $SourceExe
                        $Shortcut.Arguments = $ArgumentsToSourceExe
                        $Shortcut.Save()
                
                        }
                    }
                }
            }

#Add ProgramFiles\SysInternalsSuite to Path

#Get Current Path
$Environment = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$newpath = $Environment.Split(";")
if (!($newpath -contains "$InstallPath")){
            CMTraceLog -Message  "Adding $InstallPath to Path Variable" -Type 1 -LogFile $LogFile
            [System.Collections.ArrayList]$AddNewPathList = $newpath
            $AddNewPathList.Add("$InstallPath")
            $FinalPath = $AddNewPathList -join ";"

            #Set Updated Path
            [System.Environment]::SetEnvironmentVariable("Path", $FinalPath, "Machine")
            }
else
    {
            CMTraceLog -Message  "$InstallPath already in Path Variable" -Type 1 -LogFile $LogFile
            }



CMTraceLog -Message  "--------------------------------------------------------" -Type 1 -LogFile $LogFile
CMTraceLog -Message  "                       Finished                         " -Type 1 -LogFile $LogFile
CMTraceLog -Message  "--------------------------------------------------------" -Type 1 -LogFile $LogFile
