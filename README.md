# PowerShell OCR Capture

This project aims to make use of native Windows 10/11 features to allow users to grab text from the contents of their screen. It uses Snipping Tool/Snip & Sketch and the Windows 10 OCR engine. Unlike other screen OCR tools, this project does not require any third-party dependencies. This makes it possible to run on restrictive devices, such as work computers.

<hr width=50>

### In Action

![preview](https://user-images.githubusercontent.com/72637910/184614565-1a550bd6-80fd-4d8a-8a92-fcec9d7509d3.gif)


##### Includes:
- Launches screen capture with "Capture" button, and waits for image to copy to clipboard. Old clipboard contents are restored.
- Upscaling, extending, and centering images for better results. Supports capturing small pieces of text.
- Detecting whether to use Snipping Tool (Windows 10) or Snip & Sketch (Windows 11)
- Includes a "Copy" button to copy contents of the text field
- Window will hide when capturing text
- Runs *fast*
- Error handling

<hr width=50>

### Usage

Select a region of your screen to scan with the "Capture" button. Recognized text will be returned in an input field.

To run in PowerShell, you will have to set the command execution policy. Simply paste this into a PowerShell instance:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; ./PsOCRCapture.ps1
```

To run without setting the PowerShell script execution policy, simply download and run [`PsOCRCapture.minified.bat`](https://raw.githubusercontent.com/daijro/PsOCRCapture/main/PsOCRCapture.minified.bat)

---

### Credits

The code behind this tool was inspired by [this reference](https://github.com/HumanEquivalentUnit/PowerShell-Misc/blob/master/Get-Win10OcrTextFromImage.ps1).
