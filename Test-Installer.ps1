<#
.SYNOPSIS
    Test script for JBH Database Installer
    
.DESCRIPTION
    This script performs basic validation tests on the installer scripts
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  JBH Database Installer - Test Suite  " -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$testResults = @()
$testsPassed = 0
$testsFailed = 0

function Test-ScriptSyntax {
    param(
        [string]$ScriptPath
    )
    
    Write-Host "Testing syntax: $ScriptPath" -ForegroundColor Yellow
    
    try {
        $content = Get-Content $ScriptPath -Raw
        $errors = $null
        $tokens = $null
        
        # Use AST parsing for better syntax validation
        $ast = [System.Management.Automation.Language.Parser]::ParseInput(
            $content,
            [ref]$tokens,
            [ref]$errors
        )
        
        if ($errors.Count -eq 0) {
            Write-Host "  ✓ Syntax check passed" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ✗ Syntax errors found:" -ForegroundColor Red
            foreach ($error in $errors) {
                Write-Host "    - $($error.Message)" -ForegroundColor Red
            }
            return $false
        }
    } catch {
        Write-Host "  ✗ Error checking syntax: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-FileExists {
    param(
        [string]$FilePath,
        [string]$Description
    )
    
    Write-Host "Testing file existence: $Description" -ForegroundColor Yellow
    
    if (Test-Path $FilePath) {
        Write-Host "  ✓ File exists: $FilePath" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ File not found: $FilePath" -ForegroundColor Red
        return $false
    }
}

function Test-JsonConfiguration {
    param(
        [string]$ConfigPath
    )
    
    Write-Host "Testing JSON configuration: $ConfigPath" -ForegroundColor Yellow
    
    try {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        
        # Validate required sections
        if (-not $config.installer) {
            throw "Missing 'installer' section"
        }
        if (-not $config.paths) {
            throw "Missing 'paths' section"
        }
        if (-not $config.configurations) {
            throw "Missing 'configurations' section"
        }
        
        Write-Host "  ✓ JSON configuration is valid" -ForegroundColor Green
        Write-Host "    - Version: $($config.installer.version)" -ForegroundColor Gray
        Write-Host "    - Configurations: $($config.configurations.PSObject.Properties.Name -join ', ')" -ForegroundColor Gray
        return $true
        
    } catch {
        Write-Host "  ✗ JSON configuration error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-FunctionExists {
    param(
        [string]$ScriptPath,
        [string[]]$FunctionNames
    )
    
    Write-Host "Testing functions in: $ScriptPath" -ForegroundColor Yellow
    
    try {
        $content = Get-Content $ScriptPath -Raw
        $errors = $null
        $tokens = $null
        
        # Use AST parsing for accurate function detection
        $ast = [System.Management.Automation.Language.Parser]::ParseInput(
            $content,
            [ref]$tokens,
            [ref]$errors
        )
        
        # Get all function definitions from the AST
        $functions = $ast.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
        }, $true)
        
        $foundFunctions = $functions | ForEach-Object { $_.Name }
        $allFound = $true
        
        foreach ($funcName in $FunctionNames) {
            if ($foundFunctions -contains $funcName) {
                Write-Host "  ✓ Function found: $funcName" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Function not found: $funcName" -ForegroundColor Red
                $allFound = $false
            }
        }
        
        return $allFound
        
    } catch {
        Write-Host "  ✗ Error checking functions: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Run tests
Write-Host "`n=== File Existence Tests ===" -ForegroundColor Cyan

$files = @(
    @{ Path = "Install-JBHDatabase.ps1"; Description = "CLI Installer Script" }
    @{ Path = "Install-JBHDatabase.bat"; Description = "CLI Batch Launcher" }
    @{ Path = "Install-JBHDatabase-GUI.ps1"; Description = "GUI Installer Script" }
    @{ Path = "Install-JBHDatabase-GUI.bat"; Description = "GUI Batch Launcher" }
    @{ Path = "config.json"; Description = "Configuration File" }
    @{ Path = "README.md"; Description = "README Documentation" }
    @{ Path = "QUICKSTART.md"; Description = "Quick Start Guide" }
    @{ Path = ".gitignore"; Description = "Git Ignore File" }
    @{ Path = "LICENSE"; Description = "License File" }
)

foreach ($file in $files) {
    if (Test-FileExists -FilePath $file.Path -Description $file.Description) {
        $testsPassed++
    } else {
        $testsFailed++
    }
}

Write-Host "`n=== Syntax Validation Tests ===" -ForegroundColor Cyan

$scripts = @(
    "Install-JBHDatabase.ps1",
    "Install-JBHDatabase-GUI.ps1"
)

foreach ($script in $scripts) {
    if (Test-ScriptSyntax -ScriptPath $script) {
        $testsPassed++
    } else {
        $testsFailed++
    }
}

Write-Host "`n=== Configuration File Tests ===" -ForegroundColor Cyan

if (Test-JsonConfiguration -ConfigPath "config.json") {
    $testsPassed++
} else {
    $testsFailed++
}

Write-Host "`n=== Function Existence Tests ===" -ForegroundColor Cyan

$cliFunctions = @(
    "Write-Log",
    "Test-Administrator",
    "Show-ConfigurationMenu",
    "Get-ConfigurationPaths",
    "Copy-DatabaseFiles",
    "Test-NetworkDrive",
    "Start-Installation"
)

if (Test-FunctionExists -ScriptPath "Install-JBHDatabase.ps1" -FunctionNames $cliFunctions) {
    $testsPassed++
} else {
    $testsFailed++
}

$guiFunctions = @(
    "Write-Log",
    "Show-MessageBox",
    "Start-DatabaseCopy"
)

if (Test-FunctionExists -ScriptPath "Install-JBHDatabase-GUI.ps1" -FunctionNames $guiFunctions) {
    $testsPassed++
} else {
    $testsFailed++
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host "Total Tests:  $($testsPassed + $testsFailed)" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

if ($testsFailed -eq 0) {
    Write-Host "All tests passed! ✓" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some tests failed! ✗" -ForegroundColor Red
    exit 1
}
