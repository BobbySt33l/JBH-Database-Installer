# Quick Start Guide

## For End Users

### Using the GUI Installer (Recommended)

1. **Ensure Prerequisites**
   - Z: drive is mapped and accessible
   - You have sufficient space on C: drive (check database size on Z: drive)

2. **Run the Installer**
   - Double-click `Install-JBHDatabase-GUI.bat`
   - A window will open with installation options

3. **Select Configuration**
   - Choose **Standard** (recommended for most users)
   - Choose **Advanced** (for power users)
   - Choose **Custom** (to specify different paths)

4. **Review Paths**
   - Source Path: Where the database is located (default: Z:\JBH-Database)
   - Destination Path: Where to install (default: C:\ProgramData\JBH\Database)
   - Click "Browse" to change either path

5. **Install**
   - Click the "Install" button
   - Confirm the installation
   - Wait for the progress bar to complete
   - Click OK when installation is complete

### Using the Command Line Installer

1. **Run the Batch File**
   - Double-click `Install-JBHDatabase.bat`
   - Follow the on-screen menu

2. **Select Configuration**
   - Type `1` for Standard
   - Type `2` for Advanced
   - Type `3` for Custom
   - Press Enter

3. **Confirm Installation**
   - Review the installation summary
   - Type `Y` and press Enter to proceed
   - Wait for the installation to complete

## For IT Administrators

### Silent Installation

Run the PowerShell script with pre-configured parameters:

```powershell
# Standard installation
powershell.exe -ExecutionPolicy Bypass -File "Install-JBHDatabase.ps1" -Configuration "Standard"

# Custom paths
powershell.exe -ExecutionPolicy Bypass -File "Install-JBHDatabase.ps1" -SourcePath "Z:\CustomDB" -DestinationPath "C:\MyDB" -Configuration "Custom"
```

### Group Policy Deployment

1. Copy all installer files to a network share
2. Create a GPO with a startup/logon script
3. Call the installer with appropriate parameters:

```batch
\\network\share\Install-JBHDatabase.bat
```

### Configuration Management

Edit `config.json` to customize default settings:

```json
{
  "paths": {
    "defaultSource": "Z:\\YourDatabase",
    "defaultDestination": "C:\\YourPath\\Database"
  }
}
```

### Troubleshooting Common Issues

#### Z: Drive Not Found
```powershell
# Check if Z: drive is mapped
Get-PSDrive -Name Z

# Map Z: drive manually
New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\server\share" -Persist
```

#### Permission Denied
- Run as Administrator
- Check NTFS permissions on destination
- Verify network share permissions

#### Installation Hangs
- Check network connectivity
- Verify sufficient disk space
- Review log files in %TEMP%\JBH-Installer-Logs\

### Viewing Logs

```powershell
# Open log directory
explorer %TEMP%\JBH-Installer-Logs\

# View latest log
Get-Content (Get-ChildItem $env:TEMP\JBH-Installer-Logs\*.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
```

## Common Scenarios

### Scenario 1: First Time Installation
1. Run GUI installer
2. Select Standard configuration
3. Use default paths
4. Click Install

### Scenario 2: Upgrading Existing Database
1. Run installer (GUI or CLI)
2. Installer will automatically backup existing database
3. New database will be installed
4. Old backup will be in: `C:\ProgramData\JBH\Database-Backup-TIMESTAMP`

### Scenario 3: Multiple Workstations
1. Customize `config.json` once
2. Distribute installer package to workstations
3. Users run the installer
4. All get consistent configuration

### Scenario 4: Testing Before Production
1. Use Custom configuration
2. Set destination to a test folder (e.g., C:\Temp\TestDB)
3. Verify database integrity
4. Run again with production paths

## Support

If you encounter issues:

1. Check the log file: `%TEMP%\JBH-Installer-Logs\Install-YYYYMMDD-HHMMSS.log`
2. Verify network connectivity to Z: drive
3. Ensure sufficient disk space
4. Contact IT support with the log file

## Next Steps

After installation:
- Configure Autodesk application to use the new database path
- Test database connectivity
- Remove old backups when no longer needed
- Document your installation for future reference
