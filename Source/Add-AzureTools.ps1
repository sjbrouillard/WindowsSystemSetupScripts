[CmdletBinding()]
param (
    [Parameter()]
    [bool]
    $AutoUpgrade = $true,

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

  function Add-WingetTools
  {
    $wingetToolList = @(
      @{id = "Microsoft.AzureCLI"; },
      @{id = "Microsoft.Azure.AZCopy.10"; },
      @{id = "Microsoft.AzureDataStudio"; },
      @{id = "Microsoft.Azure.FunctionsCoreTools"; },
      @{id = "Microsoft.Azure.CosmosEmulator"; },
      @{id = "Microsoft.Azure.StorageExplorer"; },
      @{id = "Microsoft.Azure.StorageEmulator"; },
      @{id = "Microsoft.Bicep"; },
      @{id = "Pulumi.Pulumi"; },
      @{id = "Hashicorp.Terraform"; },
      @{id = "Microsoft.Azure.Aztfy"; }
    )

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
    $powerShellModuleList =@(
      @{moduleName = "Az"; }
    )

    foreach ($module in $powerShellModuleList)
    {
      # Check if the module is already installed. Upgrade if it is and AutoUpgrade is true.
      $moduleName = $module.moduleName
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