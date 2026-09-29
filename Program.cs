using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace KaiserOptimizer
{
    class Program
    {
        static int Main(string[] args)
        {
            Console.Title = "KAISER - Windows 10/11 Optimizer";

            string tempDir = Path.Combine(Path.GetTempPath(), "KAISER_" + Guid.NewGuid().ToString("N").Substring(0, 8));
            Directory.CreateDirectory(tempDir);

            try
            {
                Assembly asm = Assembly.GetExecutingAssembly();
                ExtractResource(asm, "Optimizer.bat", Path.Combine(tempDir, "Optimizer.bat"));
                ExtractResource(asm, "MemoryCleaner.ps1", Path.Combine(tempDir, "MemoryCleaner.ps1"));
                ExtractResource(asm, "banner.txt", Path.Combine(tempDir, "banner.txt"));

                string scriptPath = Path.Combine(tempDir, "Optimizer.bat");

                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "cmd.exe";
                string argList = string.Empty;
                if (args != null && args.Length > 0)
                {
                    argList = " " + string.Join(" ", args);
                }
                psi.Arguments = "/c \"\"" + scriptPath + "\"" + argList + "\"";
                psi.WorkingDirectory = tempDir;
                psi.UseShellExecute = false;

                using (Process proc = Process.Start(psi))
                {
                    proc.WaitForExit();
                    return proc.ExitCode;
                }
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("[!] Error executing KAISER Optimizer: " + ex.Message);
                Console.ResetColor();
                Console.WriteLine("\nPress any key to exit...");
                Console.ReadKey();
                return 1;
            }
            finally
            {
                try
                {
                    if (Directory.Exists(tempDir))
                    {
                        Directory.Delete(tempDir, true);
                    }
                }
                catch {}
            }
        }

        static void ExtractResource(Assembly asm, string resourceName, string outputPath)
        {
            string fullName = null;
            foreach (string name in asm.GetManifestResourceNames())
            {
                if (name.EndsWith(resourceName, StringComparison.OrdinalIgnoreCase))
                {
                    fullName = name;
                    break;
                }
            }

            if (fullName == null)
            {
                throw new FileNotFoundException("Embedded resource not found: " + resourceName);
            }

            using (Stream stream = asm.GetManifestResourceStream(fullName))
            using (FileStream fileStream = new FileStream(outputPath, FileMode.Create, FileAccess.Write))
            {
                stream.CopyTo(fileStream);
            }
        }
    }
}
