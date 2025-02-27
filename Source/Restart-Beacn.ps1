Write-Host "Stopping BEACN App..."
Stop-Process -Name BEACN -Force

Write-Host "Waiting 10 seconds to restart BEACN App..."
Start-Sleep -Seconds 10

Write-Host "Starting BEACN App..."
Start-Process -FilePath "C:\Program Files\BEACN\BEACN App\BEACN.exe"

Exit