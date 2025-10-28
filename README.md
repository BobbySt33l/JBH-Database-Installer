# JBH Database Installer for Autodesk

An automated installer that copies the appropriate database configuration from the network Z: drive to the user's local C: drive for Autodesk applications.

## Overview

This installer provides a user-friendly way to deploy JBH databases to local workstations. It supports multiple database configurations and handles the entire installation process, including backup, error handling, and logging.

## Features

- **Multiple Configurations**: Choose from Standard, Advanced, or Custom database configurations
- **Automatic Backup**: Creates backups of existing databases before installation
- **Progress Tracking**: Real-time progress display during file copy operations
- **Error Handling**: Comprehensive error checking and user-friendly error messages
- **Detailed Logging**: Complete installation logs saved for troubleshooting
- **Network Drive Validation**: Verifies Z: drive connectivity before installation
- **Flexible Paths**: Support for custom source and destination paths

## Prerequisites

- Windows operating system
- PowerShell 5.1 or later
- Network access to Z: drive (mapped network share)
- Sufficient disk space on C: drive
- (Optional) Administrator privileges for system-wide installation

## Installation

### Quick Start

1. Ensure your Z: drive is mapped and accessible
2. Double-click `Install-JBHDatabase.bat` to launch the installer
3. Follow the on-screen prompts to select your configuration
4. Wait for the installation to complete

### Command Line Usage

You can also run the installer from PowerShell with custom parameters:

```powershell
# Run with default settings
.\Install-JBHDatabase.ps1

# Specify custom paths
.\Install-JBHDatabase.ps1 -SourcePath "Z:\CustomDatabase" -DestinationPath "C:\MyDatabase"

# Pre-select a configuration
.\Install-JBHDatabase.ps1 -Configuration "Advanced"
```

### Available Parameters

- **SourcePath**: Source directory on the network drive (default: `Z:\JBH-Database`)
- **DestinationPath**: Destination directory on the local drive (default: `C:\ProgramData\JBH\Database`)
- **Configuration**: Pre-select configuration type: `Standard`, `Advanced`, or `Custom`

## Database Configurations

### Standard Configuration (Recommended)
- Best for most users
- Includes default database settings
- Optimized for typical Autodesk workflows

### Advanced Configuration
- For power users with specific requirements
- Includes extended features and additional data
- May require more disk space

### Custom Configuration
- Allows you to specify custom source and destination paths
- Provides maximum flexibility
- Useful for non-standard deployments

## Configuration File

The installer uses `config.json` to store default settings. You can edit this file to customize:

- Default paths
- Available configurations
- Backup options
- Logging preferences

Example configuration:

```json
{
  "paths": {
    "defaultSource": "Z:\\JBH-Database",
    "defaultDestination": "C:\\ProgramData\\JBH\\Database"
  },
  "configurations": {
    "Standard": {
      "subPath": "Standard",
      "description": "Standard database with default settings"
    }
  }
}
```

## Troubleshooting

### Z: Drive Not Accessible

If you receive an error about the Z: drive not being accessible:

1. Verify the network drive is mapped in File Explorer
2. Check your network connection
3. Ensure you have permissions to access the network share
4. Try accessing the Z: drive manually before running the installer

### Insufficient Permissions

If you encounter permission errors:

1. Right-click `Install-JBHDatabase.bat`
2. Select "Run as administrator"
3. Follow the prompts to complete installation

### Installation Failed

If installation fails:

1. Check the log file in `%TEMP%\JBH-Installer-Logs\`
2. Verify you have sufficient disk space
3. Ensure no Autodesk applications are currently accessing the database
4. Try running the installer again

## Logs

Installation logs are automatically saved to:
```
%TEMP%\JBH-Installer-Logs\Install-YYYYMMDD-HHMMSS.log
```

Each log file contains:
- Timestamp for each operation
- Source and destination paths
- File copy progress
- Any errors or warnings encountered

## Backups

Before installing a new database, the installer automatically creates a backup of any existing database in the destination directory. Backups are saved with a timestamp:

```
C:\ProgramData\JBH\Database-Backup-YYYYMMDD-HHMMSS
```

## Uninstallation

To remove the installed database:

1. Navigate to the installation directory (default: `C:\ProgramData\JBH\Database`)
2. Delete the folder
3. (Optional) Remove backup folders if no longer needed

## Support

For issues or questions:
- Check the troubleshooting section above
- Review the installation log files
- Contact your IT support team

## Version History

### Version 1.0.0
- Initial release
- Support for Standard, Advanced, and Custom configurations
- Automatic backup functionality
- Progress tracking and detailed logging
- Network drive validation

## License

Copyright © 2025 JBH Team. All rights reserved.