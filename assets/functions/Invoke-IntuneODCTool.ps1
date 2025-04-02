function Invoke-IntuneODCTool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AssetsPath,
        [Parameter(Mandatory = $false)]
        [string]$LogFilePath = "$env:temp\IntuneODC.log"
    )
    Begin {
        # Validate the AssetsPath
        if (-not (Test-Path -Path $AssetsPath -ErrorAction SilentlyContinue)) {
            Write-Error "The provided AssetsPath '$AssetsPath' does not exist."
            return
        }

        # Define the path to the Intune ODC tool executable
        $odcToolPath = Join-Path -Path $AssetsPath -ChildPath "bin\IntuneODC.ps1"

        # Check if the Intune ODC tool exists
        if (-not (Test-Path -Path $odcToolPath -ErrorAction SilentlyContinue)) {
            Write-Error "The Intune ODC tool was not found at '$odcToolPath'."
            return
        }

        #- Set PowerShell path for the Intune ODC tool. If sysnative is available use it otherwise use the default PowerShell Path
        $sysnativePath = "$env:windir\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
        if (Test-Path -Path $sysnativePath) {
            $powershellPath = $sysnativePath
        }
        else {
            $powershellPath = "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe"
        }
    }
    Process {
        # Execute the Intune ODC tool
        Write-Verbose "Executing Intune ODC Tool at '$odcToolPath'..."
        try {
            # Start the Intune ODC tool with PowerShell 5
            Start-Process -FilePath $powershellPath -ArgumentList "-NoProfile -NoLogo -ExecutionPolicy Bypass -File ""$odcToolPath""" -NoNewWindow -Wait -ErrorAction Stop -RedirectStandardOutput $LogFilePath -RedirectStandardError $LogFilePath
            Write-Verbose "Output and errors are being logged to '$LogFilePath'."
        }
        catch {
            Write-Error "Failed to execute the Intune ODC tool. Error: $_"
            throw
        }
        Write-Verbose "Intune ODC tool execution completed successfully."
    }
    End {
        Write-Output "Intune ODC tool run completed."
        Write-Output "You can find the output in the specified directory."
    }
}