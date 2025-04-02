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
            #Start-Process -FilePath $powershellPath -ArgumentList "-NoProfile -NoLogo -ExecutionPolicy Bypass -File ""$odcToolPath""" -NoNewWindow -Wait -ErrorAction Stop 2>&1> $LogFilePath
            $parameters = @{
                FilePath  = $odcToolPath
                PSVersion = 5.1 # <-- remove this line for PS7
            }

            # Set the timeout for the job in seconds (15 minutes)
            $timeoutSec = 900
            $job = Start-Job @parameters
            $job.ChildJobs[0].Output
            $index = $job.ChildJobs[0].Output.Count

            while ($job.JobStateInfo.State -eq [System.Management.Automation.JobState]::Running) {
                Start-Sleep -Milliseconds 200
                $job.ChildJobs[0].Output[$index]
                $index = $job.ChildJobs[0].Output.Count
                if (([DateTime]::Now - $job.PSBeginTime).TotalSeconds -gt $timeoutSec) {
                    throw "Job timed out."
                }
            }
            Write-Verbose "Output and errors are being logged to '$LogFilePath'."

            #- Wait for the job to complete and capture the output into the log file
            try {
                Write-Verbose "Writing output to log file '$LogFilePath'..."
                $job.ChildJobs[0].Output | Out-File -FilePath $LogFilePath -Append -ErrorAction Stop
            }
            catch {
                Write-Error "Failed to write output to log file '$LogFilePath'. Error: $_"
                throw
            }
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