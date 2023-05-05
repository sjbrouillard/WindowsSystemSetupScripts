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
    [bool]
    $ExcludeWingetTools = $false,

    [Parameter()]
    [bool]
    $ExcludeVSCodeExtensions = $false
)

Process
{
  Test-AdminPermissions
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

  function Add-WingetTools
  {
    $VisulaStudioConfigPath = "$($env:OneDriveConsumer)\Dev Settings\VSInstallConfigs\Microsoft.VisualStudio.2022.$($vsEdition).vsconfig"
    $wingetToolList = @(
      @{id = "Curl.Curl"; },
      @{id = "Docker.DockerDesktop"},
      @{id = "OpenJS.NodeJS"},
      @{id = "Microsoft.VisualStudio.$($VsVersion).$($vsEdition)"},
      @{id = "KirillOsenkov.MSBuildStructuredLogViewer"},
      @{id = "Microsoft..VisualStudio.$($VsVersion).BuildTools"},
      @{id = "Microsoft.VisualStudio.ConfigFinder"},
      @{id = "Microsoft.VisualStudioCode"},
      @{id = "LINQPad.LINQPad.7"},
      @{id = "Postman.Postman"; },
      @{id = "Postman.Postman.DesktopAgent"},
      @{id = "Microsoft.PowerAutomateDesktop"}   
    )

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
    $vsCodeExtensionList = @(
      @{extensionName = "ms-dotnettools.vscode-dotnet-runtime"; },
      @{extensionName = "wilfriedwoivre.arm-params-generator"; },
      @{extensionName = "ms-vscode.powershell"; },
      @{extensionName = "bencoleman.armview"; },
      @{extensionName = "ms-vscode.azure-account"; },
      @{extensionName = "ms-azuretools.vscode-azureappservice"; },
      @{extensionName = "ms-vscode.azurecli"; },
      @{extensionName = "ms-azuretools.vscode-azurecontainerapps"; },
      @{extensionName = "ms-azuretools.vscode-cosmosdb"; },
      @{extensionName = "ms-azuretools.azure-dev"; },
      @{extensionName = "ms-azuretools.vscode-azurefunctions"; },
      @{extensionName = "ms-azure-devops.azure-pipelines"; },
      @{extensionName = "terWoordComputers.azure-pipelines-overview"; },
      @{extensionName = "TomAustin.azure-devops-yaml-pipeline-validator"; },
      @{extensionName = "AzurePolicy.azurepolicyextension"; },
      @{extensionName = "msazurermtools.azurerm-vscode-tools"; },
      @{extensionName = "ms-azuretools.vscode-azureresourcegroups"; },
      @{extensionName = "ms-azuretools.vscode-azurestaticwebapps"; },
      @{extensionName = "ms-azuretools.vscode-azurestorage"; },
      @{extensionName = "ms-vscode.vscode-node-azure-pack"; },
      @{extensionName = "ms-azuretools.vscode-azurevirtualmachines"; },
      @{extensionName = "ms-azuretools.vscode-bicep"; },
      @{extensionName = "mindaro.mindaro"; },
      @{extensionName = "ms-dotnettools.csharp"; },
      @{extensionName = "ms-vscode-remote.remote-containers"; },
      @{extensionName = "ms-azuretools.vscode-docker"; },
      @{extensionName = "mindaro-dev.file-downloader"; },
      @{extensionName = "Shinotatwu-DS.file-tree-generator"; },
      @{extensionName = "ms-vscode-remote.remote-ssh"; },
      @{extensionName = "ms-vscode-remote.remote-ssh-edit"; },
      @{extensionName = "github.vscode-github-actions"; },
      @{extensionName = "GitHub.copilot"; },
      @{extensionName = "eamodio.gitlens"; },
      @{extensionName = "golang.go"; },
      @{extensionName = "hashicorp.terraform"; },
      @{extensionName = "af4jm.vscode-icalendar"; },
      @{extensionName = "VisualStudioExptTeam.vscodeintellicode"; },
      @{extensionName = "VisualStudioExptTeam.intellicode-api-usage-examples"; },
      @{extensionName = "ms-python.isort"; },
      @{extensionName = "ZainChen.json"; },
      @{extensionName = "ms-toolsai.jupyter"; },
      @{extensionName = "ms-toolsai.vscode-jupyter-cell-tags"; },
      @{extensionName = "ms-toolsai.jupyter-keymap"; },
      @{extensionName = "ms-toolsai.jupyter-renderers"; },
      @{extensionName = "ms-toolsai.jupyter-renderers-vscode"; },
      @{extensionName = "ms-toolsai.vscode-jupyter-slideshow"; },
      @{extensionName = "ms-kubernetes-tools.vscode-kubernetes-tools"; },
      @{extensionName = "DavidAnson.vscode-markdownlint"; },
      @{extensionName = "esbenp.prettier-vscode"; },
      @{extensionName = "ms-python.vscode-pylance"; },
      @{extensionName = "ms-python.vscode-pylance-pack"; },
      @{extensionName = "ms-python.python"; },
      @{extensionName = "donjayamanne.python-environment-manager"; },
      @{extensionName = "donjayamanne.python-extension-pack"; },
      @{extensionName = "KevinRose.vsc-python-indent"; },
      @{extensionName = "ms-vscode-remote.remote-wsl"; },
      @{extensionName = "ms-vscode-remote.remote-wsl-explorer"; },
      @{extensionName = "redhat.vscode-yaml"; }
    )

    foreach ($extension in $vsCodeExtensionList)
    {
      # Check if the extension is already installed and install if it's not there.
      $extensionName = $extension.extensionName
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