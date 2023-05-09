# Starter script to contain some prerequisite checks and settings.
# Not sure what will land here.

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $ExcludeAddingPoshScriptLocation,

    [Parameter()]
    [switch]
    $ExcludeSetFolderOptions
)

Process
{
  if (!$ExcludeAddingPoshScriptLocation) { Add-PoshScriptLocationToUserPath }
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

  function Set-FolderOptions
  {
    $folderOptionsRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $keys = @(
      @{name = "AlwaysShowMenus"; value = 1; type = "DWORD"; },
      @{name = "Hidden"; value = 1; type = "DWORD";  },
      @{name = "HideDrivesWithNoMedia"; value = 0; type = "DWORD";  },
      @{name = "HideFileExt"; value = 0; type = "DWORD";  },
      @{name = "HideIcons"; value = 0; type = "DWORD";  },
      @{name = "HideMergeConflicts"; value = 0; type = "DWORD";  },
      @{name = "MapNetDrvBtn"; value = 1; type = "DWORD";  },
      @{name = "NavPaneShowAllFolders"; value = 1; type = "DWORD";  },
      @{name = "SharingWizardOn"; value = 0; type = "DWORD";  },
      @{name = "ShowCompColor"; value = 1; type = "DWORD";  },
      @{name = "ShowEncryptCompressedColor"; value = 1; type = "DWORD";  },
      @{name = "ShowExtensions"; value = 1; type = "DWORD";  },
      @{name = "ShowInfoTip"; value = 1; type = "DWORD";  },
      @{name = "ShowStatusBar"; value = 1; type = "DWORD";  },
      @{name = "ShowSuperHidden"; value = 1; type = "DWORD"; }
    )

    foreach ($key in $keys)
    {
      $keyName = $key.name
      $keyValue = $key.value
      
      #Going with the simplest route. Set-ItemProperty will create the key if it doesn't exist.
      Write-Host "Updating $($keyName) to $($keyValue)."
      Set-ItemProperty -Path $folderOptionsRegistryPath -Name $keyName -Value $keyValue -PropertyType DWORD
    }
  }
}

End
{

}