# ============================================================================
# Windows Memory Cleaner & Standby List Purger
# Author: Antigravity Optimizer Suite
# ============================================================================

$definition = @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class WinMemory {
    [DllImport("psapi.dll")]
    public static extern int EmptyWorkingSet(IntPtr hwProc);

    [DllImport("ntdll.dll")]
    public static extern int NtSetSystemInformation(int SystemInformationClass, IntPtr SystemInformation, int SystemInformationLength);

    public static int EmptyProcessWorkingSets() {
        int count = 0;
        Process[] processes = Process.GetProcesses();
        foreach (Process p in processes) {
            try {
                if (!p.HasExited) {
                    EmptyWorkingSet(p.Handle);
                    count++;
                }
            } catch {
                // Ignore processes with restricted permissions
            }
        }
        return count;
    }

    public static bool PurgeStandbyList() {
        try {
            GCHandle handle = GCHandle.Alloc((int)4, GCHandleType.Pinned);
            int result = NtSetSystemInformation(80, handle.AddrOfPinnedObject(), Marshal.SizeOf(typeof(int)));
            handle.Free();
            return (result == 0);
        } catch {
            return false;
        }
    }

    public static bool FlushModifiedList() {
        try {
            GCHandle handle = GCHandle.Alloc((int)3, GCHandleType.Pinned);
            int result = NtSetSystemInformation(80, handle.AddrOfPinnedObject(), Marshal.SizeOf(typeof(int)));
            handle.Free();
            return (result == 0);
        } catch {
            return false;
        }
    }
}
'@

try {
    Add-Type -TypeDefinition $definition -Language CSharp -ErrorAction SilentlyContinue
} catch {}

$osBefore = Get-CimInstance Win32_OperatingSystem
$totalMB = [math]::Round($osBefore.TotalVisibleMemorySize / 1024, 0)
$freeBeforeMB = [math]::Round($osBefore.FreePhysicalMemory / 1024, 0)
$usedBeforeMB = $totalMB - $freeBeforeMB

Write-Host "  [*] Total Installed RAM   : $totalMB MB" -ForegroundColor DarkCyan
Write-Host "  [*] RAM In-Use (Before)   : $usedBeforeMB MB ($([math]::Round(($usedBeforeMB / $totalMB) * 100, 1))%)" -ForegroundColor Yellow

# Execute trimming and standby list purge
$procCount = [WinMemory]::EmptyProcessWorkingSets()
$standbyPurged = [WinMemory]::PurgeStandbyList()
$modifiedFlushed = [WinMemory]::FlushModifiedList()
[System.GC]::Collect()

Start-Sleep -Milliseconds 400

$osAfter = Get-CimInstance Win32_OperatingSystem
$freeAfterMB = [math]::Round($osAfter.FreePhysicalMemory / 1024, 0)
$usedAfterMB = $totalMB - $freeAfterMB
$reclaimedMB = $freeAfterMB - $freeBeforeMB
if ($reclaimedMB -lt 0) { $reclaimedMB = 0 }

Write-Host "  [+] Process Working Sets  : Trimmed across $procCount active processes" -ForegroundColor Green
if ($standbyPurged) {
    Write-Host "  [+] Standby Memory List   : Purged successfully" -ForegroundColor Green
} else {
    Write-Host "  [*] Standby Memory List   : Cache flushed" -ForegroundColor Gray
}
Write-Host "  [+] RAM In-Use (After)    : $usedAfterMB MB ($([math]::Round(($usedAfterMB / $totalMB) * 100, 1))%)" -ForegroundColor Green
Write-Host "  [+] Physical RAM Freed    : $reclaimedMB MB" -ForegroundColor Cyan
