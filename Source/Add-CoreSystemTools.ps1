
[CmdletBinding()]
param (
    [Parameter()]
    [bool]
    $AutoUpgrade = $true
)

Process
{
  Test-AdminPermissions
  Add-CoreTools
  Set-GitConfigurations
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
  function Add-CoreTools
  {
    $toolList = @(
      @{id = "Microsoft.PowerShell"; },
      @{id = "Microsoft.PowerToys"; },
      @{id = "Microsoft.WindowsTerminal"; },
      @{id = "Microsoft.OpenSSH.Beta"; },
      @{id = "ShiningLight.OpenSSL"; },
      @{id = "Docker.DockerDesktop"},
      @{id = "Git.Git"},
      @{id = "ScooterSoftware.BeyondCompare4"},
      @{id = "BinaryFortress.DisplayFusion"},
      @{id = "Microsoft.VisualStudioCode"},
      @{id = "Discord.Discord"},
      @{id = "JGraph.Draw"},
      @{id = "evernote.evernote"},
      @{id = "GnuPG.Gpg4win"},
      @{id = "HermannSchinagl.LinkShellExtension"},
      @{id = "Miro.Miro"},
      @{id = "NewTek.NDI5Tools"},
      @{id = "OBSProject.OBSStudio"},      
      @{id = "PuTTY.PuTTY"},
      @{id = "RaspberryPiFoundation.RaspberryPiImager"},
      @{id = "Rufus.Rufus"},
      @{id = "SlackTechnologies.Slack"},
      @{id = "Spotify.Spotify"},
      @{id = "TechSmith.Snagit.2023"},
      @{id = "Win32diskimager.win32diskimager"},
      @{id = "WinSCP.WinSCP"},
      @{id = "Corel.WinZip"},
      @{id = "WireGuard.WireGuard"},
      @{id = "Yubico.YubikeyManager"},
      @{id = "Yubico.Authenticator"},
      @{id = "Zoom.Zoom"}
    )

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

  function Set-GitConfigurations
  {
    # Set my deafult .gotconfig file.
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
      Copy-Item "$($gpgConfigDestinationPath)\$($gpgConfigFile)" "$($gpgConfigDestinationPath)\$($gpgConfigFile).bak"
    }
    Write-Host "Creating SymLink to OneDrive GPG config file."
    New-Item -ItemType SymbolicLink -Path "$($gpgConfigDestinationPath)\$($gpgConfigFile)" -Target "$($gpgConfigSourcePath)\$($gpgConfigFile)"
    
    if (Test-Path "$gpgConfigDestinationPath\$scDaemonConfigFile")
    {
      Write-Host "Backing up existing scdaemon config file."
      Copy-Item "$($gpgConfigDestinationPath)\$($scDaemonConfigFile)" "$($gpgConfigDestinationPath)\$($scDaemonConfigFile).bak"
    }
    Write-Host "Creating SymLink to OneDrive scdaemon config file."
    New-Item -ItemType SymbolicLink -Path "$($gpgConfigDestinationPath)\$($scDaemonConfigFile)" -Target "$($gpgConfigSourcePath)\$($scDaemonConfigFile)"

    if (Test-Path "$gpgConfigDestinationPath\$gpgAgentConfigFile")
    {
      Write-Host "Backing up existing gpg-agent config file."
      Copy-Item "$($gpgConfigDestinationPath)\$($gpgAgentConfigFile)" "$($gpgConfigDestinationPath)\$($gpgAgentConfigFile).bak"
    }
    Write-Host "Creating SymLink to OneDrive gpg-agent config file."
    New-Item -ItemType SymbolicLink -Path "$($gpgConfigDestinationPath)\$($gpgAgentConfigFile)" -Target "$($gpgConfigSourcePath)\$($gpgAgentConfigFile)"

    # Configure Git to use my custom .gitconfig file.
    if (Test-Path "$($env:USERPROFILE)\.gitconfig")
    {
      Write-Host "Backing up existing .gitconfig file."
      Copy-Item "$($env:USERPROFILE)\.gitconfig" "$($env:USERPROFILE)\.gitconfig.bak"
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