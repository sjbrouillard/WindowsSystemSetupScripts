[CmdletBinding()]
param (
    [Parameter()]
    [bool]
    $AutoUpgrade = $true,

    [Parameter()]
    [string]
    $ToolSetPath = "$($PSScriptRoot)\Toolsets.json",

    [Parameter()]
    [bool]
    $ExcludeWingetTools = $false,

    [Parameter()]
    [bool]
    $ExcludePowerShellModules = $false
)

Process
{
  Test-AdminPermissions
  Test-ToolSetPath
  Set-ToolSets
  if (!$ExcludeWingetTools) { Add-WingetTools }
  if (!$ExcludePowerShellModules) { Add-PowerShellModules }
}

Begin
{
  function Test-AdminPermissions
  {
    # Check for admin permissions and drop out if not running as admin.
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if ($IsAdmin -eq $false)
    {
      Write-Warning "This script requires elevated permissions. Please run this script as an administrator."
      exit
    }
  }

  function Test-ToolSetPath
  {
    if ([string]::IsNullOrWhiteSpace($ToolSetPath))
    {
      Throw "ToolSetPath parameter can't be null or empty."
    }

    if (!(Test-Path $ToolSetPath))
    {
      Throw "$($ToolSetPath) not found. Please validate path."
    }
  }

  function Set-ToolSets
  {
    $private:rawToolsetJson = Get-Content -Path "$($PSScriptRoot)\Toolsets.json" -Raw
    $private:rawObject = $private:rawToolsetJson | ConvertFrom-Json
    $script:azureWingetToolset = $private:rawObject.Toolsets | Where-Object { $_.ToolsetName -eq "AzureWingetTools" }
    $script:azurePowerShellModuleToolset = $private:rawObject.Toolsets | Where-Object { $_.ToolsetName -eq "AzurePowerShellModules" }
  }

  function Add-WingetTools
  {
    $wingetToolList = $script:azureWingetToolset.Packages

    foreach ($tool in $wingetToolList)
    {
      $toolId = $tool.id
      $toolIdString = [String]::Join("",$toolId)
      $toolInfo = winget list --id $toolIdString
      $toolInfoString = [String]::Join("",$toolInfo)

      if ($toolInfoString.Contains($toolIdString)) 
      {
        if ($AutoUpgrade)
        {
          winget upgrade --id $toolIdString
        }
      }
      else
      {
        winget install --id $toolIdString
      }
    }
  }

  function Add-PowerShellModules
  {
    $powerShellModuleList = $script:azurePowerShellModuleToolset.Packages

    foreach ($module in $powerShellModuleList)
    {
      # Check if the module is already installed. Upgrade if it is and AutoUpgrade is true.
      $moduleName = $module.id
      $moduleInfo = Get-Module -ListAvailable -Name $moduleName
      if ($moduleInfo)
      {
        if ($AutoUpgrade)
        {
          Update-Module -Name $moduleName
        }
      }
      else
      {
        Install-Module -Name $moduleName
      }
    }
  }
}

End
{

}