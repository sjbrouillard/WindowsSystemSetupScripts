# Starter script to contain some prerequisite checks and settings.
# Not sure what will land here.

# This adds the path where I keep my scripts to the user path.
$currentUserPathVariableToTest = [Environment]::GetEnvironmentVariable("Path","User")
$PoshScriptLocation = "$($env:OneDriveConsumer)\Dev Settings\POSHScripts"

if (!($currentUserPathVariableToTest.Contains($PoshScriptLocation)))
{
    Write-Host "Adding $($PoshScriptLocation) to user path."
    [Environment]::SetEnvironmentVariable("Path", $currentUserPathVariableToTest + ";" + $PoshScriptLocation, "User")
}


# The following section refreshes the environment variables. Keep it at the end of the script so whatever changes you make to the environment variables are reflected in the current session.

# Update standard environment variables
foreach($level in "Machine","User")
{
  [Environment]::GetEnvironmentVariables($level)
}

# Update path environment variable - needs to be handled separately
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")