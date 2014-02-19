Set-StrictMode -Version Latest

<# 
 .Synopsis
  Creates a log file, which can be optionally named and dated

 .Description
  Creates a log file, which can be optionally named and dated
  If no paramteters are specified, the log will be created under "c:\temp\log\log.log".
  The folder will be created if it does not exist.
  The return value is a file object, so full file object properties can be extracted

 .Example
   # Create a default log
   New-Log

 .Example
   # Create a named log in the default folder - c:\temp\log\MyLog.log
   New-Log -LogName "MyLog"

 .Example
   # Provide all name parameters
   New-Log -LogName "MyLog" -LogExtension

 .Example
  # Use name parameters and current date time
   New-Log -LogName "MyLog" -LogExtension
#>
function New-Log
{
  param
  (
    [string] $Path= "c:\logs",
    [string] $LogName = "log",
    [string] $LogExtension = "log",
    [switch] $UseDate = $false
  )

  # Set date variable
  $CurrentDate = ""
  if ($UseDate -eq $true) 
  { 
    $CurrentDate = Get-Date -f "yyyyMMdd-hhmmss" 
  } 

  try
  {
    # Create log folder if it does not exist
    New-Item -ItemType Directory -Force -Path "$Path" | Out-Null

    # Set the file name
    $LogFile = New-Item -ItemType File -Force -Path "$Path\$LogName$CurrentDate.$LogExtension"

    return $LogFile 
  }
  catch
  {
    Write-Output $_
  }

}

# Exports
Export-ModuleMember -function New-Log
