<#
.SYNOPSIS
    JBH Database Installer for Autodesk
    
.DESCRIPTION
    This script copies the appropriate database from the network Z: drive to the user's local C: drive.
    It allows the user to select the proper configuration for their needs.
    
.NOTES
    Author: JBH Team
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "Z:\JBH-Database",
    
    [Parameter(Mandatory=$false)]
    [string]$DestinationPath = "C:\ProgramData\JBH\Database",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Standard", "Advanced", "Custom")]
    [string]$Configuration = "Standard"
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Create log directory if it doesn't exist
$LogPath = "$env:TEMP\JBH-Installer-Logs"
if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

# Set up logging
$LogFile = Join-Path $LogPath "Install-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to console with color
    switch ($Level) {
        "ERROR"   { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default   { Write-Host $logMessage }
    }
    
    # Write to log file
    Add-Content -Path $LogFile -Value $logMessage
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-ConfigurationMenu {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  JBH Database Installer for Autodesk  " -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "Please select the database configuration:" -ForegroundColor White
    Write-Host "  1. Standard Configuration (Recommended for most users)" -ForegroundColor Gray
    Write-Host "  2. Advanced Configuration (For power users)" -ForegroundColor Gray
    Write-Host "  3. Custom Configuration (Specify custom paths)" -ForegroundColor Gray
    Write-Host "  Q. Quit" -ForegroundColor Gray
    Write-Host ""
    
    $selection = Read-Host "Enter your choice (1-3 or Q)"
    
    switch ($selection.ToUpper()) {
        "1" { return "Standard" }
        "2" { return "Advanced" }
        "3" { return "Custom" }
        "Q" { 
            Write-Log "User cancelled installation" -Level "INFO"
            exit 0 
        }
        default { 
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
            return Show-ConfigurationMenu
        }
    }
}

function Get-ConfigurationPaths {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ConfigType
    )
    
    switch ($ConfigType) {
        "Standard" {
            return @{
                SourceSubPath = "Standard"
                Description = "Standard database with default settings"
            }
        }
        "Advanced" {
            return @{
                SourceSubPath = "Advanced"
                Description = "Advanced database with extended features"
            }
        }
        "Custom" {
            Write-Host "`nEnter custom source path (leave empty for default):" -ForegroundColor Yellow
            $customSource = Read-Host "Source"
            if ([string]::IsNullOrWhiteSpace($customSource)) {
                $customSource = $SourcePath
            }
            
            Write-Host "Enter custom destination path (leave empty for default):" -ForegroundColor Yellow
            $customDest = Read-Host "Destination"
            if ([string]::IsNullOrWhiteSpace($customDest)) {
                $customDest = $DestinationPath
            }
            
            return @{
                SourceSubPath = "Custom"
                CustomSource = $customSource
                CustomDestination = $customDest
                Description = "Custom database configuration"
            }
        }
    }
}

function Copy-DatabaseFiles {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        
        [Parameter(Mandatory=$true)]
        [string]$Destination,
        
        [Parameter(Mandatory=$false)]
        [string]$Description = "database files"
    )
    
    try {
        Write-Log "Starting database copy operation..." -Level "INFO"
        Write-Log "Source: $Source" -Level "INFO"
        Write-Log "Destination: $Destination" -Level "INFO"
        Write-Log "Description: $Description" -Level "INFO"
        
        # Validate source exists
        if (-not (Test-Path $Source)) {
            throw "Source path does not exist: $Source. Please ensure Z: drive is connected."
        }
        
        # Get source size for progress reporting
        $sourceItems = Get-ChildItem -Path $Source -Recurse -Force -ErrorAction SilentlyContinue
        $totalSize = ($sourceItems | Measure-Object -Property Length -Sum).Sum
        $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
        
        Write-Log "Total size to copy: $totalSizeMB MB" -Level "INFO"
        
        # Create destination directory if it doesn't exist
        if (-not (Test-Path $Destination)) {
            Write-Log "Creating destination directory: $Destination" -Level "INFO"
            New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        }
        
        # Backup existing database if it exists
        if (Test-Path $Destination) {
            $existingFiles = Get-ChildItem -Path $Destination -ErrorAction SilentlyContinue
            if ($existingFiles) {
                $backupPath = "$Destination-Backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Write-Log "Backing up existing database to: $backupPath" -Level "WARNING"
                Copy-Item -Path $Destination -Destination $backupPath -Recurse -Force
                Write-Log "Backup completed successfully" -Level "SUCCESS"
            }
        }
        
        # Copy files with progress
        Write-Log "Copying database files..." -Level "INFO"
        Write-Host "`nCopying files, please wait..." -ForegroundColor Yellow
        
        $copiedSize = 0
        $fileCount = 0
        
        foreach ($item in $sourceItems) {
            if ($item.PSIsContainer) {
                # Create directory
                $relativePath = $item.FullName.Substring($Source.Length)
                $destPath = Join-Path $Destination $relativePath
                if (-not (Test-Path $destPath)) {
                    New-Item -ItemType Directory -Path $destPath -Force | Out-Null
                }
            } else {
                # Copy file
                $relativePath = $item.FullName.Substring($Source.Length)
                $destPath = Join-Path $Destination $relativePath
                Copy-Item -Path $item.FullName -Destination $destPath -Force
                
                $copiedSize += $item.Length
                $fileCount++
                
                # Show progress every 10 files or if file is large
                if (($fileCount % 10 -eq 0) -or ($item.Length -gt 10MB)) {
                    $percentComplete = [math]::Round(($copiedSize / $totalSize) * 100, 1)
                    Write-Progress -Activity "Copying Database Files" -Status "$percentComplete% Complete" -PercentComplete $percentComplete
                }
            }
        }
        
        Write-Progress -Activity "Copying Database Files" -Completed
        Write-Log "Database copy completed successfully! ($fileCount files, $totalSizeMB MB)" -Level "SUCCESS"
        
        return $true
        
    } catch {
        Write-Log "Error during database copy: $($_.Exception.Message)" -Level "ERROR"
        Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level "ERROR"
        return $false
    }
}

function Test-NetworkDrive {
    param(
        [Parameter(Mandatory=$true)]
        [string]$DrivePath
    )
    
    # Extract drive letter if path contains it
    if ($DrivePath -match "^([A-Z]:)") {
        $driveLetter = $matches[1]
        
        try {
            $drive = Get-PSDrive -Name $driveLetter.TrimEnd(':') -ErrorAction SilentlyContinue
            if ($drive) {
                Write-Log "Drive $driveLetter is accessible" -Level "INFO"
                return $true
            }
        } catch {
            Write-Log "Drive $driveLetter is not accessible: $($_.Exception.Message)" -Level "WARNING"
            return $false
        }
    }
    
    return Test-Path $DrivePath
}

# Main installation script
function Start-Installation {
    Write-Log "========================================" -Level "INFO"
    Write-Log "JBH Database Installer Started" -Level "INFO"
    Write-Log "========================================" -Level "INFO"
    
    # Check for administrator privileges
    if (-not (Test-Administrator)) {
        Write-Log "Administrator privileges are recommended for installation" -Level "WARNING"
        $response = Read-Host "Continue anyway? (Y/N)"
        if ($response -ne "Y" -and $response -ne "y") {
            Write-Log "Installation cancelled by user" -Level "INFO"
            exit 0
        }
    }
    
    # Show configuration menu
    $selectedConfig = Show-ConfigurationMenu
    Write-Log "User selected configuration: $selectedConfig" -Level "INFO"
    
    # Get configuration paths
    $configPaths = Get-ConfigurationPaths -ConfigType $selectedConfig
    
    # Determine source and destination
    if ($selectedConfig -eq "Custom") {
        $finalSource = $configPaths.CustomSource
        $finalDestination = $configPaths.CustomDestination
    } else {
        $finalSource = Join-Path $SourcePath $configPaths.SourceSubPath
        $finalDestination = $DestinationPath
    }
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  Installation Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Configuration: $selectedConfig" -ForegroundColor White
    Write-Host "Description:   $($configPaths.Description)" -ForegroundColor White
    Write-Host "Source:        $finalSource" -ForegroundColor White
    Write-Host "Destination:   $finalDestination" -ForegroundColor White
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    $confirm = Read-Host "Proceed with installation? (Y/N)"
    if ($confirm -ne "Y" -and $confirm -ne "y") {
        Write-Log "Installation cancelled by user" -Level "INFO"
        exit 0
    }
    
    # Test network drive connectivity
    Write-Log "Testing network drive connectivity..." -Level "INFO"
    if (-not (Test-NetworkDrive -DrivePath $finalSource)) {
        Write-Log "Unable to access source path. Please ensure Z: drive is mapped and accessible." -Level "ERROR"
        Write-Host "`nTroubleshooting tips:" -ForegroundColor Yellow
        Write-Host "  1. Ensure Z: drive is mapped to the network share" -ForegroundColor Gray
        Write-Host "  2. Check your network connection" -ForegroundColor Gray
        Write-Host "  3. Verify you have permissions to access the network share" -ForegroundColor Gray
        Read-Host "`nPress Enter to exit"
        exit 1
    }
    
    # Perform the copy operation
    $success = Copy-DatabaseFiles -Source $finalSource -Destination $finalDestination -Description $configPaths.Description
    
    if ($success) {
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  Installation Completed Successfully!  " -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "`nDatabase installed to: $finalDestination" -ForegroundColor White
        Write-Host "Log file saved to: $LogFile" -ForegroundColor Gray
        Write-Log "Installation completed successfully" -Level "SUCCESS"
    } else {
        Write-Host "`n========================================" -ForegroundColor Red
        Write-Host "  Installation Failed  " -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "`nPlease check the log file for details: $LogFile" -ForegroundColor Yellow
        Write-Log "Installation failed" -Level "ERROR"
        Read-Host "`nPress Enter to exit"
        exit 1
    }
    
    Read-Host "`nPress Enter to exit"
}

# Execute main installation
try {
    Start-Installation
} catch {
    Write-Log "Unexpected error occurred: $($_.Exception.Message)" -Level "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level "ERROR"
    Write-Host "`nAn unexpected error occurred. Please check the log file: $LogFile" -ForegroundColor Red
    Read-Host "`nPress Enter to exit"
    exit 1
}
