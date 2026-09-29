# ⚡ KAISER - Windows 10 & 11 Advanced CMD Optimizer

A high-performance, modular, and safe Command-Line (CMD) Optimizer engineered specifically for **Windows 10** and **Windows 11** (Home, Pro, Enterprise). 

It features an interactive ANSI-colored terminal dashboard, safety-first restore point prompting, and command-line flags for automated script execution. Includes advanced esports-grade tweaks found in commercial paid optimization tools.

---

## 🚀 Quick Start

### 1. Standalone Executable: `KAISER.exe` (Recommended)
You can directly double-click **`KAISER.exe`**!
- It is a single, self-contained standalone binary with built-in administrator UAC elevation.
- Supports both interactive console dashboard and all CLI flags:
  ```cmd
  KAISER.exe /pro
  KAISER.exe /ram
  KAISER.exe /quick
  KAISER.exe /help
  ```

### 2. Building / Recompiling the EXE: `Build-Exe.bat`
If you ever edit or customize `Optimizer.bat`, `MemoryCleaner.ps1`, or `banner.txt`, simply run:
```cmd
Build-Exe.bat
```
It uses the built-in Windows .NET C# compiler (`csc.exe`) to automatically re-compile and bundle everything into a fresh `KAISER.exe` without needing any external tools.

### 3. Running as Script: `Optimizer.bat`
Alternatively, you can run the raw batch script directly:
- Right-click on **`Optimizer.bat`** and select **Run as administrator** (or double-click it; it will prompt for UAC).

```cmd
:: Apply all Paid / Pro tweaks in one command
Optimizer.bat /pro

:: Instantly trim process working sets and purge standby RAM cache
Optimizer.bat /ram

:: Disable Nagle's Algorithm and TCP Delayed ACK for gaming
Optimizer.bat /nagle

:: Optimize Mouse 1:1 raw input, FilterKeys 150/25, and USB sleeping
Optimizer.bat /input

:: Unpark all CPU cores and set Win32PrioritySeparation to 0x26
Optimizer.bat /unpark

:: Apply BCD low-latency timer & boot optimizations
Optimizer.bat /bcd

:: Purge GPU DirectX, NVIDIA, AMD, and Intel shader caches
Optimizer.bat /shader

:: Boost NTFS file system throughput and disable 8.3 short names
Optimizer.bat /fs

:: Run the complete recommended optimization pipeline (includes RAM clean)
Optimizer.bat /quick

:: Purge temporary files, update caches, and flush DNS
Optimizer.bat /clean

:: Apply general gaming and GPU scheduling tweaks
Optimizer.bat /perf

:: Disable telemetry, diagnostic tracking, and consumer ads
Optimizer.bat /privacy

:: Optimize network stack, TCP autotuning, and CTCP
Optimizer.bat /network

:: Disable redundant background services
Optimizer.bat /services

:: Run DISM RestoreHealth and SFC integrity scan
Optimizer.bat /repair

:: Revert tweaks back to Windows baseline defaults
Optimizer.bat /revert

:: Display help and flags
Optimizer.bat /help
```

---

## 📋 Features & Modules Breakdown

### 1. ⚡ Quick Full Optimization (`[1]` or `/quick`)
An all-in-one safe optimization package designed for both daily productivity and competitive gaming:
- Asks for confirmation (`[Y/N]`) before creating an optional **System Restore Point** (never created automatically)
- Activates **Ultimate Performance** / **High Performance** power scheme
- Disables Hibernation to reclaim several gigabytes of drive space (`hiberfil.sys`)
- Reduces Windows system responsiveness latency (prioritizing foreground tasks & games)
- Disables telemetry logging (`DiagTrack`, `dmwappushservice`)
- Executes deep disk cache cleanup
- Optimizes TCP autotuning and disables network packet throttling
- Executes instant physical RAM & standby list cache purge

### 2. 🧠 RAM & Memory Cleaner (`[M]` or `/ram` / `/memory`)
Directly communicates with the Windows NT kernel memory manager and PSAPI subsystem:
- **Process Working Sets Trimming**: Safely forces background processes to release unneeded cached memory (`EmptyWorkingSet`).
- **Standby List Purge**: Clears the Windows file system standby cache (`NtSetSystemInformation` with `SystemMemoryListInformation = 80`), eliminating micro-stutters in RAM-intensive games and apps.
- **Modified Page List Flush**: Commits modified memory pages to pagefile to liberate physical addresses.
- **Interactive Auto-Monitor**: Built-in real-time monitoring option (`[2]` in Memory Menu) that checks memory every 10s and automatically triggers cache clearing when usage exceeds 80%.

### 3. 🏆 PRO / Paid Optimizer Tweaks (`[P]` or `/pro`)
Advanced system & esports latency optimizations found in paid utilities (such as *Hone*, *Process Lasso*, *FilterKeys Setter*, and *ReviOS*):
- **BCD Low-Latency Timer Tweaks** (`/bcd`):
  - `disabledynamictick yes`: Disables dynamic timer frequency shifts in games.
  - `useplatformclock no`: Prevents OS from forcing high-overhead HPET.
  - `tscsyncpolicy enhanced`: Forces hardware invariant Time Stamp Counter synchronization across all CPU cores.
  - `bootux disabled`: Bypasses slow UEFI loading animation for faster boot times.
- **CPU Quantum & Core Unparking** (`/unpark`):
  - Sets `Win32PrioritySeparation` to `0x26` (Hex 26 / Dec 38): Configures short, variable quantum with maximum priority boost to the active foreground game.
  - Unparks all CPU cores (`CPMINCORES 100`, `CPMAXCORES 100`) in the active power plan so every core remains ready at 100% frequency without entering sleep states.
- **Input Latency & Peripherals** (`/input`):
  - 1:1 Raw Mouse Input with zero Windows pointer acceleration curve (`MouseSpeed = 0`, sensitivity 10).
  - FilterKeys low delay repeat (`Flags = 59`, `Delay = 150`, `Repeat = 25`) for ultra-responsive keypresses in competitive titles.
  - Disables USB Selective Suspend so mice, keyboards, and headsets never suffer polling dropouts from USB sleep states.
- **Nagle's Algorithm & TCP Delayed ACK Killer** (`/nagle`):
  - Injects `TcpAckFrequency = 1`, `TCPNoDelay = 1`, and `TcpDelAckTicks = 0` across all network adapter interfaces, eliminating the 200ms TCP packet buffering delay for instantaneous hit registration in online games.
- **Deep GPU Shader Cache Cleaner** (`/shader`):
  - Flushes bloated and corrupt shader caches across DirectX (`D3DSCache`), NVIDIA (`DXCache`, `GLCache`), AMD (`DxCache`, `GLCache`), and Intel Graphics.
- **NTFS File System & SSD Boost** (`/fs`):
  - `fsutil behavior set disable8dot3 1`: Disables MS-DOS 8.3 short filename generation, accelerating file lookups and directory traversal on modern SSDs and NVMe drives.
  - `fsutil behavior set disablelastaccess 1`: Prevents updating last-access timestamps on every file read.
  - Increases NTFS lookaside memory buffer pool (`NtfsMemoryUsage = 2`).
- **Ultra-Fast Snappy Visual Effects**:
  - Eliminates slow minimization and window slide animations while preserving ClearType font smoothing so text remains crisp and readable.

### 4. 🎮 Performance & Gaming Latency (`[2]` or `/perf`)
- **Power Scheme**: Duplicates and activates the hidden Windows Ultimate Performance or High Performance scheme.
- **System Responsiveness**: Adjusts `Multimedia\SystemProfile` from Windows 20% background reservation to 0% foreground priority.
- **Gaming Scheduling**: Sets GPU priority to 8 and scheduling category to High for gaming tasks.
- **Game Mode & HAGS**: Enables Windows Game Mode and configures Hardware-Accelerated GPU Scheduling.
- **GameDVR Capture**: Disables background Xbox GameDVR recording to prevent input lag and micro-stutters.
- **Startup Delays**: Removes Explorer startup application delays (`StartupDelayInMSec` = 0) and reduces UI menu delay to 10ms.

### 5. 🔒 Privacy & Telemetry Debloat (`[3]` or `/privacy`)
- **Telemetry Services**: Disables Connected User Experiences and Telemetry (`DiagTrack`) and WAP Push Service (`dmwappushservice`).
- **Data Collection**: Configures Group Policies to enforce `AllowTelemetry = 0` and `MaxTelemetryAllowed = 0`.
- **Advertising ID**: Turns off system Advertising ID and targeted consumer suggestions.
- **Start Menu Search**: Disables Bing web search and Cortana integration from the Start Menu, making searches instant, local, and private.
- **Activity Feed**: Disables Windows Timeline and Activity History synchronization.
- **Feedback & Reporting**: Silences Windows Error Reporting and feedback prompts.

### 6. 🧹 Deep Disk & Cache Cleaner (`[4]` or `/clean`)
- Purges `%TEMP%` and `%SystemRoot%\Temp`
- Cleans Windows Update download cache (`SoftwareDistribution\Download`)
- Flushes the DNS resolver cache (`ipconfig /flushdns`)
- Purges Windows Prefetch cache
- Cleans thumbnail databases (`thumbcache_*.db`) and memory crash dumps (`MEMORY.DMP`, `Minidump`)
- Empties Recycle Bin across all local drives
- Runs Windows Component Store cleanup (`DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase`) to compress superseded system packages

### 7. 🌐 Network & TCP Latency Tuning (`[5]` or `/network`)
- **Congestion Control**: Enables Compound TCP (`CTCP`) congestion provider for lower latency and better throughput.
- **Auto-Tuning**: Configures TCP Window Auto-Tuning level to `normal` and enables Receive Side Scaling (`RSS`).
- **Latency Optimization**: Disables Receive Segment Coalescing (`RSC`) to prevent packet queue buffering in competitive games.
- **Network Throttling**: Disables the default Windows multimedia network throttling index (`0xFFFFFFFF`).
- **Direct Cache Access**: Enables DCA and Explicit Congestion Notification (`ECN`).
- **Stack Reset**: Built-in option to reset Winsock catalog and TCP/IP stack to clean defaults if needed.

### 8. ⚙️ Windows Services Tuning (`[6]` or `/services`)
Safely tunes unnecessary background services that drain CPU and memory cycles:
- `RemoteRegistry` (Security risk and unnecessary background overhead)
- `MapsBroker` (Downloaded Maps Manager offline sync)
- `RetailDemo` (Retail Demo Service)
- `wisvc` (Windows Insider Service)
- `TrkWks` (Distributed Link Tracking Client, switched to manual)
- `lfsvc` (Geolocation service, switched to manual)
- Optional toggle to disable Xbox background services for non-Xbox users.

### 9. 🗑️ Remove UWP Bloatware (`[7]`)
- Safely uninstalls non-essential pre-installed consumer UWP packages for all users (e.g. Bing News, Weather, Finance, Sports, Solitaire Collection, Feedback Hub, Tips, Skype, Zune Video, Your Phone).
- **Preserves essential apps**: Keeps Microsoft Store, Calculator, Notepad, Photos, and Paint intact.
- Optional deep uninstallation of Microsoft OneDrive.

### 10. 🛠️ System Health & Repair (`[8]` or `/repair`)
- **System File Checker**: `sfc /scannow` to detect and repair corrupted system files.
- **DISM Diagnostics**: `ScanHealth` and `CheckHealth`.
- **DISM Repair**: `DISM /Online /Cleanup-Image /RestoreHealth` using Windows Update image source.
- **CHKDSK**: Option to schedule a full disk check on next reboot (`chkdsk C: /f /r`).

### 11. 🛡️ Safety & Revert Capabilities (`[9]` and `[R]`)
- **Restore Point**: Create a snapshot point (`Pre-Optimization-Snapshot`) upon explicit user confirmation (`[Y/N]`) before applying any modifications. System Restore Points are never created silently or automatically.
- **Revert Option**: Restore default Balanced power plan, re-enable standard Windows background services, restore default system responsiveness, BCD timers, mouse/keyboard input settings, and telemetry settings.
- **Session Logging**: All operations are logged to `%TEMP%\Optimizer_Log.txt` and can be viewed directly within the tool (`[L]`).

---

## 🔒 Safety & Compatibility

- **Windows 10**: Versions 1909, 2004, 20H2, 21H1, 21H2, 22H2.
- **Windows 11**: Versions 21H2, 22H2, 23H2, 24H2.
- **Architecture**: x64, ARM64.
- All modifications are non-destructive and use standard Windows NT APIs, Registry keys, and Service configurations.
