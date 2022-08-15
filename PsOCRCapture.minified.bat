@echo off
title PsOCRCapture - Console
mode 65,15
color 0a
echo.^> Starting...
powershell -c "using namespace Windows.Graphics.Imaging;try {Add-Type -AssemblyName System.Windows.Forms, System.Drawing, System.Runtime.WindowsRuntime;$null=[Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType=WindowsRuntime];$null=[Windows.Foundation.IAsyncOperation`1, Windows.Foundation, ContentType=WindowsRuntime];$null=[Windows.Graphics.Imaging.SoftwareBitmap, Windows.Foundation, ContentType=WindowsRuntime];$null=[Windows.Graphics.Imaging.BitmapDecoder, Windows.Foundation, ContentType=WindowsRuntime];$null=[Windows.Storage.Streams.RandomAccessStream, Windows.Storage.Streams, ContentType=WindowsRuntime];$null=[Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages;$getAwaiterBaseMethod=[WindowsRuntimeSystemExtensions].GetMember('GetAwaiter').Where({$PSItem.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'}, 'First')[0];Function Await {param($AsyncTask, $ResultType);$getAwaiterBaseMethod.MakeGenericMethod($ResultType).Invoke($null, @($AsyncTask)).GetResult()};$ocrEngine=[Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage('en-US')} catch {throw 'OCR requires Windows 10+. You cannot use this module in PowerShell 7.';exit 1};Function OCRCapture {Write-Host ('*'*40);$oldClipboard=[System.Windows.Forms.Clipboard]::GetDataObject();[System.Windows.Forms.Clipboard]::SetText(' ');if (Test-Path -Path $env:SYSTEMROOT"""\System32\SnippingTool.exe"""){Write-Host '> Executing Snipping Tool';[Diagnostics.Process]::Start('SnippingTool.exe', '/clip').WaitForExit()}else{Write-Host '> Executing Snip & Sketch';Start-Process 'explorer.exe' 'ms-screenclip:' -Wait};Write-Host '> Waiting for image';$timeout=New-TimeSpan -Seconds 10;$stopwatch=[System.Diagnostics.Stopwatch]::StartNew();do {$clipboard=[System.Windows.Forms.Clipboard]::GetDataObject();Start-Sleep 0.01;if ($stopwatch.elapsed -gt $timeout){Write-Output 'Failed to copy image to clipboard.';Write-Host '> Failed. Aborting...';[System.Windows.Forms.Clipboard]::SetDataObject($oldClipboard);return};} until ($clipboard.ContainsImage());$bmp=$clipboard.getimage();[System.Windows.Forms.Clipboard]::SetDataObject($oldClipboard);$minPx=150;if (($bmp.Height -lt $minPx) -or ($bmp.Width -lt $minPx)){$nh=[math]::max($bmp.Height, $minPx);$nw=[math]::max($bmp.Width, $minPx);Write-Host ([String]::Concat('> Extending image (',$bmp.Width,',',$bmp.Height,') -> (',$nw,',',$nh,') px'));$graphics=[Drawing.Graphics]::FromImage(($newBmp=[Drawing.Bitmap]::new($nw, $nh)));$graphics.Clear($bmp.GetPixel(0, 0));if (($bmp.Height -lt $minPx) -and ($bmp.Width -lt $minPx)){$sf=([math]::min(([math]::floor($minPx/[math]::max($bmp.Width, $bmp.Height))),3));if ($sf -gt 1){Write-Host ([String]::Concat('> Scaling image by ',$sf,'x'))}}else{$sf=1};$sw=($sf*$bmp.Width);$sh=($sf*$bmp.Height);$graphics.DrawImage($bmp, ([math]::floor(($nw-$sw)/2)), ([math]::floor(($nh-$sh)/2)), $sw, $sh);$bmp=$newBmp.Clone();$newBmp.Dispose();$graphics.Dispose()};Write-Host '> Converting image format to SoftwareBitmap';$memStream=[IO.MemoryStream]::new();$bmp.Save($memStream, 'Bmp');$r=[IO.WindowsRuntimeStreamExtensions]::AsRandomAccessStream($memStream);$params=@{AsyncTask=[BitmapDecoder]::CreateAsync($r);ResultType=[BitmapDecoder]};$bitmapDecoder=Await @params;$params=@{AsyncTask=$bitmapDecoder.GetSoftwareBitmapAsync();ResultType=[SoftwareBitmap]};$softwareBitmap=Await @params;$memStream.Dispose();$r.Dispose();Write-Host '> Running OCR';(((Await $ocrEngine.RecognizeAsync($softwareBitmap)([Windows.Media.Ocr.OcrResult])).Lines|ForEach-Object {$_.Text}) -Join """`n""");Write-Host '> Completed successfully'};Function FormUI {[Windows.Forms.Application]::EnableVisualStyles();$form=New-Object Windows.Forms.Form;$form.Text='OCR Capture';$form.Width=420;$form.Height=320;$form.AutoSize=$true;$textBox=New-Object Windows.Forms.RichTextBox;$textBox.Multiline=$true;$textBox.ScrollBars=[Windows.Forms.ScrollBars]::Both;$textBox.WordWrap=$true;$textBox.AcceptsTab=$true;$textBox.Dock=[Windows.Forms.DockStyle]::Fill;$textBox.Font=New-Object System.Drawing.Font('Segoe UI', 12);$textBox.Text='Scanned text will appear here.';$form.Controls.Add($textBox);$menu=New-Object Windows.Forms.MenuStrip;$captureButton=New-Object Windows.Forms.ToolStripMenuItem;$captureButton.Text='Capture';$captureButton.add_Click({$form.Hide();$o=((&{OCRCapture}).Trim());if ($o -eq ''){$textBox.Text='Failed to recognize text.'}else{$textBox.Text=$o};$form.Show()});$menu.Items.Add($captureButton);$copyButton=New-Object Windows.Forms.ToolStripMenuItem;$copyButton.Text='Copy';$copyButton.add_Click({if ($textBox.Text -ne ''){[System.Windows.Forms.Clipboard]::SetText($textBox.Text)}});$menu.Items.Add($copyButton);$form.Controls.Add($menu);$form.Add_Shown({$form.Activate()});[void] $form.ShowDialog()};FormUI"