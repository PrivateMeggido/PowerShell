Set-StrictMode -version Latest

<# 
 .Synopsis
  Tests an assembly if it includes XUnit tests

 .Parameter
  
   

 .Description
  Tests an assembly if it includes XUnit tests

 .Example
   # Execute the tests
   Run-Tests MyAssembly.dll
#>

function Run-Tests
{
  param
  (
    [string] $Assembly = ""
  )

  $XUnitConsolePath = $env:XUNIT_CONSOLE_BIN
  $AssemblyFileName = [System.IO.Path]::GetFileNameWithoutExtension($Assembly)
  $LogFile = New-Log -path "$env:LOG_FOLDER\xunit" -logName $AssemblyFileName -logExtension 'xunit' -useDate -Properties
  #[string] $LogFilePath = $LogFile | Select-Object -ExpandProperty FullName

  if ($Assembly -eq "")
  {
    throw "No assembly was provided"
  }

  $Arguments = "$Assembly /xml $LogFile.FullName /noshadow"

  Start-Process -FilePath $XUnitConsolePath $Arguments
  #Start-Process -FilePath $testconsolepath -ArgumentList $args -NoNewWindow -Wait
 

  Write-Output $LogFile.FullName
}


# Exports
Export-ModuleMember -function Run-Tests

