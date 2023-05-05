# I use chocolatey to install and manage a number of tools that I can't get via Winget.
# This script will install chocolatey and then install the tools I use.
[CmdletBinding()]
param (
    [Parameter()]
    [bool]
    $Licensed = $true,

    [Parameter()]
    [string]
    $LicenseLocation = $env:OneDriveConsumer + '\ChocolateyLicense\chocolatey.license.xml',

    [Parameter()]
    [bool]
    $ForceLicenseUpdate = $false
)

Process 
{
  Test-AdminPermissions
  Add-CoreChocoloatey
  if ($Licensed -eq $true)
  {
    Add-ChocolateyLicensing
  }
  Update-Environment
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
  function Add-CoreChocoloatey
  {
    # This is safe to run even on a system that already has Chocolatey installed. It will not overwrite the existing installation.
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  }

  function Add-ChocolateyLicensing
  {
    $foundLicense = Test-Path $LicenseLocation
    if ($foundLicense -eq $false)
    {
      Write-Warning "Chocolatey license not found at $($LicenseLocation). Please ensure that the license is in place before continuing."
      exit
    }

    $licenseLink = "$($env:USERPROFILE)\chocolatey.license.xml"
    $isLicenseLinked = Test-Path $licenseLink

    if (($isLicenseLinked -eq $true) -and ($ForceLicenseUpdate -eq $false))
    {
      Write-Warning "Chocolatey license already linked at $($licenseLink). Use -ForceLicenseUpdate to overwrite."
    }

    if ((($isLicenseLinked -eq $true) -eq $true) -and ($ForceLicenseUpdate -eq $true))
    {
      Remove-Item $licenseLink
    }

    if ($isLicenseLinked -eq $false)
    {
      New-Item -ItemType SymbolicLink -Path $licenseLink -Target $LicenseLocation
    }

    $extensionListOutput = clist -lo -e chocolatey.extension
    $extensionListOutputString = [String]::Join("",$extensionListOutput);
    if ($extensionListOutputString.Contains("chocolatey.extension"))
    {
      Write-Host "Chocolatey extension already installed, upgrading to latest."

      cup chocolatey.extension -y
    }
    else
    {
      Write-Host "Installing Chocolatey extension."
      cinst chocolatey.extension -y
    }
  }

  function Update-Environment 
  { 
    # Update standard environment variables
    foreach($level in "Machine","User")
    {
      [Environment]::GetEnvironmentVariables($level)
    }

    # Update path environment variable - needs to be handled separately
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
  }

  function Add-ChocolateyPackages
  {
    # These are packages that I wasn't able to find via Winget.

    cinst cascadiafonts -y
    cinst chocolatey-azuredatastudio.extension -y
    cinst chocolatey-compatibility.extension -y
    cinst chocolatey-core.extension -y
    cinst chocolatey-font-helpers.extension -y
    cinst chocolatey-windowsupdate.extension -y
    cinst GitVersion.Portable -y
  }
}

End
{

}