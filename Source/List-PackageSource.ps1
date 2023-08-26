$rawJsonList = Get-Content -Path "$($PSScriptRoot)\Toolsets.json" -Raw
$rawObject = $rawJsonList | ConvertFrom-Json
$toolSetList = $rawObject.Toolsets
$coreWingetTools = $toolSetList | Where-Object { $_.ToolsetName -eq "CoreWingetTools" }
foreach ($toolset in $toolSetList) {
    Write-Host $toolset.ToolsetName
}

foreach ($package in $coreWingetTools.Packages) {
    Write-Host $package.id
}