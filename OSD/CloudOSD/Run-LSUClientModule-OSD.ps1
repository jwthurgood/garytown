<#
.SYNOPSIS
    Load and run the LSUClient PowerShell module. Used for installing Lenovo BIOS and Drivers during OSD with Configuration Manager
   
.DESCRIPTION
    Same as above

.NOTES
    Filename: Run-LSUClientModule-OSD.ps1
    Version: 1.0
    Author: Martin Bengtsson
    Blog: www.imab.dk
    Twitter: @mwbengtsson

.LINK
    https://www.imab.dk/install-lenovo-drivers-and-bios-directly-from-lenovos-driver-catalog-during-osd-using-configuration-manager/
    

#> 


## Set the script execution policy for this process
Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'SilentlyContinue'
    } Catch {}

	

$companyName = "DWT"
$global:regKey = "HKLM:\SOFTWARE\$companyName\OSDDrivers"





Function Write-CMTraceLog {
         [CmdletBinding()]
    Param (
		    [Parameter(Mandatory=$false)]
		    $Message,
 
		    [Parameter(Mandatory=$false)]
		    $ErrorMessage,
 
		    [Parameter(Mandatory=$false)]
		    $Component = "CloudOSD_LSUClient",
 
		    [Parameter(Mandatory=$false)]
		    [int]$Type,
		
		    [Parameter(Mandatory=$false)]
		    $LogFile = $LogFile
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
	    $LogMessage | Out-File -Append -Encoding UTF8 -FilePath $LogFile
    }


function Get-LenovoComputerModel() {
	Write-CMTraceLog -Message "Running function: Get-LenovoComputerModel" -Type 1
    $lenovoVendor = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).Vendor
    if ($lenovoVendor = "LENOVO") {
        Write-Verbose -Verbose "Lenovo device is detected. Continuing."
	Write-CMTraceLog -Message "Lenovo device is detected. Continuing." -Type 1
        $global:lenovoModel = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).Version
        $modelRegEx = [regex]::Match((Get-CimInstance -ClassName CIM_ComputerSystem -ErrorAction SilentlyContinue -Verbose:$false).Model, '^\w{4}')
        if ($modelRegEx.Success -eq $true) {
            $global:lenovoModelNumber = $modelRegEx.Value
            Write-Verbose -Verbose "Lenovo modelnumber: $global:lenovoModelNumber - Lenovo model: $global:lenovoModel"
        } else {
			Write-Verbose -Verbose "Failed to retrieve computermodel"
            Write-CMTraceLog -Message "Failed to retrieve computermodel" -Type 1
			
        } 
    } else {
	Write-Verbose -Verbose "Not a Lenovo device. Aborting."
        Write-CMTraceLog -Message "Not a Lenovo device. Aborting." -Type 1
        exit 1
    }  
}


function Load-LSUClientModule() {
	Write-CMTraceLog -Message "Running function: Load-LSUClientModule" -Type 1
    if (-NOT(Get-Module -Name LSUClient)) {
        Write-Verbose -Verbose "LSUClient module not loaded. Continuing."
	Write-CMTraceLog -Message "LSUClient module not loaded. Continuing." -Type 1
        if (Get-Module -Name LSUClient -ListAvailable) {
            Write-Verbose -Verbose "LSUClient module found available. Try importing and loading it."
			Write-CMTraceLog -Message "LSUClient module found available. Try importing and loading it." -Type 1
            try {
		Install-Module -Name LSUClient -Force
                Import-Module -Name LSUClient -Force
                Write-Verbose -Verbose "Successfully installed, imported and loaded the LSUClient module."
				Write-CMTraceLog -Message "Successfully installed, imported and loaded the LSUClient module." -Type 1
            } catch {
                Write-Verbose -Verbose "Failed to install or import the LSUClient module. Aborting."
		Write-CMTraceLog -Message "Failed to install or import the LSUClient module. Aborting." -Type 1
                exit 1
            }
        }
    } else {
        Write-Verbose -Verbose "LSUClient module already installed and/or imported and loaded."
		Write-CMTraceLog -Message "LSUClient module already installed and/or imported and loaded." -Type 1
    }
}


#Function for locating and installing all drivers and BIOS which can be installed silent and unattended
function Run-LSUClientModuleDefault() {
    Write-CMTraceLog -Message "Running function: Run-LSUClientModuleDefault" -Type 1
    $regKey = $global:regKey
    if (-NOT(Test-Path -Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
    Write-Verbose -Verbose "Searching for Lenovo updates..."
    Write-CMTraceLog -Message "Searching for Lenovo updates..." -Type 1

    $updates = Get-LSUpdate |
     Where-Object { $_.Installer.Unattended -AND $_.Type -eq 'Driver' -AND $_.Title -notmatch "BIOS|UEFI|Graphics|Firmware" -AND $_.RebootType -ne 5 }
	if ($updates -ne $null) {
		Write-Verbose -Verbose "Downloading updates"
		Write-CMTraceLog -Message "Downloading updates" -Type 1
		foreach ($update in $updates) {
			Install-LSUpdate $update -Verbose
			New-ItemProperty -Path $regKey -Name $update.ID -Value $update.Title -Force | Out-Null
			Write-CMTraceLog -Message "Update ID: ${update.ID}     Update Title: ${update.Title}" -Type 1
		} 
	} else {
		Write-Verbose -Verbose "No updates found and/or needed."
		Write-CMTraceLog -Message "No updates found and/or needed." -Type 1
    }	
}


#Exclude Intel Graphics Driver
#Some weird shit going on with the package here on certain models, making the script run forever, thus exlcuding the driver
function Run-LSUClientModuleCustom() {
    Write-CMTraceLog -Message "Running function: Run-LSUClientModuleCustom" -Type 1
    $regKey = $global:regKey
    if (-NOT(Test-Path -Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
    Write-Verbose -Verbose "Searching for Lenovo updates..."
	Write-CMTraceLog -Message "Searching for Lenovo updates..." -Type 1

    $updates = Get-LSUpdate | Where-Object { $_.Installer.Unattended -AND $_.Title -notlike "Intel HD Graphics Driver*"}
    if ($updates -ne $null) {
    	Write-Verbose -Verbose "Downloading updates"
	Write-CMTraceLog -Message "Downloading updates" -Type 1
        foreach ($update in $updates) {
            Install-LSUpdate $update -Verbose
            New-ItemProperty -Path $regKey -Name $update.ID -Value $update.Title -Force | Out-Null
            Write-CMTraceLog -Message "Update ID: ${update.ID}     Update Title: ${update.Title}" -Type 1
		} 
	} else {
		Write-Verbose -Verbose "No updates found and/or needed."
		Write-CMTraceLog -Message "No updates found and/or needed." -Type 1
    }
}


# Configuration ##################################################################

$LogFolder = "C:\Windows\Logs\Software"
    
if (!(Test-Path -path $LogFolder)){$Null = new-item -Path $LogFolder -ItemType Directory -Force}

$ScriptVer = "2022.05.13"
$Component = "CloudOSD_LSUClient"
$LogFile = "$LogFolder\CloudOSD_LSUClient_$(Get-Date -format yyyy-MM-dd-HHmm).log"

Write-Output "Starting script to Install Lenovo Drivers and BIOS"

Write-CMTraceLog -Message "=====================================================" -Type 1
Write-CMTraceLog -Message "Lenovo Drivers and BIOS: Script version $ScriptVer..." -Type 1
Write-CMTraceLog -Message "=====================================================" -Type 1
Write-CMTraceLog -Message "Running Script as $env:USERNAME" -Type 1 


## Set the Installation Policy for PSRepository for PSGallery
Try { Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    } Catch {
    write-output "Failed to set PSReposity Installation Policy to Trusted for PSGallery"
    Write-CMTraceLog -Message "Failed to set PSReposity Installation Policy to Trusted for PSGallery" -Type 3
    }


## Install the module LSUClient
Try { Install-Module -Name LSUClient -Force
    } Catch {
    write-output "Failed to install the LSUClient PowerShell Module"
    Write-CMTraceLog -Message "Failed to install the LSUClient PowerShell Module" -Type 3
    }
	
## Import the module LSUClient
Try { Import-Module -Name LSUClient -Force
    } Catch {
    write-output "Failed to load the LSUClient PowerShell Module"
    Write-CMTraceLog -Message "Failed to load the LSUClient PowerShell Module" -Type 3
    }



try {
    Write-CMTraceLog -Message "Starting script to Install Lenovo Drivers and BIOS" -Type 1
    Get-LenovoComputerModel
    Load-LSUClientModule
    if ($global:lenovoModelNumber -eq "20QF") {
        Run-LSUClientModuleCustom
    } else {
        Run-LSUClientModuleDefault
    }
}
catch [Exception] {
    Write-CMTraceLog -Message "Script failed to carry out one or more actions." -Type 3
    Write-CMTraceLog -Message "$_.Exception.Message" -Type 3
	if (-NOT(Test-Path -Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
	New-ItemProperty -Path $regKey -Name "_ExceptionMessage" -Value $_.Exception.Message -Force | Out-Null
    exit 1
}
finally { 
    $currentDate = Get-Date -Format g
    if (-NOT(Test-Path -Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
    New-ItemProperty -Path $regKey -Name "_RunDateTime" -Value $currentDate -Force | Out-Null
    New-ItemProperty -Path $regKey -Name "_LenovoModelNumber" -Value $global:lenovoModelNumber -Force | Out-Null
    New-ItemProperty -Path $regKey -Name "_LenovoModel" -Value $global:lenovoModel -Force | Out-Null
    Write-Output "Ending script to Install Lenovo Drivers and BIOS"
	
    Write-CMTraceLog -Message "Ending script to Install Lenovo Drivers and BIOS" -Type 1
    Write-CMTraceLog -Message "=====================================================" -Type 1
    Write-CMTraceLog -Message "Registry tatooed at: $global:regKey" -Type 1
    Write-CMTraceLog -Message "=====================================================" -Type 1
}
