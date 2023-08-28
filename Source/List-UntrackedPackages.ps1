$rawToolSetsJsonList = Get-Content -Path "$($PSScriptRoot)\Toolsets.json" -Raw
$rawToolSetObject = $rawToolSetsJsonList | ConvertFrom-Json
$toolSetList = $rawToolSetObject.Toolsets
$coreWingetTools = $toolSetList | Where-Object { $_.ToolsetName -eq "CoreWingetTools" }
$azureWingetTools = $toolSetList | Where-Object { $_.ToolsetName -eq "AzureWingetTools" }
$devWingetTools = $toolSetList | Where-Object { $_.ToolsetName -eq "DevWingetTools" }

$allDefinedWingetIdList = @()

foreach ($tool in $coreWingetTools.Packages)
{
  $allDefinedWingetIdList += $tool.id
}

foreach ($tool in $azureWingetTools.Packages)
{
  $allDefinedWingetIdList += $tool.id
}

foreach ($tool in $devWingetTools.Packages)
{
  $allDefinedWingetIdList += $tool.id
}

if (Test-Path -Path "$($PSScriptRoot)\wingetsrc.json") {
    Write-Host "Removing $($PSScriptRoot)\wingetsrc.json"
    Remove-Item -Path "$($PSScriptRoot)\wingetsrc.json"
}

Write-Host "Creating $($PSScriptRoot)\wingetsrc.json"
winget export --source winget --output "$($PSScriptRoot)\wingetsrc.json"

$rawInstalledWingetJsonList = Get-Content -Path "$($PSScriptRoot)\wingetsrc.json" -Raw
$rawInstalledWingetObject = $rawInstalledWingetJsonList | ConvertFrom-Json
$installedWingetTools = $rawInstalledWingetObject.Sources | Where-Object { $_.SourceDetails.Name -eq "winget" }

$installedWingetIdList = @()
foreach ($tool in $installedWingetTools.Packages)
{
  $installedWingetIdList += $tool.PackageIdentifier
}

$notTrackedList = @()

foreach ($id in $installedWingetIdList)
{
  if ($allDefinedWingetIdList -notcontains $id)
  {
    $notTrackedList += $id
  }
}

Write-Host "Not Tracked: $($notTrackedList.Count)"

foreach ($id in $notTrackedList)
{
  Write-Host "Not Tracked: $id"
}