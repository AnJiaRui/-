$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$root = Split-Path -Parent $scriptDirectory
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://127.0.0.1:8765/')
$listener.Start()
Write-Host 'Auto OCR mode is running on http://127.0.0.1:8765/' -ForegroundColor Green
Write-Host 'The browser will send OCR results here automatically.'
try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $response = $context.Response
    $response.Headers.Add('Access-Control-Allow-Origin', '*')
    $response.Headers.Add('Access-Control-Allow-Methods', 'POST, OPTIONS')
    if ($context.Request.HttpMethod -eq 'OPTIONS') { $response.StatusCode = 204; $response.Close(); continue }
    if ($context.Request.HttpMethod -ne 'POST' -or $context.Request.Url.AbsolutePath -ne '/result') { $response.StatusCode = 404; $response.Close(); continue }
    $reader = New-Object System.IO.StreamReader($context.Request.InputStream, $context.Request.ContentEncoding)
    $text = $reader.ReadToEnd()
    $reader.Close()
    [System.IO.File]::WriteAllText((Join-Path $root 'recognition-result.txt'), $text, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host 'OCR result received. Starting typing in 5 seconds...' -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $root 'type-result.ps1'), '-InputFile', (Join-Path $root 'recognition-result.txt'), '-DelayMilliseconds', '400'
    $bytes = [System.Text.Encoding]::UTF8.GetBytes('{"ok":true}')
    $response.ContentType = 'application/json'
    $response.ContentLength64 = $bytes.Length
    $response.OutputStream.Write($bytes, 0, $bytes.Length)
    $response.Close()
  }
} finally { $listener.Stop() }
