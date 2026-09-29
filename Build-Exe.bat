@echo off
setlocal
title Building KAISER.exe...
chcp 65001 >nul 2>&1

set "CSC_PATH=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"

if not exist "%CSC_PATH%" (
    set "CSC_PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
)

if not exist "%CSC_PATH%" (
    echo [!] Error: .NET Framework C# Compiler ^(csc.exe^) was not found.
    pause
    exit /b 1
)

echo [*] Compiling KAISER.exe with embedded scripts and administrator manifest...
"%CSC_PATH%" /nologo /target:exe /out:"%~dp0KAISER.exe" /win32manifest:"%~dp0app.manifest" /resource:"%~dp0Optimizer.bat",Optimizer.bat /resource:"%~dp0MemoryCleaner.ps1",MemoryCleaner.ps1 /resource:"%~dp0banner.txt",banner.txt "%~dp0Program.cs"

if %errorlevel% equ 0 (
    echo [+] Compilation successful!
    echo [+] Created standalone binary: %~dp0KAISER.exe
) else (
    echo [!] Compilation failed with error code %errorlevel%.
)

exit /b %errorlevel%
