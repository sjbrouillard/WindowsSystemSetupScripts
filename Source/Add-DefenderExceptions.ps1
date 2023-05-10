[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $RootSourceCodeFolder
)

Process
{
    Write-Host "This script will create Windows Defender exclusions for common Visual Studio 2022 folders and processes."
    Write-Host ""
    Test-RootSourceCodeFolder
    Register-PathExclusions
    Register-ProcessExclusions
}

Begin
{

     # Validating here due to limitations of validation attributes.
     function Test-RootSourceCodeFolder
     {
         if ([string]::IsNullOrWhiteSpace($RootSourceCodeFolder))
         {
             Throw "RootSourceCodeFolder parameter can't be null or empty."
         }
 
         if (!(Test-Path $RootSourceCodeFolder -PathType Container))
         {
             Throw "$($RootSourceCodeFolder) not found. Please validate path."
         }
     }

     function Register-PathExclusions 
     {
        $pathExclusionList =  @(
            @{Path = $RootSourceCodeFolder },
            @{Path = "C:\Windows\Microsoft.NET" },
            @{Path = "C:\Windows\assembly" },
            @{Path = "$($env:USERPROFILE)\.dotnet" },
            @{Path = "$($env:USERPROFILE)\.librarymanager" },
            @{Path = "$($env:LOCALAPPDATA))\Microsoft\VisualStudio" },
            @{Path = "$($env:LOCALAPPDATA))\Microsoft\VSApplicationInsights" },
            @{Path = "$($env:LOCALAPPDATA))\Microsoft\VSCommon" },
            @{Path = "$($env:LOCALAPPDATA))\Microsoft\VisualStudio Services" },
            @{Path = "$($env:APPDATA))\Microsoft\VisualStudio" },
            @{Path = "$($env:ProgramData))\Microsoft\VisualStudio" },
            @{Path = "$($env:ProgramData))\Microsoft\NetFramework" },
            @{Path = "$($env:ProgramData))\Microsoft\Visual Studio" },
            @{Path = "$($env:ProgramData))\VSApplicationInsights" },
            @{Path = "$($env:ProgramFiles))\dotnet" },
            @{Path = "$($env:ProgramFiles))\IIS" },
            @{Path = "$($env:ProgramFiles))\IIS Express" },
            @{Path = "$($env:ProgramFiles))\Microsoft SDKs" },
            @{Path = "$($env:ProgramFiles))\Microsoft SQL Server" },
            @{Path = "$($env:ProgramFiles))\Microsoft Visual Studio" },
            @{Path = "$($env:ProgramFiles))\Microsoft Visual Studio 10.0" },
            @{Path = "$($env:ProgramFiles))\Microsoft VS Code" },
            @{Path = "$(${Env:ProgramFiles(x86)})\dotnet"},
            @{Path = "$(${Env:ProgramFiles(x86)})\IIS"},
            @{Path = "$(${Env:ProgramFiles(x86)})\IIS Express"},
            @{Path = "$(${Env:ProgramFiles(x86)})\Microsoft SDKs"},
            @{Path = "$(${Env:ProgramFiles(x86)})\Microsoft SQL Server"},
            @{Path = "$(${Env:ProgramFiles(x86)})\Microsoft Visual Studio"}
        )

        foreach ($exclusion in $pathExclusionList) 
        {
            $exclusionPath = $exclusion.Path
            Write-Host "Adding Path Exclusion: " $exclusionPath
            Add-MpPreference -ExclusionPath $exclusionPath
        }
     }

     function Register-ProcessExclusions
     {
        $processExclusionList = @(
            @{Process = 'ServiceHub.SettingsHost.exe'},
            @{Process = 'ServiceHub.IdentityHost.exe'},
            @{Process = 'ServiceHub.VSDetouredHost.exe'},
            @{Process = 'ServiceHub.Host.CLR.x86.exe'},
            @{Process = 'Microsoft.ServiceHub.Controller.exe'},
            @{Process = 'PerfWatson2.exe'},
            @{Process = 'sqlwriter.exe'}
        )

        foreach ($exclusion in $processExclusionList)
        {
            $exclusionProcess = $exclusion.Process
            Write-Host "Adding Process Exclusion: " $exclusionProcess
            Add-MpPreference -ExclusionProcess $exclusionProcess
        }
     }
}

End 
{
    Write-Host ""
    Write-Host "Your Exclusions:"

    $prefs = Get-MpPreference
    $prefs.ExclusionPath
    $prefs.ExclusionProcess

    Write-Host ""
    Write-Host "Enjoy faster build times and coding!"
    Write-Host ""
}