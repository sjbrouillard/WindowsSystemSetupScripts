[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $ProjectFolder
)

Process
{
    Write-Host "This script will create Windows Defender exclusions for common Visual Studio 2022 folders and processes."
    Write-Host ""
    Test-ProjectFolder
    Register-PathExclusions
    Register-ProcessExclusions
}

Begin
{

     # Validating here due to limitations of validation attributes.
     function Test-ProjectFolder
     {
         if ([string]::IsNullOrWhiteSpace($ProjectFolder))
         {
             Throw "ProjectFolder parameter can't be null or empty."
         }
 
         if (!(Test-Path $ProjectFolder -PathType Container))
         {
             Throw "$($ProjectFolder) not found. Please validate path."
         }
     }

     function Register-PathExclusions 
     {

        $userPath = $env:USERPROFILE
        $pathExclusions = New-Object System.Collections.ArrayList

        $pathExclusions.Add($ProjectFolder) | out-null
        $pathExclusions.Add('C:\Windows\Microsoft.NET') | out-null
        $pathExclusions.Add('C:\Windows\assembly') | out-null

        $pathExclusions.Add($userPath + '\.dotnet') | out-null
        $pathExclusions.Add($userPath + '\.librarymanager') | out-null

        $pathExclusions.Add($userPath + '\AppData\Local\Microsoft\VisualStudio') | out-null
        $pathExclusions.Add($userPath + '\AppData\Local\Microsoft\VisualStudio Services') | out-null
        $pathExclusions.Add($userPath + '\AppData\Local\Microsoft\VSApplicationInsights') | out-null
        $pathExclusions.Add($userPath + '\AppData\Local\Microsoft\VSCommon') | out-null

        $pathExclusions.Add($userPath + '\AppData\Roaming\Microsoft\VisualStudio') | out-null

        $pathExclusions.Add('C:\ProgramData\Microsoft\VisualStudio') | out-null
        $pathExclusions.Add('C:\ProgramData\Microsoft\NetFramework') | out-null
        $pathExclusions.Add('C:\ProgramData\Microsoft Visual Studio') | out-null
        $pathExclusions.Add('C:\ProgramData\VSApplicationInsights') | out-null

        $pathExclusions.Add('C:\Program Files\Microsoft Visual Studio') | out-null
        $pathExclusions.Add('C:\Program Files\Microsoft Visual Studio 10.0') | out-null
        $pathExclusions.Add('C:\Program Files\Microsoft VS Code') | out-null
        $pathExclusions.Add('C:\Program Files\dotnet') | out-null
        $pathExclusions.Add('C:\Program Files\Microsoft SDKs') | out-null
        $pathExclusions.Add('C:\Program Files\Microsoft SQL Server') | out-null
        $pathExclusions.Add('C:\Program Files\IIS') | out-null
        $pathExclusions.Add('C:\Program Files\IIS Express') | out-null

        $pathExclusions.Add('C:\Program Files (x86)\Microsoft Visual Studio') | out-null
        $pathExclusions.Add('C:\Program Files (x86)\dotnet') | out-null
        $pathExclusions.Add('C:\Program Files (x86)\Microsoft SDKs') | out-null
        $pathExclusions.Add('C:\Program Files (x86)\Microsoft SQL Server') | out-null
        $pathExclusions.Add('C:\Program Files (x86)\IIS') | out-null
        $pathExclusions.Add('C:\Program Files (x86)\IIS Express') | out-null

        foreach ($exclusion in $pathExclusions) 
        {
            Write-Host "Adding Path Exclusion: " $exclusion
            Add-MpPreference -ExclusionPath $exclusion
        }
     }

     function Register-ProcessExclusions
     {
        $processExclusions = New-Object System.Collections.ArrayList

        $processExclusions.Add('ServiceHub.SettingsHost.exe') | out-null
        $processExclusions.Add('ServiceHub.IdentityHost.exe') | out-null
        $processExclusions.Add('ServiceHub.VSDetouredHost.exe') | out-null
        $processExclusions.Add('ServiceHub.Host.CLR.x86.exe') | out-null
        $processExclusions.Add('Microsoft.ServiceHub.Controller.exe') | out-null
        $processExclusions.Add('PerfWatson2.exe') | out-null
        $processExclusions.Add('sqlwriter.exe') | out-null

        foreach ($exclusion in $processExclusions)
        {
            Write-Host "Adding Process Exclusion: " $exclusion
            Add-MpPreference -ExclusionProcess $exclusion
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