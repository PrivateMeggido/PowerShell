Set-StrictMode -version Latest

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class Win32Api
{
    [DllImport("User32.dll", EntryPoint = "SetWindowText")]
    public static extern int SetWindowText(IntPtr hWnd, string text);
}
"@


<# 
  .SYNOPSIS

  Minor simplification for calling the IISExpress command.

  .DESCRIPTION

  Minor simplification for calling the IISExpress command.
  Will expand the passed path to a full path (which is required for IISExpress to work fine).

  .PARAMETER  WebAppPath

  Required. The path to the root of the WebApplication.

  .PARAMETER Port 

  Required. The Port to use for the application.

  .EXAMPLE

  Starts the web app on the current folder (internally expanding the path) on port 1234

    Start-WebApp -WebAppPath .\ -Port 1234

  Starts the web app on the described folder on port 8080

    Start-WebApp -WebAppPath c:\inetpub\www\myapp -Port 8080 
#>
function Start-WebApp
{
  param
  (
    [Parameter(Position=0,
               HelpMessage="The full path of the Web App to start")]
    [ValidateNotNullOrEmpty()]
    [string] $WebAppPath = $(throw "WebAppPath is mandatory, please provide a value"),
    [Parameter(Position=1,
               HelpMessage="The port to use for the application")]
    [ValidateNotNullOrEmpty()]
    [string] $Port = $(throw "Port is mandatory, please provide a value")
  )

  Write-Debug "WebAppPath: $WebAppPath"
  Write-Debug "Port: $Port"

  $FullPath = Resolve-Path -Path $WebAppPath
  $StripAppPath = Split-Path -Path $FullPath -Leaf
  $IISExpressPath = "$env:ProgramFiles\IIS Express\iisexpress.exe"
  $Arguments = "/path:$($FullPath.Path) /port:$Port"

  Write-Debug "FullPath: $($FullPath.Path)"
  Write-Debug "IISExpressPath: $IISExpressPath"
  Write-Debug "Arguments: $Arguments"
  
  $WebAppProcess = Start-Process -FilePath $IISExpressPath -ArgumentList $Arguments -PassThru
  $PID = $WebAppProcess.Id

  Write-Host "Started $StripAppPath at $Port - PID $PID"

  #$WebAppProcess.WaitForInputIdle(1000)
  Start-Sleep -s 1 
  $WindowTextResult = [Win32Api]::SetWindowText($WebAppProcess.MainWindowHandle, "PID $PID - $StripAppPath at $Port")

}

# Exports
Export-ModuleMember -function Start-WebApp
