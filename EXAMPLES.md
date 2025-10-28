# JBH Database Installer - Demo Script

This document demonstrates how the installer works with example scenarios.

## Demo Scenario 1: Standard Installation (CLI)

**User Action:** Double-click `Install-JBHDatabase.bat`

**Expected Output:**
```
========================================
  JBH Database Installer for Autodesk
========================================

Starting installer...

========================================
  JBH Database Installer for Autodesk  
========================================

Please select the database configuration:
  1. Standard Configuration (Recommended for most users)
  2. Advanced Configuration (For power users)
  3. Custom Configuration (Specify custom paths)
  Q. Quit

Enter your choice (1-3 or Q): 1

========================================
  Installation Summary
========================================
Configuration: Standard
Description:   Standard database with default settings
Source:        Z:\JBH-Database\Standard
Destination:   C:\ProgramData\JBH\Database
========================================

Proceed with installation? (Y/N): Y

[2025-10-28 16:45:00] [INFO] Testing network drive connectivity...
[2025-10-28 16:45:01] [INFO] Drive Z: is accessible
[2025-10-28 16:45:01] [INFO] Starting database copy operation...
[2025-10-28 16:45:01] [INFO] Source: Z:\JBH-Database\Standard
[2025-10-28 16:45:01] [INFO] Destination: C:\ProgramData\JBH\Database
[2025-10-28 16:45:02] [INFO] Total size to copy: 125.50 MB
[2025-10-28 16:45:02] [INFO] Creating destination directory: C:\ProgramData\JBH\Database

Copying files, please wait...
[Progress bar showing: ████████████████████████████████████████ 100%]

[2025-10-28 16:45:45] [SUCCESS] Database copy completed successfully! (450 files, 125.50 MB)

========================================
  Installation Completed Successfully!  
========================================

Database installed to: C:\ProgramData\JBH\Database
Log file saved to: C:\Users\YourName\AppData\Local\Temp\JBH-Installer-Logs\Install-20251028-164500.log

Press Enter to exit
```

## Demo Scenario 2: GUI Installation

**User Action:** Double-click `Install-JBHDatabase-GUI.bat`

**Expected Behavior:**
1. A window opens titled "JBH Database Installer for Autodesk"
2. Three radio buttons are displayed:
   - ⚫ Standard Configuration (Recommended for most users) [Selected by default]
   - ⚪ Advanced Configuration (For power users)
   - ⚪ Custom Configuration (Specify custom paths)
3. Path fields show:
   - Source Path: Z:\JBH-Database [with Browse button]
   - Destination Path: C:\ProgramData\JBH\Database [with Browse button]
4. User clicks "Install" button
5. Confirmation dialog appears: "This will install the database to: C:\ProgramData\JBH\Database. Do you want to proceed?"
6. User clicks "Yes"
7. Progress window appears showing:
   - Progress bar advancing
   - Status: "Copying database files..."
   - Details: "150 of 450 files copied (45.50 MB of 125.50 MB)"
8. Completion dialog: "Database installation completed successfully! Files copied: 450, Total size: 125.50 MB"
9. User clicks "OK" and application closes

## Demo Scenario 3: Custom Paths Installation

**User Action:** Run installer with custom parameters

```powershell
.\Install-JBHDatabase.ps1 -SourcePath "Z:\CustomDB\MyDatabase" -DestinationPath "D:\Projects\Database" -Configuration "Custom"
```

**Expected Output:**
```
[2025-10-28 16:50:00] [INFO] ========================================
[2025-10-28 16:50:00] [INFO] JBH Database Installer Started
[2025-10-28 16:50:00] [INFO] ========================================
[2025-10-28 16:50:00] [INFO] User selected configuration: Custom
[2025-10-28 16:50:00] [INFO] Starting database copy operation...
[2025-10-28 16:50:00] [INFO] Source: Z:\CustomDB\MyDatabase
[2025-10-28 16:50:00] [INFO] Destination: D:\Projects\Database
...
[Installation proceeds automatically]
...
[2025-10-28 16:52:30] [SUCCESS] Installation completed successfully
```

## Demo Scenario 4: Upgrading Existing Database

**Situation:** Database already exists at C:\ProgramData\JBH\Database

**User Action:** Run standard installation

**Expected Behavior:**
```
[2025-10-28 17:00:05] [WARNING] Backing up existing database to: C:\ProgramData\JBH\Database-Backup-20251028-170005
[2025-10-28 17:00:25] [SUCCESS] Backup completed successfully
[2025-10-28 17:00:25] [INFO] Copying database files...
[Installation continues normally]
```

**Result:**
- Old database backed up to: `C:\ProgramData\JBH\Database-Backup-20251028-170005`
- New database installed to: `C:\ProgramData\JBH\Database`

## Demo Scenario 5: Error Handling - Z: Drive Not Available

**Situation:** Z: drive is not mapped or accessible

**Expected Output:**
```
[2025-10-28 17:10:00] [INFO] Testing network drive connectivity...
[2025-10-28 17:10:02] [WARNING] Drive Z: is not accessible
[2025-10-28 17:10:02] [ERROR] Unable to access source path. Please ensure Z: drive is mapped and accessible.

Troubleshooting tips:
  1. Ensure Z: drive is mapped to the network share
  2. Check your network connection
  3. Verify you have permissions to access the network share

Press Enter to exit
```

## Demo Scenario 6: Insufficient Disk Space

**Situation:** Not enough space on C: drive

**Expected Output:**
```
[2025-10-28 17:15:00] [INFO] Total size to copy: 500.00 MB
[2025-10-28 17:15:01] [ERROR] Error during database copy: There is not enough space on the disk.
[2025-10-28 17:15:01] [ERROR] Installation failed

========================================
  Installation Failed  
========================================

Please check the log file for details: C:\Users\YourName\AppData\Local\Temp\JBH-Installer-Logs\Install-20251028-171500.log

Press Enter to exit
```

## Demo Scenario 7: Silent Installation (IT Deployment)

**User Action:** IT admin runs from command line or GPO

```batch
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "\\networkshare\installer\Install-JBHDatabase.ps1" -Configuration "Standard"
```

**Expected Behavior:**
- Installation runs silently in the background
- No user interaction required
- Logs written to standard location
- Exit code 0 on success, 1 on failure

## Log File Example

**Location:** `%TEMP%\JBH-Installer-Logs\Install-20251028-164500.log`

**Content:**
```
[2025-10-28 16:45:00] [INFO] ========================================
[2025-10-28 16:45:00] [INFO] JBH Database Installer Started
[2025-10-28 16:45:00] [INFO] ========================================
[2025-10-28 16:45:00] [INFO] User selected configuration: Standard
[2025-10-28 16:45:01] [INFO] Testing network drive connectivity...
[2025-10-28 16:45:01] [INFO] Drive Z: is accessible
[2025-10-28 16:45:01] [INFO] Starting database copy operation...
[2025-10-28 16:45:01] [INFO] Source: Z:\JBH-Database\Standard
[2025-10-28 16:45:01] [INFO] Destination: C:\ProgramData\JBH\Database
[2025-10-28 16:45:01] [INFO] Description: Standard database with default settings
[2025-10-28 16:45:02] [INFO] Total size to copy: 125.50 MB
[2025-10-28 16:45:02] [INFO] Creating destination directory: C:\ProgramData\JBH\Database
[2025-10-28 16:45:02] [INFO] Copying database files...
[2025-10-28 16:45:45] [SUCCESS] Database copy completed successfully! (450 files, 125.50 MB)
[2025-10-28 16:45:45] [SUCCESS] Installation completed successfully
```

## Testing Checklist

Before deploying to production, test the following scenarios:

- [ ] Install Standard configuration on clean system
- [ ] Install Advanced configuration on clean system
- [ ] Install Custom configuration with custom paths
- [ ] Upgrade existing database (verify backup is created)
- [ ] Install with Z: drive not available (verify error handling)
- [ ] Install with insufficient disk space (verify error handling)
- [ ] Install without admin rights (verify warning displayed)
- [ ] Install using GUI version
- [ ] Install using CLI version
- [ ] Install using silent/automated method
- [ ] Verify log files are created correctly
- [ ] Verify backup functionality
- [ ] Verify progress reporting works correctly
- [ ] Test "Cancel" button in GUI
- [ ] Test Browse buttons in GUI
- [ ] Test all three radio button selections in GUI

## Performance Expectations

Based on typical database sizes:

| Configuration | Typical Size | Files | Estimated Time* |
|---------------|-------------|-------|-----------------|
| Standard      | 100-150 MB  | 400-500 | 30-60 seconds |
| Advanced      | 200-300 MB  | 800-1000 | 60-90 seconds |
| Custom        | Varies      | Varies | Varies |

*Time estimates based on local network with 1 Gbps connection

## Notes for Developers

- Scripts are compatible with PowerShell 5.1+ and PowerShell Core 7+
- GUI requires Windows Forms (Windows only)
- CLI version works on any system with PowerShell
- All paths use standard Windows path separators
- Network drives are validated before copy operations
- Atomic copy operations ensure data integrity
- Comprehensive error handling throughout
- Progress reporting updates every 5-10 files for performance
