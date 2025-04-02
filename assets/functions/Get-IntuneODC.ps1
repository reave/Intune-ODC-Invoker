function Get-IntuneODC {
    <#
        .SYNOPSIS
            Downloads the IntuneODC script and XML configuration file.
        .DESCRIPTION
            This function downloads the IntuneODC script and XML configuration file from specified URLs.
        .PARAMETER AssetsPath
            The path where the downloaded files will be saved.
        .EXAMPLE
            Get-IntuneODC -AssetsPath "C:\IntuneODC"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AssetsPath
    )
    Begin {
        $downloadUrls = @(
            [PSCustomObject]@{
                Url     = "https://aka.ms/intuneps1"
                Name    = "IntuneODC"
                OutPath = "$($AssetsPath)\bin\IntuneODC.ps1"
            },
            [PSCustomObject]@{
                Url     = "https://aka.ms/intunexml"
                Name    = "IntuneODC XML"
                OutPath = "$($AssetsPath)\bin\IntuneODC.xml"
            }
        )

        #- Validate AssetsPath exists and is a directory
        if (-not (Test-Path -Path $AssetsPath -ErrorAction SilentlyContinue)) {
            Write-Error "The specified path '$AssetsPath' does not exist."

            #- Create the directory if it doesn't exist
            try {
                New-Item -Path $AssetsPath -ItemType Directory -ErrorAction Stop
                Write-Verbose "Created directory: $AssetsPath"
            }
            catch {
                Write-Error "Failed to create directory '$AssetsPath'. Error: $_"
                return
            }
        }
    }
    Process {
        #- Loop through the URLs and download each file to the specified path
        foreach ($url in $downloadUrls) {
            try {
                Write-Verbose "Downloading $($url.Name) from $($url.Url) to $($url.OutPath)"
                Invoke-WebRequest -Uri $url.Url -OutFile $url.OutPath -ErrorAction Stop
                Write-Verbose "Downloaded $($url.Name) successfully."
            }
            catch {
                Write-Error "Failed to download $($url.Name). Error: $_"
            }
        }

        #- Validate the downloaded files
        foreach ($url in $downloadUrls) {
            if (-not (Test-Path -Path $url.OutPath -ErrorAction SilentlyContinue)) {
                Write-Error "The file '$($url.OutPath)' was not downloaded successfully."
                return
            }
            else {
                Write-Verbose "The file '$($url.OutPath)' was downloaded successfully."
            }
        }
    }
    End {
        Write-Verbose "All files downloaded and validated successfully."
    }
}