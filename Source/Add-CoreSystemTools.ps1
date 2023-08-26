
[CmdletBinding()]
param (
    [Parameter()]
    [bool]
    $AutoUpgrade = $true,

    [Parameter()]
    [string]
    $ToolSetPath = "$($PSScriptRoot)\Toolsets.json",

    [Parameter()]
    [switch]
    $ExcludeWingetTools,

    [Parameter()]
    [switch]
    $ExcludeGitConfigurations,

    [Parameter()]
    [switch]
    $ExcludePowerShellModules
)

Process
{
  Test-AdminPermissions
  Test-ToolSetPath
  Set-ToolSets
  if (!$ExcludeWingetTools) { Add-WingetTools }
  if (!$ExcludePowerShellModules) { Add-PowerShellModules }
  if (!$ExcludeGitConfigurations) { Set-GitConfigurations }
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
    $script:coreWingetToolset = $private:rawObject.Toolsets | Where-Object { $_.ToolsetName -eq "CoreWingetTools" }
    $script:corePowerShellModuleToolset = $private:rawObject.Toolsets | Where-Object { $_.ToolsetName -eq "CorePowerShellModules" }
  }

  function Add-WingetTools
  {
    $toolList = $script:coreWingetToolset.Packages

    foreach ($tool in $toolList)
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
    $powerShellModuleList = $script:corePowerShellModuleToolset.Packages

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

  function Set-GitConfigurations
  {
    # Set my deafult .gitconfig file.
    # Configure Git to use the Yubikey for SSH authentication.
    # Configure Git to use the Yubikey for GPG signing.
    # Configure Git to use the Yubikey for GPG encryption.

    $defaultPlinkPath = "C:\Program Files\PuTTY\plink.exe"
    $isPlinkPathValid = Test-Path $defaultPlinkPath
    $gpgConfigDestinationPath = "$($env:APPDATA)\gnupg"
    $isGPGConfigDestinationPathValid = Test-Path $gpgConfigDestinationPath
    $gpgConfigSourcePath = "$($env:OneDriveConsumer)\Dev Settings\GPG"
    $isGpgConfigSourcePathValid = Test-Path $gpgConfigSourcePath
    $gpgConfigFile = "gpg.conf"
    $scDaemonConfigFile = "scdaemon.conf"
    $gpgAgentConfigFile = "$gpg-agent.conf"
    $customGitConfigSourcePath = "$($env:OneDriveConsumer)\Dev Settings\Git\.gitconfig"
    $isCustomGitConfigSourcePathValid = Test-Path $customGitConfigSourcePath
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

    # Check for required files and paths.
    if (!$isGPGConfigDestinationPathValid)
    {
      Write-Host "GPG config destination path not found. Validate that GPG is installed and try again."
      Exit
    }

    if (!$isPlinkPathValid)
    {
      Write-Host "Plink not found at default location. Validate that PuTTY is installed and try again."
      Exit
    }

    if (!$isGpgConfigSourcePathValid)
    {
      Write-Host "GPG config source path not found. Validate that OneDrive is installed and in sync, then try again."
      Exit
    }

    if (!$isCustomGitConfigSourcePathValid)
    {
      Write-Host "Custom Git config source path not found. Validate that OneDrive is installed and in sync, then try again."
      Exit
    }

    # Configure GPG for signing commits and using the Yubikey for key storage.
    if (Test-Path "$gpgConfigDestinationPath\$gpgConfigFile")
    {
      Write-Host "Backing up existing GPG config file."
      Copy-Item "$($gpgConfigDestinationPath)\$($gpgConfigFile)" "$($gpgConfigDestinationPath)\$($gpgConfigFile).$($timestamp).bak"
      Write-Host "Removing existing GPG config file."
      Remove-Item "$($gpgConfigDestinationPath)\$($gpgConfigFile)"
    }
    Write-Host "Creating SymLink to OneDrive GPG config file."
    New-Item -ItemType SymbolicLink -Path "$($gpgConfigDestinationPath)\$($gpgConfigFile)" -Target "$($gpgConfigSourcePath)\$($gpgConfigFile)"
    
    if (Test-Path "$gpgConfigDestinationPath\$scDaemonConfigFile")
    {
      Write-Host "Backing up existing scdaemon config file."
      Copy-Item "$($gpgConfigDestinationPath)\$($scDaemonConfigFile)" "$($gpgConfigDestinationPath)\$($scDaemonConfigFile).$($timestamp).bak"
      Write-Host "Removing existing scdaemon config file."
      Remove-Item "$($gpgConfigDestinationPath)\$($scDaemonConfigFile)"
    }
    Write-Host "Creating SymLink to OneDrive scdaemon config file."
    New-Item -ItemType SymbolicLink -Path "$($gpgConfigDestinationPath)\$($scDaemonConfigFile)" -Target "$($gpgConfigSourcePath)\$($scDaemonConfigFile)"

    if (Test-Path "$gpgConfigDestinationPath\$gpgAgentConfigFile")
    {
      Write-Host "Backing up existing gpg-agent config file."
      Copy-Item "$($gpgConfigDestinationPath)\$($gpgAgentConfigFile)" "$($gpgConfigDestinationPath)\$($gpgAgentConfigFile).$($timestamp).bak"
      Write-Host "Removing existing gpg-agent config file."
      Remove-Item "$($gpgConfigDestinationPath)\$($gpgAgentConfigFile)"
    }
    Write-Host "Creating SymLink to OneDrive gpg-agent config file."
    New-Item -ItemType SymbolicLink -Path "$($gpgConfigDestinationPath)\$($gpgAgentConfigFile)" -Target "$($gpgConfigSourcePath)\$($gpgAgentConfigFile)"

    # Configure Git to use my custom .gitconfig file.
    if (Test-Path "$($env:USERPROFILE)\.gitconfig")
    {
      Write-Host "Backing up existing .gitconfig file."
      Copy-Item "$($env:USERPROFILE)\.gitconfig" "$($env:USERPROFILE)\.gitconfig.bak"
      Write-Host "Removing existing .gitconfig file."
      Remove-Item "$($env:USERPROFILE)\.gitconfig"
    }
    Write-Host "Creating SymLink to OneDrive .gitconfig file."
    New-Item -ItemType SymbolicLink -Path "$($env:USERPROFILE)\.gitconfig" -Target "$($customGitConfigSourcePath)"
    
    # Configure Git to use Putty for SSH and set the default path to plink.exe.
    [Environment]::SetEnvironmentVariable("GIT_SSH", $defaultPlinkPath, "User")
  }
}

End
{

}