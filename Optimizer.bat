@echo off
setlocal
title KAISER - Windows 10/11 Optimizer
chcp 65001 >nul 2>&1

:: Enable ANSI Virtual Terminal Processing
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f "delims=" %%a in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%a"

:: Define ANSI Colors
set "C_RESET=%ESC%[0m"
set "C_BOLD=%ESC%[1m"
set "C_RED=%ESC%[91m"
set "C_GREEN=%ESC%[92m"
set "C_YELLOW=%ESC%[93m"
set "C_BLUE=%ESC%[94m"
set "C_MAGENTA=%ESC%[95m"
set "C_CYAN=%ESC%[96m"
set "C_WHITE=%ESC%[97m"
set "C_GRAY=%ESC%[90m"

:: Script Directory
set "SCRIPT_DIR=%~dp0"

:: Verify Administrative Privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo %C_YELLOW%[i] Administrative privileges required.%C_RESET%
    echo %C_CYAN%[*] Requesting UAC elevation...%C_RESET%
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs"
    exit /b
)

:: Cache Windows Version Information
for /f "tokens=4-5 delims=[.] " %%i in ('ver') do set "WIN_VER=%%i.%%j"
set "LOG_FILE=%TEMP%\Optimizer_Log.txt"
echo [%date% %time%] Optimizer session started on Windows Build %WIN_VER% >> "%LOG_FILE%"

:: ============================================================================
:: CLI PARAMETERS ROUTING
:: ============================================================================
set "ARG1=%~1"
if not defined ARG1 goto MAIN_MENU
if "%ARG1%"=="-h" goto CLI_HELP
if "%ARG1%"=="--help" goto CLI_HELP
if "%ARG1%"=="help" goto CLI_HELP
if "%ARG1%"=="/help" goto CLI_HELP
if "%ARG1%"=="/h" goto CLI_HELP

if /i "%ARG1%"=="/ram" (
    call :DO_MEMORY_CLEAN
    exit /b 0
)
if /i "%ARG1%"=="/memory" (
    call :DO_MEMORY_CLEAN
    exit /b 0
)
if /i "%ARG1%"=="/pro" (
    call :DO_ALL_PRO_TWEAKS
    exit /b 0
)
if /i "%ARG1%"=="/bcd" (
    call :DO_PRO_BCD
    exit /b 0
)
if /i "%ARG1%"=="/unpark" (
    call :DO_PRO_CPU_UNPARK
    exit /b 0
)
if /i "%ARG1%"=="/input" (
    call :DO_PRO_INPUT_LAG
    exit /b 0
)
if /i "%ARG1%"=="/nagle" (
    call :DO_PRO_NAGLE
    exit /b 0
)
if /i "%ARG1%"=="/shader" (
    call :DO_PRO_SHADER_CLEAN
    exit /b 0
)
if /i "%ARG1%"=="/fs" (
    call :DO_PRO_NTFS
    exit /b 0
)
if /i "%ARG1%"=="/quick" (
    echo %C_CYAN%[*] Quick Full Optimization selected.%C_RESET%
    echo.
    set /p "ASK_RP=%C_YELLOW%  Would you like to create a System Restore Point before proceeding? [Y/N]: %C_RESET%"
    if /i "%ASK_RP%"=="Y" (
        call :DO_RESTORE_POINT
    ) else (
        echo %C_GRAY%  [*] Skipping Restore Point creation.%C_RESET%
    )
    call :DO_PERFORMANCE_TWEAKS
    call :DO_PRIVACY_TWEAKS
    call :DO_DISK_CLEANUP
    call :DO_NETWORK_TWEAKS
    call :DO_SERVICES_TWEAKS
    call :DO_MEMORY_CLEAN
    echo %C_GREEN%[+] Quick Optimization completed successfully.%C_RESET%
    exit /b 0
)
if /i "%ARG1%"=="/perf" (
    echo %C_CYAN%[*] Applying Performance Tweaks...%C_RESET%
    call :DO_PERFORMANCE_TWEAKS
    echo %C_GREEN%[+] Performance tweaks applied.%C_RESET%
    exit /b 0
)
if /i "%ARG1%"=="/privacy" (
    echo %C_CYAN%[*] Applying Privacy Tweaks...%C_RESET%
    call :DO_PRIVACY_TWEAKS
    echo %C_GREEN%[+] Privacy tweaks applied.%C_RESET%
    exit /b 0
)
if /i "%ARG1%"=="/clean" (
    echo %C_CYAN%[*] Purging Disk and Cache...%C_RESET%
    call :DO_DISK_CLEANUP
    echo %C_GREEN%[+] Disk cleanup completed.%C_RESET%
    exit /b 0
)
if /i "%ARG1%"=="/network" (
    echo %C_CYAN%[*] Tuning Network and Latency...%C_RESET%
    call :DO_NETWORK_TWEAKS
    echo %C_GREEN%[+] Network tuning completed.%C_RESET%
    exit /b 0
)
if /i "%ARG1%"=="/services" (
    echo %C_CYAN%[*] Tuning Background Services...%C_RESET%
    call :DO_SERVICES_TWEAKS
    echo %C_GREEN%[+] Services tuning completed.%C_RESET%
    exit /b 0
)
if /i "%ARG1%"=="/repair" (
    echo %C_CYAN%[*] Running System Integrity Repair...%C_RESET%
    dism /Online /Cleanup-Image /RestoreHealth
    sfc /scannow
    echo %C_GREEN%[+] System repair completed.%C_RESET%
    exit /b 0
)
if /i "%ARG1%"=="/revert" (
    echo %C_YELLOW%[*] Reverting changes to Windows defaults...%C_RESET%
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
    call :RESTORE_SERVICES
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f >nul 2>&1
    echo %C_GREEN%[+] Baseline defaults restored.%C_RESET%
    exit /b 0
)
goto MAIN_MENU

:CLI_HELP
echo.
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_WHITE%  WINDOWS 10/11 OPTIMIZER - COMMAND LINE SYNTAX%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   Usage: %~nx0 [FLAG]
echo.
echo   Flags:
echo     /quick         Run full recommended optimization non-interactively
echo     /ram, /memory  Instantly trim working sets and purge standby RAM cache
echo     /pro           Apply all paid / pro optimization tweaks in one click
echo     /bcd           Apply BCD timer, HPET, and dynamic tick tweaks
echo     /unpark        Unpark all CPU cores and set Win32PrioritySeparation
echo     /input         Optimize mouse 1:1 raw input, FilterKeys and USB sleep
echo     /nagle         Disable Nagle's algorithm and TCP delayed ACK
echo     /shader        Purge GPU DirectX, NVIDIA, AMD, and Intel shader caches
echo     /fs            Boost NTFS file system throughput and disable 8.3 names
echo     /perf          Apply general performance and gaming latency tweaks
echo     /privacy       Disable telemetry, diagnostic tracking and ads
echo     /clean         Execute deep disk and cache purge
echo     /network       Apply TCP and low-latency network optimizations
echo     /services      Tweak unnecessary background services
echo     /repair        Run DISM RestoreHealth and SFC integrity repair
echo     /revert        Restore baseline Windows defaults
echo     /help          Display this help message
echo.
exit /b 0

:: ============================================================================
:: INTERACTIVE MAIN MENU
:: ============================================================================
:MAIN_MENU
cls
echo %C_CYAN%=================================================================================%C_RESET%
if not exist "%SCRIPT_DIR%banner.txt" (
    powershell -NoProfile -Command "[IO.File]::WriteAllBytes('%SCRIPT_DIR%banner.txt', [Convert]::FromBase64String('ICDilojilojilZcgIOKWiOKWiOKVlyDilojilojilojilojilojilZcg4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4pWXIAogIOKWiOKWiOKVkSDilojilojilZTilZ3ilojilojilZTilZDilZDilojilojilZfilojilojilZHilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilojilojilZcKICDilojilojilojilojilojilZTilZ0g4paI4paI4paI4paI4paI4paI4paI4pWR4paI4paI4pWR4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4pWXICDilojilojilojilojilojilojilZTilZ0KICDilojilojilZTilZDilojilojilZcg4paI4paI4pWU4pWQ4pWQ4paI4paI4pWR4paI4paI4pWR4pWa4pWQ4pWQ4pWQ4pWQ4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4pWdICDilojilojilZTilZDilZDilojilojilZcKICDilojilojilZEgIOKWiOKWiOKVl+KWiOKWiOKVkSAg4paI4paI4pWR4paI4paI4pWR4paI4paI4paI4paI4paI4paI4paI4pWR4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWRICDilojilojilZEKICDilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWa4pWQ4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ0K'))" >nul 2>&1
)
echo %C_BOLD%%C_CYAN%
type "%SCRIPT_DIR%banner.txt"
echo %C_RESET%%C_CYAN%=================================================================================%C_RESET%
echo %C_WHITE%  OS: %C_GREEN%Windows (Build %WIN_VER%)%C_WHITE%   Elevation: %C_GREEN%Admin Elevated%C_RESET%
echo %C_CYAN%---------------------------------------------------------------------------------%C_RESET%
echo %C_BOLD%%C_WHITE%  [1]%C_RESET% %C_GREEN%Quick Full Optimization%C_RESET%      %C_GRAY%- Recommended one-click safe performance boost%C_RESET%
echo %C_BOLD%%C_WHITE%  [M]%C_RESET% %C_CYAN%RAM and Memory Cleaner%C_RESET%       %C_GRAY%- Trim process working sets and purge standby cache%C_RESET%
echo %C_BOLD%%C_WHITE%  [P]%C_RESET% %C_YELLOW%PRO Optimizer Tweaks%C_RESET%        %C_GRAY%- BCD timers, Nagle's TCP, CPU unpark, Input lag%C_RESET%
echo %C_BOLD%%C_WHITE%  [2]%C_RESET% %C_CYAN%Performance and Gaming%C_RESET%       %C_GRAY%- Power plan, GPU scheduling, CPU priority%C_RESET%
echo %C_BOLD%%C_WHITE%  [3]%C_RESET% %C_MAGENTA%Privacy and Telemetry%C_RESET%        %C_GRAY%- Disable tracking, Cortana, DiagTrack, Ads%C_RESET%
echo %C_BOLD%%C_WHITE%  [4]%C_RESET% %C_YELLOW%Deep Disk and Cache Clean%C_RESET%    %C_GRAY%- Purge Temp, Prefetch, Update logs, DNS%C_RESET%
echo %C_BOLD%%C_WHITE%  [5]%C_RESET% %C_BLUE%Network and TCP Tuning%C_RESET%      %C_GRAY%- CTCP, TCP autotuning, latency tweaks%C_RESET%
echo %C_BOLD%%C_WHITE%  [6]%C_RESET% %C_CYAN%Windows Services Tuning%C_RESET%      %C_GRAY%- Disable redundant and heavy background tasks%C_RESET%
echo %C_BOLD%%C_WHITE%  [7]%C_RESET% %C_RED%Remove UWP Bloatware%C_RESET%        %C_GRAY%- Remove pre-installed junk apps (safe list)%C_RESET%
echo %C_BOLD%%C_WHITE%  [8]%C_RESET% %C_WHITE%System Health and Repair%C_RESET%     %C_GRAY%- SFC Scan, DISM RestoreHealth, Components%C_RESET%
echo %C_BOLD%%C_WHITE%  [9]%C_RESET% %C_GREEN%Create Restore Point%C_RESET%        %C_GRAY%- Safety first: capture system snapshot%C_RESET%
echo %C_BOLD%%C_WHITE%  [R]%C_RESET% %C_YELLOW%Revert / Reset Settings%C_RESET%      %C_GRAY%- Restore default Windows configurations%C_RESET%
echo %C_BOLD%%C_WHITE%  [L]%C_RESET% %C_GRAY%View Optimizer Log%C_RESET%
echo %C_BOLD%%C_WHITE%  [0]%C_RESET% %C_RED%Exit%C_RESET%
echo %C_CYAN%---------------------------------------------------------------------------------%C_RESET%
set /p "CHOICE=%C_BOLD%%C_YELLOW%  Select an option [0-9, M, P, R, L]: %C_RESET%"

if "%CHOICE%"=="1" goto MENU_QUICK_TWEAK
if /i "%CHOICE%"=="M" goto MENU_MEMORY
if /i "%CHOICE%"=="P" goto MENU_PRO_TWEAKS
if "%CHOICE%"=="2" goto MENU_PERFORMANCE
if "%CHOICE%"=="3" goto MENU_PRIVACY
if "%CHOICE%"=="4" goto MENU_DISK_CLEAN
if "%CHOICE%"=="5" goto MENU_NETWORK
if "%CHOICE%"=="6" goto MENU_SERVICES
if "%CHOICE%"=="7" goto MENU_BLOATWARE
if "%CHOICE%"=="8" goto MENU_REPAIR
if "%CHOICE%"=="9" goto MENU_RESTORE_POINT
if /i "%CHOICE%"=="R" goto MENU_REVERT
if /i "%CHOICE%"=="L" goto VIEW_LOG
if "%CHOICE%"=="0" goto EXIT_SCRIPT

echo %C_RED%  Invalid selection! Please choose a valid number or letter.%C_RESET%
timeout /t 1 >nul
goto MAIN_MENU

:: ============================================================================
:: OPTION 1: QUICK FULL OPTIMIZATION
:: ============================================================================
:MENU_QUICK_TWEAK
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_GREEN%  QUICK RECOMMENDED OPTIMIZATION%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   This will safely apply:
echo    - High or Ultimate Performance Power Scheme
echo    - Gaming responsiveness and network throttling tweaks
echo    - Disable Diagnostic Telemetry and Advertising ID
echo    - Deep Disk Cache Clean (Temp, update downloads, DNS)
echo    - Safe background service tuning
echo    - Physical RAM and Standby List Cache Purge
echo.
set /p "CONFIRM=%C_YELLOW%  Proceed with Quick Optimization? [Y/N]: %C_RESET%"
if /i not "%CONFIRM%"=="Y" goto MAIN_MENU

echo.
set /p "ASK_RP=%C_BOLD%%C_YELLOW%  Would you like to create a System Restore Point before proceeding? [Y/N]: %C_RESET%"
if /i "%ASK_RP%"=="Y" (
    call :DO_RESTORE_POINT
) else (
    echo %C_GRAY%  [*] Skipping Restore Point creation.%C_RESET%
)

call :DO_PERFORMANCE_TWEAKS
call :DO_PRIVACY_TWEAKS
call :DO_DISK_CLEANUP
call :DO_NETWORK_TWEAKS
call :DO_SERVICES_TWEAKS
call :DO_MEMORY_CLEAN

echo.
echo %C_GREEN%[+] Quick Optimization successfully applied!%C_RESET%
echo %C_YELLOW%[*] A system reboot is recommended for all changes to take full effect.%C_RESET%
echo.
pause
goto MAIN_MENU

:: ============================================================================
:: OPTION M: RAM & MEMORY CLEANER
:: ============================================================================
:MENU_MEMORY
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_CYAN%  RAM AND MEMORY CLEANER%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   This utility directly invokes the Windows NT kernel memory manager to:
echo    - Trim bloated process working sets across all running apps
echo    - Purge the Windows Standby Memory Cache (eliminates micro-stuttering)
echo    - Flush modified page lists
echo.
echo   [1] Clean Physical RAM and Standby List (Instantly Free Memory)
echo   [2] Run RAM Monitor (Auto-cleans RAM whenever usage exceeds 80%%)
echo   [B] Back to Main Menu
echo.
set /p "M_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%M_CHOICE%"=="B" goto MAIN_MENU
if "%M_CHOICE%"=="1" (
    call :DO_MEMORY_CLEAN
    pause & goto MENU_MEMORY
)
if "%M_CHOICE%"=="2" (
    call :DO_MEMORY_MONITOR
    goto MENU_MEMORY
)
goto MENU_MEMORY

:DO_MEMORY_CLEAN
echo %C_CYAN%[*] Cleaning System Memory and Purging Standby List...%C_RESET%
if exist "%SCRIPT_DIR%MemoryCleaner.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%MemoryCleaner.ps1"
) else (
    powershell -NoProfile -Command "$definition = @' using System; using System.Diagnostics; using System.Runtime.InteropServices; public class WinMemory { [DllImport(\"psapi.dll\")] public static extern int EmptyWorkingSet(IntPtr hwProc); [DllImport(\"ntdll.dll\")] public static extern int NtSetSystemInformation(int SystemInformationClass, IntPtr SystemInformation, int SystemInformationLength); public static int EmptyProcessWorkingSets() { int count = 0; foreach (Process p in Process.GetProcesses()) { try { if (!p.HasExited) { EmptyWorkingSet(p.Handle); count++; } } catch {} } return count; } public static bool PurgeStandbyList() { try { GCHandle handle = GCHandle.Alloc((int)4, GCHandleType.Pinned); int res = NtSetSystemInformation(80, handle.AddrOfPinnedObject(), Marshal.SizeOf(typeof(int))); handle.Free(); return (res == 0); } catch { return false; } } } '@; try { Add-Type -TypeDefinition $definition -Language CSharp -ErrorAction SilentlyContinue } catch {}; $os = Get-CimInstance Win32_OperatingSystem; $b = [math]::Round($os.FreePhysicalMemory / 1024, 0); [WinMemory]::EmptyProcessWorkingSets(); [WinMemory]::PurgeStandbyList(); [System.GC]::Collect(); Start-Sleep -Milliseconds 300; $os2 = Get-CimInstance Win32_OperatingSystem; $a = [math]::Round($os2.FreePhysicalMemory / 1024, 0); $freed = $a - $b; if ($freed -lt 0) { $freed = 0 }; Write-Host \"  [+] Physical RAM Freed: $freed MB\" -ForegroundColor Cyan"
)
echo [%date% %time%] Memory cleaned >> "%LOG_FILE%"
exit /b

:DO_MEMORY_MONITOR
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_GREEN%  AUTOMATIC RAM CLEANER MONITOR (ACTIVE)%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo %C_WHITE%  Monitors physical memory every 10 seconds.%C_RESET%
echo %C_YELLOW%  If RAM usage exceeds 80%%, it automatically purges cache and working sets.%C_RESET%
echo %C_GRAY%  Press CTRL+C or close this window to stop the monitor.%C_RESET%
echo %C_CYAN%------------------------------------------------------------------------%C_RESET%
powershell -NoProfile -Command ^
  "$cleaner = '%SCRIPT_DIR%MemoryCleaner.ps1';" ^
  "while ($true) {" ^
  "  $os = Get-CimInstance Win32_OperatingSystem;" ^
  "  $total = [math]::Round($os.TotalVisibleMemorySize / 1024, 0);" ^
  "  $free = [math]::Round($os.FreePhysicalMemory / 1024, 0);" ^
  "  $used = $total - $free;" ^
  "  $pct = [math]::Round(($used / $total) * 100, 1);" ^
  "  $time = (Get-Date).ToString('HH:mm:ss');" ^
  "  if ($pct -gt 80) {" ^
  "    Write-Host \"[$time] WARNING: RAM usage at $pct% ($used / $total MB). Triggering auto-clean...\" -ForegroundColor Yellow;" ^
  "    & $cleaner;" ^
  "  } else {" ^
  "    Write-Host \"[$time] OK: RAM usage at $pct% ($used / $total MB)\" -ForegroundColor Green;" ^
  "  }" ^
  "  Start-Sleep -Seconds 10;" ^
  "}"
pause
exit /b

:: ============================================================================
:: OPTION P: PRO / PAID OPTIMIZER TWEAKS
:: ============================================================================
:MENU_PRO_TWEAKS
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_YELLOW%  PRO / PAID OPTIMIZER TWEAKS (ESPORTS & ENTHUSIAST)%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   Advanced tweaks used in paid software (Hone, Process Lasso, ReviOS, FilterKeys):
echo.
echo   [1] BCD Low-Latency Timer Tweaks (Disable Dynamic Tick, Invariant TSC)
echo   [2] CPU Quantum & Core Unparking (Win32PrioritySeparation 0x26 + 100%% Unpark)
echo   [3] Input Latency & Peripherals (Raw 1:1 Mouse, FilterKeys 150/25, USB Sleep Off)
echo   [4] Disable Nagle's Algorithm & TCP Delayed ACK on All Network Adapters
echo   [5] Deep GPU Shader Cache Cleaner (DirectX, NVIDIA, AMD, Intel)
echo   [6] NTFS File System & SSD Throughput Boost (Disable 8.3 & LastAccess)
echo   [7] Ultra-Fast Snappy Visual Effects (Instant UI + Smooth ClearType Fonts)
echo   [8] Apply All PRO Tweaks in One Click
echo   [B] Back to Main Menu
echo.
set /p "PRO_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%PRO_CHOICE%"=="B" goto MAIN_MENU
if "%PRO_CHOICE%"=="1" (
    call :DO_PRO_BCD
    pause & goto MENU_PRO_TWEAKS
)
if "%PRO_CHOICE%"=="2" (
    call :DO_PRO_CPU_UNPARK
    pause & goto MENU_PRO_TWEAKS
)
if "%PRO_CHOICE%"=="3" (
    call :DO_PRO_INPUT_LAG
    pause & goto MENU_PRO_TWEAKS
)
if "%PRO_CHOICE%"=="4" (
    call :DO_PRO_NAGLE
    pause & goto MENU_PRO_TWEAKS
)
if "%PRO_CHOICE%"=="5" (
    call :DO_PRO_SHADER_CLEAN
    pause & goto MENU_PRO_TWEAKS
)
if "%PRO_CHOICE%"=="6" (
    call :DO_PRO_NTFS
    pause & goto MENU_PRO_TWEAKS
)
if "%PRO_CHOICE%"=="7" (
    call :DO_PRO_VISUAL_FX
    pause & goto MENU_PRO_TWEAKS
)
if "%PRO_CHOICE%"=="8" (
    call :DO_ALL_PRO_TWEAKS
    pause & goto MENU_PRO_TWEAKS
)
goto MENU_PRO_TWEAKS

:DO_ALL_PRO_TWEAKS
echo.
echo %C_CYAN%[*] Applying complete PRO / Paid Optimization suite...%C_RESET%
call :DO_PRO_BCD
call :DO_PRO_CPU_UNPARK
call :DO_PRO_INPUT_LAG
call :DO_PRO_NAGLE
call :DO_PRO_SHADER_CLEAN
call :DO_PRO_NTFS
call :DO_PRO_VISUAL_FX
echo.
echo %C_GREEN%[+] All PRO optimizations applied successfully!%C_RESET%
echo [%date% %time%] All PRO tweaks applied >> "%LOG_FILE%"
exit /b

:DO_PRO_BCD
echo %C_CYAN%[*] Applying BCD low-latency timer and boot optimizations...%C_RESET%
bcdedit /set useplatformclock no >nul 2>&1
bcdedit /set disabledynamictick yes >nul 2>&1
bcdedit /set tscsyncpolicy enhanced >nul 2>&1
bcdedit /set bootux disabled >nul 2>&1
echo %C_GREEN%[+] BCD timers tweaked: Dynamic tick disabled, Invariant TSC enhanced.%C_RESET%
echo [%date% %time%] BCD tweaks applied >> "%LOG_FILE%"
exit /b

:DO_PRO_CPU_UNPARK
echo %C_CYAN%[*] Tuning CPU Quantum Priority and Unparking all cores...%C_RESET%
:: Win32PrioritySeparation 38 (0x26): Short quantum, variable, maximum foreground burst
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f >nul 2>&1
:: Unpark all CPU cores
powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100 >nul 2>&1
powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100 >nul 2>&1
powercfg -setactive scheme_current >nul 2>&1
echo %C_GREEN%[+] Win32PrioritySeparation set to 0x26 (Dec 38). All CPU cores unparked to 100%%.%C_RESET%
echo [%date% %time%] CPU quantum and unparking applied >> "%LOG_FILE%"
exit /b

:DO_PRO_INPUT_LAG
echo %C_CYAN%[*] Optimizing Mouse, Keyboard, and USB Input Latency...%C_RESET%
:: Mouse 1:1 Raw Input (zero Windows pointer acceleration)
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f >nul 2>&1
:: FilterKeys low delay repeat (fastest keypress registration for FPS/Fortnite/Rhythm)
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "59" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "150" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "25" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "250" /f >nul 2>&1
:: Disable USB Selective Suspend (prevents USB input devices from sleeping)
powercfg -setacvalueindex scheme_current 2a737441-1930-4402-86ee-b63990422d3b 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
powercfg -setactive scheme_current >nul 2>&1
echo %C_GREEN%[+] Mouse raw 1:1 input active, FilterKeys 150/25 set, USB sleeping disabled.%C_RESET%
echo [%date% %time%] Input lag tweaks applied >> "%LOG_FILE%"
exit /b

:DO_PRO_NAGLE
echo %C_CYAN%[*] Disabling Nagle's Algorithm and TCP Delayed ACK across all network interfaces...%C_RESET%
powershell -NoProfile -Command "foreach ($i in (Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces')) { Set-ItemProperty -Path $i.PSPath -Name TcpAckFrequency -Value 1 -Type DWord -ErrorAction SilentlyContinue; Set-ItemProperty -Path $i.PSPath -Name TCPNoDelay -Value 1 -Type DWord -ErrorAction SilentlyContinue; Set-ItemProperty -Path $i.PSPath -Name TcpDelAckTicks -Value 0 -Type DWord -ErrorAction SilentlyContinue }" >nul 2>&1
echo %C_GREEN%[+] Nagle's algorithm disabled, TCPNoDelay enabled (eliminates 200ms ACK delay).%C_RESET%
echo [%date% %time%] Nagle's algorithm disabled >> "%LOG_FILE%"
exit /b

:DO_PRO_SHADER_CLEAN
echo %C_CYAN%[*] Purging GPU DirectX, NVIDIA, AMD, and Intel Shader Caches...%C_RESET%
:: DirectX Shader Cache
del /s /f /q "%LOCALAPPDATA%\D3DSCache\*.*" >nul 2>&1
for /d %%x in ("%LOCALAPPDATA%\D3DSCache\*") do rmdir /s /q "%%x" >nul 2>&1
:: NVIDIA Shader Cache
del /s /f /q "%LOCALAPPDATA%\NVIDIA\DXCache\*.*" >nul 2>&1
del /s /f /q "%LOCALAPPDATA%\NVIDIA\GLCache\*.*" >nul 2>&1
for /d %%x in ("%LOCALAPPDATA%\NVIDIA\DXCache\*") do rmdir /s /q "%%x" >nul 2>&1
for /d %%x in ("%LOCALAPPDATA%\NVIDIA\GLCache\*") do rmdir /s /q "%%x" >nul 2>&1
:: AMD Shader Cache
del /s /f /q "%LOCALAPPDATA%\AMD\DxCache\*.*" >nul 2>&1
del /s /f /q "%LOCALAPPDATA%\AMD\GLCache\*.*" >nul 2>&1
for /d %%x in ("%LOCALAPPDATA%\AMD\DxCache\*") do rmdir /s /q "%%x" >nul 2>&1
for /d %%x in ("%LOCALAPPDATA%\AMD\GLCache\*") do rmdir /s /q "%%x" >nul 2>&1
:: Intel Graphics Cache
del /s /f /q "%LOCALAPPDATA%\Intel\ShaderCache\*.*" >nul 2>&1
for /d %%x in ("%LOCALAPPDATA%\Intel\ShaderCache\*") do rmdir /s /q "%%x" >nul 2>&1
echo %C_GREEN%[+] GPU shader caches purged. Fixes FPS drops and game stutters.%C_RESET%
echo [%date% %time%] Shader caches purged >> "%LOG_FILE%"
exit /b

:DO_PRO_NTFS
echo %C_CYAN%[*] Boosting NTFS file system and SSD/NVMe throughput...%C_RESET%
fsutil behavior set disable8dot3 1 >nul 2>&1
fsutil behavior set disablelastaccess 1 >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d 2 /f >nul 2>&1
echo %C_GREEN%[+] 8.3 short names disabled, last access timestamps off, NTFS buffer expanded.%C_RESET%
echo [%date% %time%] NTFS throughput boosted >> "%LOG_FILE%"
exit /b

:DO_PRO_VISUAL_FX
echo %C_CYAN%[*] Tuning Windows Visual Effects for ultra-snappy responsiveness...%C_RESET%
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d "2" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothingType" /t REG_DWORD /d 2 /f >nul 2>&1
echo %C_GREEN%[+] Slow UI animations disabled, font smoothing (ClearType) preserved.%C_RESET%
echo [%date% %time%] Visual effects tuned >> "%LOG_FILE%"
exit /b

:: ============================================================================
:: OPTION 2: PERFORMANCE AND GAMING LATENCY
:: ============================================================================
:MENU_PERFORMANCE
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_CYAN%  PERFORMANCE AND GAMING LATENCY TWEAKS%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   [1] Enable Ultimate / High Performance Power Plan
echo   [2] Optimize System Responsiveness and Multimedia Scheduling
echo   [3] Enable Game Mode and Hardware-Accelerated GPU Scheduling (HAGS)
echo   [4] Disable Background Apps and Startup Delays
echo   [5] Disable GameDVR Background Capture (Reduces Input Lag)
echo   [6] Apply All Performance Tweaks
echo   [B] Back to Main Menu
echo.
set /p "P_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%P_CHOICE%"=="B" goto MAIN_MENU
if "%P_CHOICE%"=="1" (
    call :PERF_POWER
    pause & goto MENU_PERFORMANCE
)
if "%P_CHOICE%"=="2" (
    call :PERF_RESPONSIVENESS
    pause & goto MENU_PERFORMANCE
)
if "%P_CHOICE%"=="3" (
    call :PERF_GAMEMODE
    pause & goto MENU_PERFORMANCE
)
if "%P_CHOICE%"=="4" (
    call :PERF_STARTUP
    pause & goto MENU_PERFORMANCE
)
if "%P_CHOICE%"=="5" (
    call :PERF_FSO
    pause & goto MENU_PERFORMANCE
)
if "%P_CHOICE%"=="6" (
    call :DO_PERFORMANCE_TWEAKS
    pause & goto MENU_PERFORMANCE
)
goto MENU_PERFORMANCE

:DO_PERFORMANCE_TWEAKS
call :PERF_POWER
call :PERF_RESPONSIVENESS
call :PERF_GAMEMODE
call :PERF_STARTUP
call :PERF_FSO
exit /b

:PERF_POWER
echo %C_CYAN%[*] Configuring Ultimate/High Performance Power Plan...%C_RESET%
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
if %errorlevel% neq 0 (
    powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    echo %C_GREEN%[+] High Performance plan activated.%C_RESET%
) else (
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
    echo %C_GREEN%[+] Ultimate Performance plan activated.%C_RESET%
)
powercfg -h off >nul 2>&1
echo %C_GREEN%[+] Hibernation disabled (Reclaimed storage from C:\).%C_RESET%
echo [%date% %time%] Power tweaks applied >> "%LOG_FILE%"
exit /b

:PERF_RESPONSIVENESS
echo %C_CYAN%[*] Tuning System Responsiveness and MMSystem priority...%C_RESET%
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "10" /f >nul 2>&1
echo %C_GREEN%[+] System responsiveness and gaming priority set to max.%C_RESET%
echo [%date% %time%] Gaming responsiveness tweaked >> "%LOG_FILE%"
exit /b

:PERF_GAMEMODE
echo %C_CYAN%[*] Optimizing Game Mode and HAGS...%C_RESET%
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
echo %C_GREEN%[+] Windows Game Mode enabled and HAGS configured.%C_RESET%
exit /b

:PERF_STARTUP
echo %C_CYAN%[*] Eliminating Startup Delay...%C_RESET%
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo %C_GREEN%[+] Startup application delay removed.%C_RESET%
exit /b

:PERF_FSO
echo %C_CYAN%[*] Configuring Game Bar and DVR capture...%C_RESET%
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
echo %C_GREEN%[+] Background GameDVR capture disabled (Reduces input lag).%C_RESET%
exit /b

:: ============================================================================
:: OPTION 3: PRIVACY AND TELEMETRY DEBLOAT
:: ============================================================================
:MENU_PRIVACY
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_MAGENTA%  PRIVACY AND TELEMETRY DEBLOAT%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   [1] Disable Windows Telemetry and Diagnostic Data (DiagTrack)
echo   [2] Disable Advertising ID and Targeted Suggestions
echo   [3] Disable Cortana and Bing Search from Start Menu
echo   [4] Disable Windows Activity History and Timeline
echo   [5] Disable Feedback Hub Prompts and Error Reporting
echo   [6] Apply All Privacy and Anti-Telemetry Tweaks
echo   [B] Back to Main Menu
echo.
set /p "PR_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%PR_CHOICE%"=="B" goto MAIN_MENU
if "%PR_CHOICE%"=="1" (
    call :PRIVACY_TELEMETRY
    pause & goto MENU_PRIVACY
)
if "%PR_CHOICE%"=="2" (
    call :PRIVACY_ADS
    pause & goto MENU_PRIVACY
)
if "%PR_CHOICE%"=="3" (
    call :PRIVACY_BING_CORTANA
    pause & goto MENU_PRIVACY
)
if "%PR_CHOICE%"=="4" (
    call :PRIVACY_TIMELINE
    pause & goto MENU_PRIVACY
)
if "%PR_CHOICE%"=="5" (
    call :PRIVACY_FEEDBACK
    pause & goto MENU_PRIVACY
)
if "%PR_CHOICE%"=="6" (
    call :DO_PRIVACY_TWEAKS
    pause & goto MENU_PRIVACY
)
goto MENU_PRIVACY

:DO_PRIVACY_TWEAKS
call :PRIVACY_TELEMETRY
call :PRIVACY_ADS
call :PRIVACY_BING_CORTANA
call :PRIVACY_TIMELINE
call :PRIVACY_FEEDBACK
exit /b

:PRIVACY_TELEMETRY
echo %C_CYAN%[*] Disabling Diagnostic Telemetry (DiagTrack / dmwappushservice)...%C_RESET%
sc config DiagTrack start=disabled >nul 2>&1
sc stop DiagTrack >nul 2>&1
sc config dmwappushservice start=disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MaxTelemetryAllowed" /t REG_DWORD /d 0 /f >nul 2>&1
echo %C_GREEN%[+] Diagnostic tracking services and telemetry disabled.%C_RESET%
echo [%date% %time%] Telemetry disabled >> "%LOG_FILE%"
exit /b

:PRIVACY_ADS
echo %C_CYAN%[*] Disabling Advertising ID and tailored experiences...%C_RESET%
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo %C_GREEN%[+] Targeted advertising and consumer suggestions disabled.%C_RESET%
exit /b

:PRIVACY_BING_CORTANA
echo %C_CYAN%[*] Disabling Cortana and Bing Search integration in Start Menu...%C_RESET%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d 0 /f >nul 2>&1
echo %C_GREEN%[+] Bing Start Menu search and Cortana disabled.%C_RESET%
exit /b

:PRIVACY_TIMELINE
echo %C_CYAN%[*] Disabling Windows Activity History and Timeline sync...%C_RESET%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
echo %C_GREEN%[+] Activity History tracking disabled.%C_RESET%
exit /b

:PRIVACY_FEEDBACK
echo %C_CYAN%[*] Disabling Feedback notifications and Error Reporting...%C_RESET%
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo %C_GREEN%[+] Feedback Hub popups and Windows Error Reporting silenced.%C_RESET%
exit /b

:: ============================================================================
:: OPTION 4: DEEP DISK AND CACHE CLEANER
:: ============================================================================
:MENU_DISK_CLEAN
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_YELLOW%  DEEP DISK AND CACHE CLEANER%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   [1] Clean User and System Temp Folders
echo   [2] Clean Windows Update Download Cache (SoftwareDistribution)
echo   [3] Flush DNS Cache and Network Resolution Cache
echo   [4] Clean Windows Prefetch Cache
echo   [5] Clean Thumbnail Cache and Crash Dumps
echo   [6] Empty Recycle Bin (All Drives)
echo   [7] Run Windows Component Store Cleanup (DISM StartComponentCleanup)
echo   [8] Perform Complete Deep Clean (All of the above)
echo   [B] Back to Main Menu
echo.
set /p "D_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%D_CHOICE%"=="B" goto MAIN_MENU
if "%D_CHOICE%"=="1" (
    call :CLEAN_TEMP
    pause & goto MENU_DISK_CLEAN
)
if "%D_CHOICE%"=="2" (
    call :CLEAN_UPDATE_CACHE
    pause & goto MENU_DISK_CLEAN
)
if "%D_CHOICE%"=="3" (
    call :CLEAN_DNS
    pause & goto MENU_DISK_CLEAN
)
if "%D_CHOICE%"=="4" (
    call :CLEAN_PREFETCH
    pause & goto MENU_DISK_CLEAN
)
if "%D_CHOICE%"=="5" (
    call :CLEAN_THUMB_DUMP
    pause & goto MENU_DISK_CLEAN
)
if "%D_CHOICE%"=="6" (
    call :CLEAN_RECYCLE
    pause & goto MENU_DISK_CLEAN
)
if "%D_CHOICE%"=="7" (
    call :CLEAN_DISM_STORE
    pause & goto MENU_DISK_CLEAN
)
if "%D_CHOICE%"=="8" (
    call :DO_DISK_CLEANUP
    pause & goto MENU_DISK_CLEAN
)
goto MENU_DISK_CLEAN

:DO_DISK_CLEANUP
call :CLEAN_TEMP
call :CLEAN_UPDATE_CACHE
call :CLEAN_DNS
call :CLEAN_PREFETCH
call :CLEAN_THUMB_DUMP
call :CLEAN_RECYCLE
call :CLEAN_DISM_STORE
exit /b

:CLEAN_TEMP
echo %C_CYAN%[*] Cleaning User and System Temporary Directories...%C_RESET%
del /s /f /q "%TEMP%\*.*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rmdir /s /q "%%x" >nul 2>&1
del /s /f /q "%SystemRoot%\Temp\*.*" >nul 2>&1
for /d %%x in ("%SystemRoot%\Temp\*") do rmdir /s /q "%%x" >nul 2>&1
echo %C_GREEN%[+] Temporary directories cleaned.%C_RESET%
exit /b

:CLEAN_UPDATE_CACHE
echo %C_CYAN%[*] Clearing Windows Update Download Cache...%C_RESET%
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /s /f /q "%SystemRoot%\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%x in ("%SystemRoot%\SoftwareDistribution\Download\*") do rmdir /s /q "%%x" >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
echo %C_GREEN%[+] Windows Update cache cleared.%C_RESET%
exit /b

:CLEAN_DNS
echo %C_CYAN%[*] Flushing DNS Resolver Cache...%C_RESET%
ipconfig /flushdns >nul 2>&1
echo %C_GREEN%[+] DNS cache flushed successfully.%C_RESET%
exit /b

:CLEAN_PREFETCH
echo %C_CYAN%[*] Cleaning Windows Prefetch folder...%C_RESET%
del /s /f /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
echo %C_GREEN%[+] Prefetch folder purged.%C_RESET%
exit /b

:CLEAN_THUMB_DUMP
echo %C_CYAN%[*] Cleaning Memory Dumps and Error Logs...%C_RESET%
del /s /f /q "%SystemRoot%\MEMORY.DMP" >nul 2>&1
del /s /f /q "%SystemRoot%\Minidump\*.*" >nul 2>&1
del /s /f /q "%LOCALAPPDATA%\CrashDumps\*.*" >nul 2>&1
del /s /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo %C_GREEN%[+] Crash dumps and thumbnail caches purged.%C_RESET%
exit /b

:CLEAN_RECYCLE
echo %C_CYAN%[*] Emptying Recycle Bin...%C_RESET%
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo %C_GREEN%[+] Recycle bin emptied.%C_RESET%
exit /b

:CLEAN_DISM_STORE
echo %C_CYAN%[*] Cleaning Windows Component Store (DISM)...%C_RESET%
echo %C_YELLOW%    Compressing superseded components (takes 1-2 mins)...%C_RESET%
dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
if %errorlevel% equ 0 (
    echo %C_GREEN%[+] Component Store cleaned successfully.%C_RESET%
) else (
    echo %C_YELLOW%[!] DISM Component cleanup completed.%C_RESET%
)
exit /b

:: ============================================================================
:: OPTION 5: NETWORK AND TCP LATENCY TUNING
:: ============================================================================
:MENU_NETWORK
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_BLUE%  NETWORK AND TCP LATENCY TUNING%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   [1] Enable Compound TCP (CTCP) Congestion Provider
echo   [2] Enable TCP Window Auto-Tuning (Normal)
echo   [3] Disable Network Throttling Index for Gaming
echo   [4] Enable Direct Cache Access (DCA) and ECN
echo   [5] Reset Winsock and TCP/IP Stack to Defaults
echo   [6] Apply All Recommended Network Optimizations
echo   [B] Back to Main Menu
echo.
set /p "N_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%N_CHOICE%"=="B" goto MAIN_MENU
if "%N_CHOICE%"=="1" (
    call :NET_CONGESTION
    pause & goto MENU_NETWORK
)
if "%N_CHOICE%"=="2" (
    call :NET_AUTOTUNING
    pause & goto MENU_NETWORK
)
if "%N_CHOICE%"=="3" (
    call :NET_THROTTLING
    pause & goto MENU_NETWORK
)
if "%N_CHOICE%"=="4" (
    call :NET_DMA_DCA
    pause & goto MENU_NETWORK
)
if "%N_CHOICE%"=="5" (
    call :NET_RESET
    pause & goto MENU_NETWORK
)
if "%N_CHOICE%"=="6" (
    call :DO_NETWORK_TWEAKS
    pause & goto MENU_NETWORK
)
goto MENU_NETWORK

:DO_NETWORK_TWEAKS
call :NET_CONGESTION
call :NET_AUTOTUNING
call :NET_THROTTLING
call :NET_DMA_DCA
exit /b

:NET_CONGESTION
echo %C_CYAN%[*] Setting optimal TCP congestion provider (CTCP)...%C_RESET%
netsh int tcp set supplemental template=custom congestionprovider=ctcp >nul 2>&1
netsh int tcp set supplemental template=internet congestionprovider=ctcp >nul 2>&1
echo %C_GREEN%[+] Compound TCP Congestion Provider enabled.%C_RESET%
exit /b

:NET_AUTOTUNING
echo %C_CYAN%[*] Enabling TCP Window Auto-Tuning level=normal...%C_RESET%
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global chimney=disabled >nul 2>&1
netsh int tcp set global rsc=disabled >nul 2>&1
echo %C_GREEN%[+] TCP Auto-Tuning and RSS enabled, RSC disabled (minimizes ping jitter).%C_RESET%
exit /b

:NET_THROTTLING
echo %C_CYAN%[*] Disabling Windows Network Throttling...%C_RESET%
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
echo %C_GREEN%[+] Network packet throttling disabled for smooth online gaming.%C_RESET%
exit /b

:NET_DMA_DCA
echo %C_CYAN%[*] Enabling Direct Cache Access (DCA) and ECN Capability...%C_RESET%
netsh int tcp set global dca=enabled >nul 2>&1
netsh int tcp set global ecncapability=enabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
echo %C_GREEN%[+] Direct Cache Access enabled and TCP timestamps disabled.%C_RESET%
exit /b

:NET_RESET
echo %C_CYAN%[*] Resetting Winsock Catalog and TCP/IP Stack...%C_RESET%
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo %C_GREEN%[+] Winsock and TCP/IP reset. Reboot will be required.%C_RESET%
exit /b

:: ============================================================================
:: OPTION 6: WINDOWS SERVICES TUNING
:: ============================================================================
:MENU_SERVICES
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_CYAN%  WINDOWS SERVICES TUNING%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   Safely disables background services that consume RAM and CPU cycles:
echo    - Remote Registry (Security risk and background drain)
echo    - Downloaded Maps Manager (Offline maps sync)
echo    - Retail Demo Service
echo    - Windows Insider Service
echo    - Xbox Background Services (Optional)
echo.
echo   [1] Apply Safe Service Optimizations (Retains all essential features)
echo   [2] Disable Xbox Live Background Services (For non-Xbox users)
echo   [3] Restore Default Windows Service Configurations
echo   [B] Back to Main Menu
echo.
set /p "S_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%S_CHOICE%"=="B" goto MAIN_MENU
if "%S_CHOICE%"=="1" (
    call :DO_SERVICES_TWEAKS
    pause & goto MENU_SERVICES
)
if "%S_CHOICE%"=="2" (
    call :DISABLE_XBOX_SERVICES
    pause & goto MENU_SERVICES
)
if "%S_CHOICE%"=="3" (
    call :RESTORE_SERVICES
    pause & goto MENU_SERVICES
)
goto MENU_SERVICES

:DO_SERVICES_TWEAKS
echo %C_CYAN%[*] Optimizing non-essential background services...%C_RESET%
sc stop RemoteRegistry >nul 2>&1
sc config RemoteRegistry start=disabled >nul 2>&1
sc stop MapsBroker >nul 2>&1
sc config MapsBroker start=disabled >nul 2>&1
sc stop RetailDemo >nul 2>&1
sc config RetailDemo start=disabled >nul 2>&1
sc stop wisvc >nul 2>&1
sc config wisvc start=disabled >nul 2>&1
sc stop TrkWks >nul 2>&1
sc config TrkWks start=demand >nul 2>&1
sc stop lfsvc >nul 2>&1
sc config lfsvc start=demand >nul 2>&1

echo %C_GREEN%[+] Safe background services tuned.%C_RESET%
echo [%date% %time%] Background services tuned >> "%LOG_FILE%"
exit /b

:DISABLE_XBOX_SERVICES
echo %C_CYAN%[*] Disabling Xbox Background Services...%C_RESET%
sc stop XblAuthManager >nul 2>&1
sc config XblAuthManager start=disabled >nul 2>&1
sc stop XblGameSave >nul 2>&1
sc config XblGameSave start=disabled >nul 2>&1
sc stop XboxNetApiSvc >nul 2>&1
sc config XboxNetApiSvc start=disabled >nul 2>&1
sc stop XboxGipSvc >nul 2>&1
sc config XboxGipSvc start=disabled >nul 2>&1
echo %C_GREEN%[+] Xbox services disabled.%C_RESET%
exit /b

:RESTORE_SERVICES
echo %C_CYAN%[*] Restoring default service startup types...%C_RESET%
sc config RemoteRegistry start=demand >nul 2>&1
sc config MapsBroker start=auto >nul 2>&1
sc config RetailDemo start=demand >nul 2>&1
sc config wisvc start=demand >nul 2>&1
sc config TrkWks start=auto >nul 2>&1
sc config lfsvc start=demand >nul 2>&1
sc config XblAuthManager start=demand >nul 2>&1
sc config XblGameSave start=demand >nul 2>&1
sc config XboxNetApiSvc start=demand >nul 2>&1
sc config XboxGipSvc start=demand >nul 2>&1
sc config DiagTrack start=auto >nul 2>&1
echo %C_GREEN%[+] Core services set back to defaults.%C_RESET%
exit /b

:: ============================================================================
:: OPTION 7: REMOVE BLOATWARE / UWP APPS
:: ============================================================================
:MENU_BLOATWARE
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_RED%  REMOVE PRE-INSTALLED UWP BLOATWARE%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   This safely removes pre-installed sponsored and unnecessary apps:
echo    - 3D Builder / Print3D
echo    - Bing Weather, News, Finance, Sports
echo    - Feedback Hub, Get Help, Tips
echo    - Solitaire Collection
echo    - Skype and Zune Video
echo    (Keeps: Microsoft Store, Calculator, Notepad, Photos, Paint)
echo.
echo   [1] Remove Consumer Bloatware (Safe list)
echo   [2] Remove OneDrive (Deep uninstall)
echo   [B] Back to Main Menu
echo.
set /p "B_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%B_CHOICE%"=="B" goto MAIN_MENU
if "%B_CHOICE%"=="1" (
    call :REMOVE_APPX_BLOAT
    pause & goto MENU_BLOATWARE
)
if "%B_CHOICE%"=="2" (
    call :UNINSTALL_ONEDRIVE
    pause & goto MENU_BLOATWARE
)
goto MENU_BLOATWARE

:REMOVE_APPX_BLOAT
echo %C_CYAN%[*] Removing UWP junk packages (This may take a moment)...%C_RESET%
powershell -NoProfile -Command "$apps = @('Microsoft.BingNews','Microsoft.BingWeather','Microsoft.BingFinance','Microsoft.BingSports','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.MicrosoftFeedbackHub','Microsoft.MicrosoftSolitaireCollection','Microsoft.Microsoft3DViewer','Microsoft.Print3D','Microsoft.SkypeApp','Microsoft.ZuneVideo','Microsoft.YourPhone'); foreach ($app in $apps) { Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -eq $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue }"
echo %C_GREEN%[+] UWP bloatware removed for all users.%C_RESET%
echo [%date% %time%] UWP bloatware removed >> "%LOG_FILE%"
exit /b

:UNINSTALL_ONEDRIVE
echo %C_YELLOW%[!] Warning: This will completely remove OneDrive and stop file syncing.%C_RESET%
set /p "CONFIRM_OD=Are you sure you want to remove OneDrive? [Y/N]: "
if /i not "%CONFIRM_OD%"=="Y" exit /b
echo %C_CYAN%[*] Terminating OneDrive process...%C_RESET%
taskkill /f /im OneDrive.exe >nul 2>&1
echo %C_CYAN%[*] Uninstalling OneDrive...%C_RESET%
if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall >nul 2>&1
)
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
    "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall >nul 2>&1
)
rmdir /s /q "%UserProfile%\OneDrive" >nul 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\OneDrive" >nul 2>&1
rmdir /s /q "%ProgramData%\Microsoft OneDrive" >nul 2>&1
echo %C_GREEN%[+] OneDrive removed.%C_RESET%
exit /b

:: ============================================================================
:: OPTION 8: SYSTEM HEALTH AND REPAIR
:: ============================================================================
:MENU_REPAIR
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_WHITE%  SYSTEM HEALTH AND INTEGRITY REPAIR%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   [1] Run SFC Scan (System File Checker)
echo   [2] Run DISM /CheckHealth and /ScanHealth
echo   [3] Run DISM /RestoreHealth (Fix corrupted system images)
echo   [4] Schedule CHKDSK on Next Restart
echo   [5] Perform Complete Auto Repair (SFC + DISM)
echo   [B] Back to Main Menu
echo.
set /p "H_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%H_CHOICE%"=="B" goto MAIN_MENU
if "%H_CHOICE%"=="1" (
    sfc /scannow
    pause & goto MENU_REPAIR
)
if "%H_CHOICE%"=="2" (
    dism /Online /Cleanup-Image /ScanHealth
    pause & goto MENU_REPAIR
)
if "%H_CHOICE%"=="3" (
    dism /Online /Cleanup-Image /RestoreHealth
    pause & goto MENU_REPAIR
)
if "%H_CHOICE%"=="4" (
    chkdsk C: /f /r
    pause & goto MENU_REPAIR
)
if "%H_CHOICE%"=="5" (
    echo %C_CYAN%[*] Running DISM RestoreHealth...%C_RESET%
    dism /Online /Cleanup-Image /RestoreHealth
    echo %C_CYAN%[*] Running SFC Scannow...%C_RESET%
    sfc /scannow
    pause & goto MENU_REPAIR
)
goto MENU_REPAIR

:: ============================================================================
:: OPTION 9: RESTORE POINT
:: ============================================================================
:MENU_RESTORE_POINT
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_GREEN%  CREATE SYSTEM RESTORE POINT%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   This will capture a snapshot of your system configuration.
echo.
set /p "CONFIRM_RP=%C_YELLOW%  Are you sure you want to create a System Restore Point now? [Y/N]: %C_RESET%"
if /i not "%CONFIRM_RP%"=="Y" (
    echo %C_GRAY%  [*] Restore Point creation cancelled.%C_RESET%
    timeout /t 1 >nul
    goto MAIN_MENU
)
echo.
call :DO_RESTORE_POINT
pause
goto MAIN_MENU

:DO_RESTORE_POINT
echo %C_CYAN%[*] Checking System Protection status...%C_RESET%
powershell -NoProfile -Command "Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue" >nul 2>&1
echo %C_CYAN%[*] Creating System Restore Point 'Pre-Optimization'...%C_RESET%
powershell -NoProfile -Command "Checkpoint-Computer -Description 'Pre-Optimization-Snapshot' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue" >nul 2>&1
if %errorlevel% equ 0 (
    echo %C_GREEN%[+] System Restore Point successfully created!%C_RESET%
) else (
    echo %C_YELLOW%[!] Note: System Protection must be enabled on drive C: to create snapshots.%C_RESET%
)
echo [%date% %time%] Restore point creation initiated >> "%LOG_FILE%"
exit /b

:: ============================================================================
:: OPTION R: REVERT AND RESET SETTINGS
:: ============================================================================
:MENU_REVERT
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_YELLOW%  REVERT AND RESET SETTINGS TO DEFAULTS%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo   [1] Restore Balanced Power Plan
echo   [2] Re-enable Default Background Services
echo   [3] Restore Default System Responsiveness and Network Throttling
echo   [4] Re-enable Telemetry and Advertising ID
echo   [5] Restore Default BCD Timer and Dynamic Tick Settings
echo   [6] Restore Default Mouse and Keyboard Input Settings
echo   [7] Revert All Settings to Baseline Defaults
echo   [B] Back to Main Menu
echo.
set /p "REV_CHOICE=%C_YELLOW%  Select option: %C_RESET%"
if /i "%REV_CHOICE%"=="B" goto MAIN_MENU
if "%REV_CHOICE%"=="1" (
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
    echo %C_GREEN%[+] Balanced power plan restored.%C_RESET%
    pause & goto MENU_REVERT
)
if "%REV_CHOICE%"=="2" (
    call :RESTORE_SERVICES
    pause & goto MENU_REVERT
)
if "%REV_CHOICE%"=="3" (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 2 /f >nul 2>&1
    echo %C_GREEN%[+] Responsiveness, Network throttling, and CPU quantum restored.%C_RESET%
    pause & goto MENU_REVERT
)
if "%REV_CHOICE%"=="4" (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo %C_GREEN%[+] Telemetry and Advertising ID re-enabled.%C_RESET%
    pause & goto MENU_REVERT
)
if "%REV_CHOICE%"=="5" (
    bcdedit /deletevalue useplatformclock >nul 2>&1
    bcdedit /deletevalue disabledynamictick >nul 2>&1
    bcdedit /deletevalue tscsyncpolicy >nul 2>&1
    bcdedit /deletevalue bootux >nul 2>&1
    echo %C_GREEN%[+] BCD timers and boot settings restored to Windows defaults.%C_RESET%
    pause & goto MENU_REVERT
)
if "%REV_CHOICE%"=="6" (
    reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "6" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "10" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "126" /f >nul 2>&1
    echo %C_GREEN%[+] Mouse and keyboard input response restored to defaults.%C_RESET%
    pause & goto MENU_REVERT
)
if "%REV_CHOICE%"=="7" (
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
    call :RESTORE_SERVICES
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
    bcdedit /deletevalue useplatformclock >nul 2>&1
    bcdedit /deletevalue disabledynamictick >nul 2>&1
    bcdedit /deletevalue tscsyncpolicy >nul 2>&1
    bcdedit /deletevalue bootux >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "126" /f >nul 2>&1
    echo %C_GREEN%[+] All settings restored to Windows baseline defaults.%C_RESET%
    pause & goto MENU_REVERT
)
goto MENU_REVERT

:: ============================================================================
:: OPTION L: VIEW LOG
:: ============================================================================
:VIEW_LOG
cls
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_WHITE%  OPTIMIZER ACTIVITY LOG%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
if exist "%LOG_FILE%" (
    type "%LOG_FILE%"
) else (
    echo No log file found.
)
echo.
pause
goto MAIN_MENU

:: ============================================================================
:: EXIT
:: ============================================================================
:EXIT_SCRIPT
cls
echo.
echo %C_CYAN%========================================================================%C_RESET%
echo %C_BOLD%%C_GREEN%  Thank you for using KAISER Windows Optimizer!%C_RESET%
echo %C_YELLOW%  Tip: If you applied major tweaks, restart your PC to allow changes to settle.%C_RESET%
echo %C_CYAN%========================================================================%C_RESET%
echo.
timeout /t 2 >nul
exit /b 0
