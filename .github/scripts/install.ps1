param(
    [string]$PythonPath = 'C:\Python311-x64',
    [string]$PythonVersion = '3.11',
    [int]$PythonArch = 64,
    [string]$UIASupport = 'NO'
)

$MinicondaUrl = 'http://repo.continuum.io/miniconda/'

function DownloadMiniconda($pythonVersion, $platformSuffix) {
    $webClient = New-Object System.Net.WebClient
    $url = 'https://repo.anaconda.com/miniconda/Miniconda3-py311_24.4.0-0-Windows-x86_64.exe'
    $filename = if ($pythonVersion -match '3.11') { "Miniconda3-py311_24.4.0.0-Windows-$platformSuffix.exe" } else { "Miniconda-py311_24.4.0.0-$platformSuffix.exe" }
    $url = "$MinicondaUrl$filename"

    $basePath = Join-Path $pwd.Path ''
    $filePath = Join-Path $basePath $filename

    if (Test-Path $filePath) {
        Write-Host "Reusing $filePath"
        return $filePath
    }

    # Download and retry up to 3 times in case of network transient errors.
    Write-Host "Downloading $filename from $url"
    $retryAttempts = 2
    for ($i = 0; $i -lt $retryAttempts; $i++) {
        try {
            $webClient.DownloadFile($url, $filePath)
            break
        }
        Catch [Exception] {
            Start-Sleep 1
        }
    }
    if (Test-Path $filePath) {
        Write-Host "File saved at $filePath"
    }
    else {
        # Retry once to get the error message if any at the last try
        $webClient.DownloadFile($url, $filePath)
    }
    return $filePath
}

function InstallMiniconda($pythonVersion, $architecture, $pythonHome) {
    Write-Host "Installing Python $pythonVersion for $architecture-bit architecture to $pythonHome"
    if (Test-Path $pythonHome) {
        Write-Host "$pythonHome already exists, skipping."
        return $false
    }
    $platformSuffix = if ($architecture -eq 32) { 'x86' } else { 'x86_64' }
    $filePath = DownloadMiniconda $pythonVersion $platformSuffix
    Write-Host "Installing $filePath to $pythonHome"
    $installLog = Join-Path $pythonHome '.log'
    $arguments = "/S /D=$pythonHome"
    Write-Host "$filePath $arguments"
    Start-Process -FilePath $filePath -ArgumentList $arguments -Wait -PassThru
    if (Test-Path $pythonHome) {
        Write-Host "Python $pythonVersion ($architecture-bit) installation complete"
    }
    else {
        Write-Host "Failed to install Python in $pythonHome"
        Get-Content -Path $installLog
        Exit 1
    }
}

function InstallCondaPackages($pythonHome, $spec) {
    $condaPath = Join-Path $pythonHome 'Scripts\conda.exe'
    $arguments = "install --yes $spec"
    Write-Host ('conda ' + $arguments)
    Start-Process -FilePath "$condaPath" -ArgumentList $arguments -Wait -PassThru
}

function UpdateConda($pythonHome) {
    $condaPath = Join-Path $pythonHome 'Scripts\conda.exe'
    Write-Host 'Updating conda...'
    $arguments = 'update --yes conda'
    Write-Host "$condaPath $arguments"
    Start-Process -FilePath "$condaPath" -ArgumentList $arguments -Wait -PassThru
}

function InstallComtypes($pythonHome) {
    $pipPath = Join-Path $pythonHome 'Scripts\pip.exe'
    $arguments = 'install comtypes'
    Start-Process -FilePath "$pipPath" -ArgumentList $arguments -Wait -PassThru
}

function UpdateEnvironmentVairbale() {
    [CmdletBinding(PositionalBinding = $false)]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Name,

        [Parameter(Mandatory = $true, Position = 1)]
        [AllowEmptyString()]
        [string]
        $Value,

        [Parameter(Mandatory = $true, Position = 2)]
        [System.EnvironmentVariableTarget]
        $Target
    )

    $Old = [System.Environment]::GetEnvironmentVariable($Name, $Target)
    if ("$Old" -Ne "$Value") {
        Write-Host "Update: $Name ($Target)"
        Write-Host "    Old: $Old"
        Write-Host "    New: $Value"
        [System.Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }
}

function main() {
    try {
        $currentResolution = Get-DisplayResolution
        Write-Host "Current resolution: $currentResolution"
    }
    Catch [Exception] {
        Write-Host "Can't print current resolution. Get-DisplayResolution cmd is not available"
    }

    Write-Host "PYTHON=$PythonPath"
    Write-Host "PYTHON_VERSION=$PythonVersion"
    Write-Host "PYTHON_ARCH=$PythonArch"

    try {
        # https://github.com/kzm4269/rye-installation-scripts/blob/main/windows10/install_rye.ps1
        # For scoop bucket with rye: https://github.com/Vechro/ryence
        $InstallerExe = 'rye-x86_64-windows.exe'
        $InstallerUrl = "https://github.com/astral-sh/rye/releases/latest/download/$filePath"

        Write-Host 'Downloading Rye installer'
        Invoke-WebRequest -UseBasicParsing -o "$InstallerExe" "$InstallerUrl"
        Write-Host 'Executing: rye self install'
        & $InstallerExe self install --yes
        Write-Host 'Executing: rye self update'
        & $InstallerExe self update

        if (Test-Path $pythonHome) {
            Write-Host "Python $pythonVersion ($architecture-bit) installation complete"
        }
    }
    catch {
        Write-Host 'Failed to install Rye and Python.'
        <#Do this if a terminating exception happens#>
        # cargo install --git https://github.com/astral-sh/rye rye
    }
    finally {
        <#Do this after the try block regardless of whether an exception occurred or not#>
    }

    if ($UIASupport -eq 'YES') {
        # InstallComtypes $PythonPath
    }

    # InstallMiniconda $PythonVersion $PythonArch $PythonPath
    # UpdateConda $PythonPath
    # InstallCondaPackages $PythonPath "pywin32 Pillow coverage nose"
}

main
