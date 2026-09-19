param(
  [string]$InputFile,
  [int]$DelayMilliseconds = 400
)

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDirectory
if (-not $InputFile) { $InputFile = Join-Path $projectRoot 'recognition-result.txt' }

if (-not (Test-Path -LiteralPath $InputFile)) {
  Write-Host "Input file not found: $InputFile" -ForegroundColor Red
  Write-Host "Save the OCR result as recognition-result.txt, or pass a text file path."
  exit 1
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class NativeKeyboard {
  [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public KEYBDINPUT ki; }
  [StructLayout(LayoutKind.Sequential)] public struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
  [DllImport("user32.dll", SetLastError = true)] public static extern uint SendInput(uint count, INPUT[] inputs, int size);
  [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int key);
  public const uint INPUT_KEYBOARD = 1;
  public const uint KEYEVENTF_UNICODE = 4;
  public const uint KEYEVENTF_KEYUP = 2;
  public const int VK_TAB = 9;
  public static void SendUnicode(char character) {
    INPUT[] inputs = new INPUT[2];
    inputs[0].type = INPUT_KEYBOARD;
    inputs[0].ki.wScan = character;
    inputs[0].ki.dwFlags = KEYEVENTF_UNICODE;
    inputs[1].type = INPUT_KEYBOARD;
    inputs[1].ki.wScan = character;
    inputs[1].ki.dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP;
    SendInput(2, inputs, Marshal.SizeOf(typeof(INPUT)));
  }
  public static bool TabIsDown() { return (GetAsyncKeyState(VK_TAB) & 0x8000) != 0; }
}
"@

$text = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $InputFile), [System.Text.Encoding]::UTF8)
Write-Host "Switch to the target input window. Typing starts in:" -ForegroundColor Yellow
for ($secondsLeft = 5; $secondsLeft -ge 1; $secondsLeft--) {
  Write-Host $secondsLeft -ForegroundColor Yellow
  Start-Sleep -Seconds 1
}
Write-Host "Typing started at 150 characters per minute. Press TAB to pause, then TAB again to resume." -ForegroundColor Green

$paused = $false
foreach ($character in $text.ToCharArray()) {
  if ([NativeKeyboard]::TabIsDown()) {
    while ([NativeKeyboard]::TabIsDown()) { Start-Sleep -Milliseconds 30 }
    $paused = -not $paused
    if ($paused) { Write-Host "PAUSED - press TAB to resume." -ForegroundColor Yellow }
    else { Write-Host "RESUMED" -ForegroundColor Green }
  }
  while ($paused) {
    if ([NativeKeyboard]::TabIsDown()) {
      while ([NativeKeyboard]::TabIsDown()) { Start-Sleep -Milliseconds 30 }
      $paused = $false
      Write-Host "RESUMED" -ForegroundColor Green
    }
    Start-Sleep -Milliseconds 30
  }
  [NativeKeyboard]::SendUnicode($character)
  Start-Sleep -Milliseconds $DelayMilliseconds
}
Write-Host "Typing complete." -ForegroundColor Green
