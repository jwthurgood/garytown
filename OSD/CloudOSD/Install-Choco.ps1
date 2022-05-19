
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Allow Global Confirmation
choco feature enable --name 'allowGlobalConfirmation'

# Set as package provider
get-packageprovider -Name Chocolatey -Force

# Set as trusted
Set-PackageSource -Name Chocolatey -Trusted -Force
Set-PackageSource -Name PSGallery -Trusted -Force

# Run the following commands to enable TLS 1.2 support.  Enables Nuget and Chocolatey to return results when using find-package (as Nuget and Chocolatey require TLS 1.2 or higher)
# The SystemDefaultTlsVersions setting allows .NET to use the OS configuration (which in Windows 11 is TLS 1.3 & 1.2)
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:64
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:32
