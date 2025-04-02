Param(
    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = "$PSScriptRoot\IntuneODC"
)

#- Set InvocationInfo equal to either HostInvocation or $MyInvocation
if (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } else { $InvocationInfo = $MyInvocation }

#- Set the path to the script\assets\functions
$scriptPath = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

#- Get all functions from the path of the script\assets\functions and import them with a try catch
$functions = Get-ChildItem -Path "$scriptPath\assets\functions" -Filter "*.ps1"

ForEach ($function in $functions) {
    Write-Verbose "Importing function from $($function.FullName)..."
    try {
        . $function.FullName
    }
    catch {
        Write-Error "Failed to import function from $($function.FullName). Error: $_"
    }
}

#- Download the IntuneODC script and XML configuration file
Write-Output "Downloading IntuneODC script and XML configuration file..."
Get-IntuneODC -AssetsPath "$scriptPath\assets"

#- Run the IntuneODC tool
Write-Output "Running IntuneODC tool... Please wait..."
Invoke-IntuneODCTool -AssetsPath "$scriptPath\assets" -LogFilePath "$scriptPath\IntuneODC.log"

Write-Output "Moving IntuneODC Output files to the the output directory..."
$odcZipFile = Get-ChildItem -Path $scriptPath -Filter "$($env:COMPUTERNAME)_CollectedData*"
try {
    if ($odcZipFile) {
        foreach ($file in $odcZipFile) {
            $destinationPath = Join-Path -Path $OutputDirectory -ChildPath $file.Name
            Move-Item -Path $file.FullName -Destination $destinationPath -ErrorAction Stop
            Write-Output "File moved successfully to $destinationPath"
        }
    }
    else {
        Write-Warning "No files matching the pattern were found to move."
    }
}
catch {
    Write-Error "Failed to move the files. Error: $_"
}
