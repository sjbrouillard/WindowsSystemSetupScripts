# Starter script to contain some prerequisite checks and settings.
# Not sure what will land here.

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $ExcludeAddingPoshScriptLocation,

    [Parameter()]
    [switch]
    $ExcludeSetFolderOptions,

    [Parameter()]
    [switch]
    $ExcludeLongPathSupport
)

Process
{
  if (!$ExcludeAddingPoshScriptLocation) { Add-PoshScriptLocationToUserPath }
  if (!$ExcludeLongPathSupport) { Set-LongPathEnabled }
  if (!$ExcludeSetFolderOptions) { Set-FolderOptions }
  Update-EnvironmentVariables
}

Begin
{

  # This adds the path where I keep my daily-use scripts to the user path.
  function Add-PoshScriptLocationToUserPath
  {
    $currentUserPathVariableToTest = [Environment]::GetEnvironmentVariable("Path","User")
    $PoshScriptLocation = "$($env:OneDriveConsumer)\Dev Settings\POSHScripts"
    
    if (!($currentUserPathVariableToTest.Contains($PoshScriptLocation)))
    {
        Write-Host "Adding $($PoshScriptLocation) to user path."
        [Environment]::SetEnvironmentVariable("Path", $currentUserPathVariableToTest + ";" + $PoshScriptLocation, "User")
    }
  }

  function Update-EnvironmentVariables
  {
    # Update standard environment variables
    foreach($level in "Machine","User")
    {
      [Environment]::GetEnvironmentVariables($level)
    }

    # Update path environment variable - needs to be handled separately
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
  }

  function Set-LongPathEnabled
  {
    $longPathEnabledRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    $longPathEnabledRegistryName = "LongPathsEnabled"
    $longPathEnabledRegistryValue = 1

    Write-Host "Enabling long paths."
    Set-ItemProperty -Path $longPathEnabledRegistryPath -Name $longPathEnabledRegistryName -Value $longPathEnabledRegistryValue
  }

  function Set-FolderOptions
  {
    $folderOptionsRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $keys = @(
      @{name = "AlwaysShowMenus"; value = 1; },
      @{name = "Hidden"; value = 1;  },
      @{name = "HideDrivesWithNoMedia"; value = 0;  },
      @{name = "HideFileExt"; value = 0;  },
      @{name = "HideIcons"; value = 0;  },
      @{name = "HideMergeConflicts"; value = 0;  },
      @{name = "MapNetDrvBtn"; value = 1;  },
      @{name = "NavPaneShowAllFolders"; value = 1;  },
      @{name = "SharingWizardOn"; value = 0;  },
      @{name = "ShowCompColor"; value = 1;  },
      @{name = "ShowEncryptCompressedColor"; value = 1;  },
      @{name = "ShowExtensions"; value = 1;  },
      @{name = "ShowInfoTip"; value = 1;  },
      @{name = "ShowStatusBar"; value = 1;  },
      @{name = "ShowSuperHidden"; value = 1; }
    )

    foreach ($key in $keys)
    {
      $keyName = $key.name
      $keyValue = $key.value
      
      #Going with the simplest route. Set-ItemProperty will create the key if it doesn't exist.
      Write-Host "Updating $($keyName) to $($keyValue)."
      Set-ItemProperty -Path $folderOptionsRegistryPath -Name $keyName -Value $keyValue
    }
  }
}

End
{

}