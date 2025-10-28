<#
.SYNOPSIS
    JBH Database Installer for Autodesk - GUI Version
    
.DESCRIPTION
    This script provides a graphical user interface for copying databases
    from the network Z: drive to the user's local C: drive.
    
.NOTES
    Author: JBH Team
    Version: 1.0
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Initialize variables
$script:selectedConfig = "Standard"
$script:sourcePath = "Z:\JBH-Database"
$script:destinationPath = "C:\ProgramData\JBH\Database"
$script:logPath = "$env:TEMP\JBH-Installer-Logs"

# Ensure log directory exists
if (-not (Test-Path $script:logPath)) {
    New-Item -ItemType Directory -Path $script:logPath -Force | Out-Null
}

$script:logFile = Join-Path $script:logPath "Install-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $script:logFile -Value $logMessage
}

function Show-MessageBox {
    param(
        [string]$Message,
        [string]$Title = "JBH Database Installer",
        [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::Information
    )
    
    return [System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon)
}

function Start-DatabaseCopy {
    param(
        [System.Windows.Forms.Form]$ParentForm
    )
    
    try {
        # Determine final paths based on configuration
        if ($script:selectedConfig -eq "Custom") {
            $finalSource = $script:sourcePath
            $finalDestination = $script:destinationPath
        } else {
            $finalSource = Join-Path $script:sourcePath $script:selectedConfig
            $finalDestination = $script:destinationPath
        }
        
        Write-Log "Starting installation with configuration: $script:selectedConfig"
        Write-Log "Source: $finalSource"
        Write-Log "Destination: $finalDestination"
        
        # Validate source
        if (-not (Test-Path $finalSource)) {
            throw "Source path does not exist: $finalSource`n`nPlease ensure Z: drive is mapped and accessible."
        }
        
        # Create progress form
        $progressForm = New-Object System.Windows.Forms.Form
        $progressForm.Text = "Installing Database..."
        $progressForm.Size = New-Object System.Drawing.Size(500, 200)
        $progressForm.StartPosition = "CenterScreen"
        $progressForm.FormBorderStyle = "FixedDialog"
        $progressForm.MaximizeBox = $false
        $progressForm.MinimizeBox = $false
        
        $progressLabel = New-Object System.Windows.Forms.Label
        $progressLabel.Location = New-Object System.Drawing.Point(20, 20)
        $progressLabel.Size = New-Object System.Drawing.Size(450, 40)
        $progressLabel.Text = "Preparing to copy database files..."
        $progressForm.Controls.Add($progressLabel)
        
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point(20, 70)
        $progressBar.Size = New-Object System.Drawing.Size(450, 30)
        $progressBar.Style = "Continuous"
        $progressForm.Controls.Add($progressBar)
        
        $statusLabel = New-Object System.Windows.Forms.Label
        $statusLabel.Location = New-Object System.Drawing.Point(20, 110)
        $statusLabel.Size = New-Object System.Drawing.Size(450, 40)
        $statusLabel.Text = "Initializing..."
        $progressForm.Controls.Add($statusLabel)
        
        $progressForm.Show()
        $progressForm.Refresh()
        
        # Create destination directory
        if (-not (Test-Path $finalDestination)) {
            Write-Log "Creating destination directory"
            New-Item -ItemType Directory -Path $finalDestination -Force | Out-Null
        }
        
        # Backup existing database if present
        $existingFiles = Get-ChildItem -Path $finalDestination -ErrorAction SilentlyContinue
        if ($existingFiles) {
            $backupPath = "$finalDestination-Backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Write-Log "Creating backup at: $backupPath"
            $progressLabel.Text = "Creating backup of existing database..."
            $progressForm.Refresh()
            Copy-Item -Path $finalDestination -Destination $backupPath -Recurse -Force
        }
        
        # Get source files
        $progressLabel.Text = "Analyzing source files..."
        $progressForm.Refresh()
        
        $sourceItems = Get-ChildItem -Path $finalSource -Recurse -Force -ErrorAction SilentlyContinue
        $totalFiles = ($sourceItems | Where-Object { -not $_.PSIsContainer }).Count
        $totalSize = ($sourceItems | Measure-Object -Property Length -Sum).Sum
        $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
        
        Write-Log "Total files to copy: $totalFiles ($totalSizeMB MB)"
        
        # Copy files
        $progressLabel.Text = "Copying database files..."
        $statusLabel.Text = "0 of $totalFiles files copied (0 MB of $totalSizeMB MB)"
        $progressForm.Refresh()
        
        $copiedSize = 0
        $fileCount = 0
        
        foreach ($item in $sourceItems) {
            if ($item.PSIsContainer) {
                $relativePath = $item.FullName.Substring($finalSource.Length)
                $destPath = Join-Path $finalDestination $relativePath
                if (-not (Test-Path $destPath)) {
                    New-Item -ItemType Directory -Path $destPath -Force | Out-Null
                }
            } else {
                $relativePath = $item.FullName.Substring($finalSource.Length)
                $destPath = Join-Path $finalDestination $relativePath
                Copy-Item -Path $item.FullName -Destination $destPath -Force
                
                $copiedSize += $item.Length
                $fileCount++
                
                $percentComplete = [math]::Min(100, [math]::Round(($copiedSize / $totalSize) * 100, 1))
                $copiedMB = [math]::Round($copiedSize / 1MB, 2)
                
                $progressBar.Value = $percentComplete
                $statusLabel.Text = "$fileCount of $totalFiles files copied ($copiedMB MB of $totalSizeMB MB)"
                
                if ($fileCount % 5 -eq 0) {
                    $progressForm.Refresh()
                }
            }
        }
        
        $progressBar.Value = 100
        $progressLabel.Text = "Installation completed successfully!"
        $statusLabel.Text = "$fileCount files copied ($totalSizeMB MB total)"
        $progressForm.Refresh()
        
        Start-Sleep -Seconds 1
        $progressForm.Close()
        
        Write-Log "Installation completed successfully - $fileCount files, $totalSizeMB MB"
        
        Show-MessageBox -Message "Database installation completed successfully!`n`nFiles copied: $fileCount`nTotal size: $totalSizeMB MB`nDestination: $finalDestination" -Icon Information
        
        return $true
        
    } catch {
        Write-Log "Error during installation: $($_.Exception.Message)" -Level "ERROR"
        
        if ($progressForm) {
            $progressForm.Close()
        }
        
        Show-MessageBox -Message "Installation failed:`n`n$($_.Exception.Message)`n`nPlease check the log file for details:`n$script:logFile" -Icon Error
        
        return $false
    }
}

# Create main form
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "JBH Database Installer for Autodesk"
$mainForm.Size = New-Object System.Drawing.Size(600, 500)
$mainForm.StartPosition = "CenterScreen"
$mainForm.FormBorderStyle = "FixedDialog"
$mainForm.MaximizeBox = $false

# Title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(550, 30)
$titleLabel.Text = "JBH Database Installer for Autodesk"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$mainForm.Controls.Add($titleLabel)

# Configuration group box
$configGroupBox = New-Object System.Windows.Forms.GroupBox
$configGroupBox.Location = New-Object System.Drawing.Point(20, 60)
$configGroupBox.Size = New-Object System.Drawing.Size(550, 120)
$configGroupBox.Text = "Select Database Configuration"
$mainForm.Controls.Add($configGroupBox)

# Standard radio button
$standardRadio = New-Object System.Windows.Forms.RadioButton
$standardRadio.Location = New-Object System.Drawing.Point(20, 30)
$standardRadio.Size = New-Object System.Drawing.Size(500, 20)
$standardRadio.Text = "Standard Configuration (Recommended for most users)"
$standardRadio.Checked = $true
$standardRadio.Add_Click({
    $script:selectedConfig = "Standard"
})
$configGroupBox.Controls.Add($standardRadio)

# Advanced radio button
$advancedRadio = New-Object System.Windows.Forms.RadioButton
$advancedRadio.Location = New-Object System.Drawing.Point(20, 60)
$advancedRadio.Size = New-Object System.Drawing.Size(500, 20)
$advancedRadio.Text = "Advanced Configuration (For power users)"
$advancedRadio.Add_Click({
    $script:selectedConfig = "Advanced"
})
$configGroupBox.Controls.Add($advancedRadio)

# Custom radio button
$customRadio = New-Object System.Windows.Forms.RadioButton
$customRadio.Location = New-Object System.Drawing.Point(20, 90)
$customRadio.Size = New-Object System.Drawing.Size(500, 20)
$customRadio.Text = "Custom Configuration (Specify custom paths)"
$customRadio.Add_Click({
    $script:selectedConfig = "Custom"
})
$configGroupBox.Controls.Add($customRadio)

# Paths group box
$pathsGroupBox = New-Object System.Windows.Forms.GroupBox
$pathsGroupBox.Location = New-Object System.Drawing.Point(20, 190)
$pathsGroupBox.Size = New-Object System.Drawing.Size(550, 150)
$pathsGroupBox.Text = "Installation Paths"
$mainForm.Controls.Add($pathsGroupBox)

# Source path label
$sourceLabel = New-Object System.Windows.Forms.Label
$sourceLabel.Location = New-Object System.Drawing.Point(20, 30)
$sourceLabel.Size = New-Object System.Drawing.Size(100, 20)
$sourceLabel.Text = "Source Path:"
$pathsGroupBox.Controls.Add($sourceLabel)

# Source path textbox
$sourceTextBox = New-Object System.Windows.Forms.TextBox
$sourceTextBox.Location = New-Object System.Drawing.Point(20, 55)
$sourceTextBox.Size = New-Object System.Drawing.Size(440, 25)
$sourceTextBox.Text = $script:sourcePath
$sourceTextBox.Add_TextChanged({
    $script:sourcePath = $sourceTextBox.Text
})
$pathsGroupBox.Controls.Add($sourceTextBox)

# Source browse button
$sourceBrowseBtn = New-Object System.Windows.Forms.Button
$sourceBrowseBtn.Location = New-Object System.Drawing.Point(470, 53)
$sourceBrowseBtn.Size = New-Object System.Drawing.Size(60, 25)
$sourceBrowseBtn.Text = "Browse"
$sourceBrowseBtn.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select source database folder"
    $folderBrowser.SelectedPath = $script:sourcePath
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $script:sourcePath = $folderBrowser.SelectedPath
        $sourceTextBox.Text = $script:sourcePath
    }
})
$pathsGroupBox.Controls.Add($sourceBrowseBtn)

# Destination path label
$destLabel = New-Object System.Windows.Forms.Label
$destLabel.Location = New-Object System.Drawing.Point(20, 90)
$destLabel.Size = New-Object System.Drawing.Size(120, 20)
$destLabel.Text = "Destination Path:"
$pathsGroupBox.Controls.Add($destLabel)

# Destination path textbox
$destTextBox = New-Object System.Windows.Forms.TextBox
$destTextBox.Location = New-Object System.Drawing.Point(20, 115)
$destTextBox.Size = New-Object System.Drawing.Size(440, 25)
$destTextBox.Text = $script:destinationPath
$destTextBox.Add_TextChanged({
    $script:destinationPath = $destTextBox.Text
})
$pathsGroupBox.Controls.Add($destTextBox)

# Destination browse button
$destBrowseBtn = New-Object System.Windows.Forms.Button
$destBrowseBtn.Location = New-Object System.Drawing.Point(470, 113)
$destBrowseBtn.Size = New-Object System.Drawing.Size(60, 25)
$destBrowseBtn.Text = "Browse"
$destBrowseBtn.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select destination folder"
    $folderBrowser.SelectedPath = $script:destinationPath
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $script:destinationPath = $folderBrowser.SelectedPath
        $destTextBox.Text = $script:destinationPath
    }
})
$pathsGroupBox.Controls.Add($destBrowseBtn)

# Install button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(360, 360)
$installButton.Size = New-Object System.Drawing.Size(100, 35)
$installButton.Text = "Install"
$installButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$installButton.Add_Click({
    $result = Show-MessageBox -Message "This will install the database to:`n$script:destinationPath`n`nDo you want to proceed?" -Buttons YesNo -Icon Question
    
    if ($result -eq "Yes") {
        Write-Log "User initiated installation"
        $success = Start-DatabaseCopy -ParentForm $mainForm
        
        if ($success) {
            $mainForm.Close()
        }
    }
})
$mainForm.Controls.Add($installButton)

# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(470, 360)
$cancelButton.Size = New-Object System.Drawing.Size(100, 35)
$cancelButton.Text = "Cancel"
$cancelButton.Add_Click({
    Write-Log "User cancelled installation"
    $mainForm.Close()
})
$mainForm.Controls.Add($cancelButton)

# Info label
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Location = New-Object System.Drawing.Point(20, 410)
$infoLabel.Size = New-Object System.Drawing.Size(550, 40)
$infoLabel.Text = "This installer will copy the database from the network Z: drive to your local C: drive.`nExisting databases will be backed up automatically."
$infoLabel.ForeColor = [System.Drawing.Color]::Gray
$mainForm.Controls.Add($infoLabel)

# Log startup
Write-Log "========================================" 
Write-Log "JBH Database Installer GUI Started"
Write-Log "========================================"

# Show the form
[void]$mainForm.ShowDialog()
