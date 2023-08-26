[CmdletBinding()]
param (
    [Parameter()]
    [bool]
    $AutoUpgrade = $false,

    [Parameter()]
    [string]
    [ValidateSet("2019","2022")]
    $VsVersion = "2022",

    [Parameter()]
    [string]
    [ValidateSet("Community","Professional","Enterprise")]
    $VsEdition = "Professional",

    [Parameter()]
    [string]
    $ToolSetPath = "$($PSScriptRoot)\Toolsets.json",
    
    [Parameter()]
    [bool]
    $ExcludeWingetTools = $false,

    [Parameter()]
    [bool]
    $ExcludeVSCodeExtensions = $false
)

Process
{
  Test-AdminPermissions
  Test-ToolSetPath
  Set-ToolSets
  if (!$ExcludeWingetTools) { Add-WingetTools }
  if (!$ExcludeVSCodeExtensions) { Add-VSCodeExtensions }
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
    $script:devWingetToolset = $private:rawObject.Toolsets | Where-Object { $_.ToolsetName -eq "DevWingetTools" }
    $script:devVsCodeExtensions = $private:rawObject.Toolsets | Where-Object { $_.ToolsetName -eq "VsCodeExtenstions" }
  }

  function Add-WingetTools
  {
    $VisulaStudioConfigPath = "$($env:OneDriveConsumer)\Dev Settings\VSInstallConfigs\Microsoft.VisualStudio.2022.$($vsEdition).vsconfig"
    $wingetToolList = $script:devWingetToolset.Packages

    foreach ($tool in $wingetToolList)
    {
      $toolId = $tool.id
      $toolIdString = [String]::Join("",$toolId)
      $toolInfo = winget list --id $toolIdString
      $toolInfoString = [String]::Join("",$toolInfo)

      # Check if the tool is already installed. Upgrade if it is and AutoUpgrade is true.
      if ($toolInfoString.Contains($toolIdString)) 
      {
        if ($AutoUpgrade)
        {
          winget upgrade --id $toolIdString
        }
      }

      # Install the tool if it is not already installed.
      else
      {
        # Special case for Visual Studio. This allows for a config file to be used if present.
        if ($toolId.Contains("Microsoft.VisualStudio.$($VsVersion).$($vsEdition)"))
        {
          Add-VisualStudio -toolId $toolId -configPath $VisulaStudioConfigPath
        }
        else
        {
          winget install --id $toolIdString
        }
      }
    }

  }

  function Add-VisualStudio
  {
    param (
      [Parameter(Mandatory=$true)]
      [string]
      $toolId,

      [Parameter(Mandatory=$true)]
      [string]
      $configPath
    )

    $isValidConfigPath = Test-Path $configPath

    if ($isValidConfigPath)
    {
      winget install --id $toolIdString --silent --override "--config $VisulaStudioConfigPath"
    }
    else
    {
      Write-Host "Visual Studio $($VsVersion) $($vsEdition) config file not found at $($VisulaStudioConfigPath). Installing without config file."
      winget install --id $toolIdString
    }
  }

  function Add-VSCodeExtensions
  {
    $vsCodeExtensionList = $script:devVsCodeExtensions.Packages

    foreach ($extension in $vsCodeExtensionList)
    {
      # Check if the extension is already installed and install if it's not there.
      $extensionName = $extension.id
      $extensionInfo = code --list-extensions | Select-String -Pattern $extensionName
      if (!$extensionInfo)
      {
        code --install-extension $extensionName
      }
    }
  }
}

End
{

}