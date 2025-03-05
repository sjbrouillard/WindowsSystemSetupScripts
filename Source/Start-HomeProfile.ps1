[CmdletBinding()]
param (
    [Parameter(ParameterSetName = 'HomeLaptop')]
    [switch]
    $HomeLaptop,

    [Parameter(ParameterSetName = 'WorkLaptop')]
    [switch]
    $WorkLaptop
)

process {
    if ($HomeLaptop) { Start-HomeLaptopProfile }
    if ($WorkLaptop) { Start-WorkLaptopProfile }
}

begin {
    function Start-HomeLaptopProfile {
      Write-Host "Starting Display Pilot 2..."
      Start-Process -FilePath "C:\Program Files\BenQ\Display Pilot 2\Display Pilot 2.exe"
      
      Write-Host "Starting Elgato Control Center..."
      Start-Process -FilePath "C:\Program Files\Elgato\ControlCenter\ControlCenter.exe" -ArgumentList "-runinbk"
      
      Write-Host "Starting Elgato Stream Deck..."
      Start-Process -FilePath "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe" -ArgumentList "-runinbk"
      
      Write-Host "Starting Adobe Updater Startup Utility..."
      Start-Process -FilePath "C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA\UpdaterStartupUtility.exe"
      
      Write-Host "Starting AdobeGCClient..."
      Start-Process -FilePath "C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient\AGCInvokerUtility.exe"
      
      Write-Host "Starting Adobe Creative Cloud Experience..."
      Start-Process -FilePath "C:\Program Files (x86)\Adobe\Adobe Creative Cloud Experience\CCXProcess.exe"
      
      Write-Host "Starting Adobe Creative Cloud..."
      Start-Process -FilePath "C:\Program Files\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe" -ArgumentList "--showwindow=false", "--onOSstartup=true"
      
      Write-Host "Starting WinZip Update Notifier..."
      Start-Process -FilePath "C:\Program Files\WinZip\WZUpdateNotifier.exe" -ArgumentList "-show"
      
      Write-Host "Starting Brother Software Update Notification Service..."
      Start-Process -FilePath "C:\Program Files (x86)\Brother\SoftwareUpdateNotification\SoftwareUpdateNotificationService.exe" -ArgumentList "/Autorun"
      
      Write-Host "Starting Brother Status Monitor..."
      Start-Process -FilePath "C:\Program Files (x86)\Browny02\Brother\BrStMonW.exe" -ArgumentList "/Autorun"
      
      Write-Host "Starting SpyderUtility..."
      Start-Process -FilePath "C:\Program Files (x86)\Datacolor\SpyderXElite\Utility\SpyderUtility.exe"
      
      Write-Host "Starting Dyn Updater..."
      Start-Process -FilePath "C:\Program Files (x86)\Dyn\Updater\dyn_updater.exe"
      
      Write-Host "Waiting to start BEACN App..."
      Start-Sleep -Seconds 10
      
      Write-Host "Starting BEACN App..."
      Start-Process -FilePath "C:\Program Files\BEACN\BEACN App\BEACN.exe"

      Exit
    }

    function Start-WorkLaptopProfile {
        Write-Host "Starting Display Pilot 2..."
        Start-Process -FilePath "C:\Program Files\BenQ\Display Pilot 2\Display Pilot 2.exe"

        Write-Host "Starting Elgato Stream Deck..."
        Start-Process -FilePath "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe" -ArgumentList "-runinbk"

        Write-Host "Waiting to start BEACN App..."
        Start-Sleep -Seconds 10

        Write-Host "Starting BEACN App..."
        Start-Process -FilePath "C:\Program Files\BEACN\BEACN App\BEACN.exe"

        Exit
    }

}

