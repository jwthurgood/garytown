# Name: OSDTattoo
# Authors: J�rgen Nilsson CCMEXEC
# Script to tattoo the registry with deployment variables during OS deployment 
$RegKeyName = "DWT\OSD"

# Set values
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$FullRegKeyName = "HKLM:\SOFTWARE\" + $regkeyname 

# Create Registry key
New-Item -Path $FullRegKeyName -type Directory -Force -ErrorAction SilentlyContinue

# Get values
$InstallTime = Get-Date -Format G 
$OSDStartTime = $tsenv.Value("OSDStartTime")
$AdvertisementID = $tsenv.Value("_SMSTSAdvertID")
$Organisation = $tsenv.value("_SMSTSOrgName")
$TaskSequenceID = $tsenv.value("_SMSTSPackageID")
$Packagename = $tsenv.value("_SMSTSPackageName")
$MachineName = $env:computername
$Installationmode = $tsenv.value("_SMSTSLaunchMode")
$TSVersion= $tsenv.value("TSVersion")

#Calculate time elapsed
$OSDTImeSpan = New-TimeSpan -start $OSDstartTime -end $installtime
$OSDDuration = "{0:hh}:{0:mm}:{0:ss}" -f $OSDTimeSpan

# Write values
new-itemproperty $FullRegKeyName -Name "Installed Date" -Value $InstallTime -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty $FullRegKeyName -Name "TSVersion" -Value $TSVersion -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty $FullRegKeyName -Name "OSD Start Time" -Value $OSDStartTime -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty $FullRegKeyName -Name "OSD Duration" -Value $OSDDuration -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty $FullRegKeyName -Name "OrganisationName" -Value $Organisation -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty $FullRegKeyName -Name "AdvertisementID" -Value $AdvertisementID -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty $FullRegKeyName -Name "TaskSequenceID" -Value $TaskSequenceID -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty $FullRegKeyName -Name "Task Sequence Name" -Value $Packagename -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty $FullRegKeyName -Name "Installation Type" -Value $Installationmode -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty $FullRegKeyName -Name "Computer Name" -Value $MachineName -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty $FullRegKeyName -Name "OS Version" -value (Get-CimInstance Win32_Operatingsystem).version -PropertyType String -Force | Out-Null







