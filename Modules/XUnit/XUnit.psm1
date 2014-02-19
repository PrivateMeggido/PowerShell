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

  $XUnitConsolePath = 'C:\tools\xunit\xunit.console.clr4.exe'
  $AssemblyFileName = [System.IO.Path]::GetFileNameWithoutExtension($Assembly)
  $LogFile = New-Log -path 'C:\logs\xunit' -logName $AssemblyFileName -logExtension 'xunit' -useDate -Properties
  #[string] $LogFilePath = $LogFile | Select-Object -ExpandProperty FullName

  if ($Assembly -eq "")
  {
    throw "No assembly was provided"
  }

  & $XUnitConsolePath $Assembly /xml "$LogFile.FullName"

  #Write-Output $LogFile.FullName
}


# Exports
Export-ModuleMember -function Run-Tests

