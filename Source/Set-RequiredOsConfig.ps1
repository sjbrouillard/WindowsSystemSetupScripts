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
    $ExcludeLongPathSupport,

    [Parameter()]
    [switch]
    $ExcludeVerboseBootStatus,

    [Parameter()]
    [switch]
    $ExcludeUpdateEnvironmentVariables
)

Process
{
  if (!$ExcludeAddingPoshScriptLocation) { Add-PoshScriptLocationToUserPath }
  if (!$ExcludeLongPathSupport) { Set-LongPathEnabled }
  if (!$ExcludeSetFolderOptions) { Set-FolderOptions }
  if (!$ExcludeVerboseBootStatus) { Set-VerboseBootStatus }
  if (!$ExcludeUpdateEnvironmentVariables) { Update-EnvironmentVariables }
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
    $folderViewOptionsRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $viewKeys = @(
      @{name = "AlwaysShowMenus"; value = 1; },
      @{name = "Hidden"; value = 1;  },
      @{name = "HideDrivesWithNoMedia"; value = 0;  },
      @{name = "HideFileExt"; value = 0;  },
      @{name = "HideIcons"; value = 0;  },
      @{name = "HideMergeConflicts"; value = 0;  },
      @{name = "MapNetDrvBtn"; value = 1;  },
      @{name = "NavPaneShowAllFolders"; value = 0;  },
      @{name = "SharingWizardOn"; value = 0;  },
      @{name = "ShowCompColor"; value = 1;  },
      @{name = "ShowEncryptCompressedColor"; value = 1;  },
      @{name = "ShowExtensions"; value = 1;  },
      @{name = "ShowInfoTip"; value = 1;  },
      @{name = "ShowStatusBar"; value = 1;  },
      @{name = "ShowSuperHidden"; value = 1; }
    )

    #Set the view options contained in the ...\Explorer\Advanced registry key
    foreach ($key in $viewKeys)
    {
      $keyName = $key.name
      $keyValue = $key.value
      
      #Going with the simplest route. Set-ItemProperty will create the key if it doesn't exist.
      Write-Host "Updating $($folderViewOptionsRegistryPath)\$($keyName) to $($keyValue)."
      Set-ItemProperty -Path $folderViewOptionsRegistryPath -Name $keyName -Value $keyValue
    }

    #Set the general options contained in the ...\Explorer registry key
    $folderGeneralOptionsRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
    $generalKeys = @(
      @{name = "ShowCloudFilesInQuickAccess"; value = 0; },
      @{name = "ShowRecent"; value = 0; },
      @{name = "ShowFrequent"; value = 0; }
    )

    foreach ($key in $generalKeys)
    {
      $keyName = $key.name
      $keyValue = $key.value
      
      #Going with the simplest route. Set-ItemProperty will create the key if it doesn't exist.
      Write-Host "Updating $($folderGeneralOptionsRegistryPath)\$($keyName) to $($keyValue)."
      Set-ItemProperty -Path $folderGeneralOptionsRegistryPath -Name $keyName -Value $keyValue
    }
  }

  function Set-VerboseBootStatus
  {
    $bootStatusRegistryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    $bootStatusRegistryName = "VerboseStatus"
    $bootStatusRegistryValue = 1
    Write-Host "Enabling verbose boot status."
    Set-ItemProperty -Path $bootStatusRegistryPath -Name $bootStatusRegistryName -Value $bootStatusRegistryValue
  }
}

End
{

}
