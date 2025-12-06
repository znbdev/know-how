@echo off
setlocal

:: =================================================================
:: System Info Script (WMIC Alternative)
:: Uses PowerShell to execute WMI queries without relying on the WMIC executable.
:: =================================================================

title PC System Information Report (PowerShell Hybrid)

echo.
echo ===================================================
echo PC System Information Report
echo ===================================================
echo.

:: -----------------------------------------------------------------
:: SECTION 1: SYSTEM & OS DETAILS (SYSTEMINFO)
:: -----------------------------------------------------------------
echo ## 1. SYSTEM AND OPERATING SYSTEM DETAILS
echo ---------------------------------------------------
systeminfo | findstr /V /C:"Hotfix" /C:"KB" /C:"Time Zone" /C:"Update"
echo.
echo ---------------------------------------------------

:: -----------------------------------------------------------------
:: SECTION 2: HARDWARE DETAILS (POWERSHELL/WMI)
:: -----------------------------------------------------------------
echo ## 2. CPU, RAM, and Storage DETAILS
echo ---------------------------------------------------

:: Execute a single PowerShell command to get multiple hardware details
powershell -Command "$CPU = Get-CimInstance -ClassName Win32_Processor; Write-Host '--- CPU Details:'; $CPU | Format-List Name, NumberOfCores, NumberOfLogicalProcessors; Write-Host ''; $RAM = Get-CimInstance -ClassName Win32_ComputerSystem; Write-Host '--- Total Physical Memory (Bytes):'; $RAM.TotalPhysicalMemory; Write-Host ''; Write-Host '--- Memory Modules:'; Get-CimInstance -ClassName Win32_PhysicalMemory | Format-Table -AutoSize DeviceLocator, Capacity, Speed; Write-Host ''; Write-Host '--- Disk Drives:'; Get-CimInstance -ClassName Win32_DiskDrive | Format-Table -AutoSize Model, Size, InterfaceType"

echo.
echo ---------------------------------------------------

:: -----------------------------------------------------------------
:: SECTION 3: NETWORK DETAILS (IPCONFIG)
:: -----------------------------------------------------------------
echo ## 3. NETWORK DETAILS
echo ---------------------------------------------------
ipconfig | findstr /C:"IPv4" /C:"Default Gateway" /C:"Subnet"
echo.
echo ---------------------------------------------------

echo.
echo ===================================================
echo Report Finished.
echo ===================================================

pause
endlocal