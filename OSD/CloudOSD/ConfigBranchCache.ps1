#Gary Blok @GWBLOK - Settings and Process taken from 2PintSoftware.com's recommendations. 

#Set the BranchCache Port Variable
#the default is 80 so we want to change this to avoid conflicts with other apps that might use that port.
$BCPORT = '1337'

#Set the BranchCache  Serve On Battery Variable
$serveonbattery = 'TRUE'

#Set the BranchCache Cache Age Variable
#Sets the age in days for how long untouched data will remain in the cache before being cleaned out.
$TTL = '365'

#Stop the BranchCache Service
#Avoids errors in the event log when we reconfigure the port in the next steps
Stop-Service -Name PeerDistSvc -Force

#Set BranchCache ListenPort to %BCPORT%
#Sets the port of which BranchCache uses to listen for  other peers requesting data.
New-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\PeerDist\DownloadManager\Peers\Connection" -Force
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\PeerDist\DownloadManager\Peers\Connection" -Name ListenPort -PropertyType DWORD -Value $BCPORT -Force

#Set BranchCache Cache Time To Live for cached data
#Sets the threshold for how long data is in the cache before its being removed out.
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PeerDist\Retrieval" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PeerDist\Retrieval" -Name SegmentTTL -PropertyType DWORD -Value $TTL -Force


#Enables BranchCache in distributed mode
Start-Process netsh -ArgumentList "branchcache set service mode=distributed serveonbattery=% serveonbattery%:" -PassThru -Wait

#Set BranchCache Cache Size to 50% of disk space
#Can be set high on Windows 10 due to the BranchCache low disk space detection.
Start-Process netsh -ArgumentList "branchcache set cachesize size=50 percent=TRUE" -PassThru -Wait

#Set BranchCache service start mode to Automatic
#Sets the starup of the BranchCache service to automatic to enable servicing other clients even if not actively downloading.
Set-Service -Name PeerDistSvc -StartupType Automatic
