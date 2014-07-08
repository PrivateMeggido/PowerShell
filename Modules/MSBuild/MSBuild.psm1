Set-StrictMode -Version Latest

<# 
 .Synopsis
  Builds the solution at the current folder with configuration and platform values.

 .Description
  Builds the solution at the current folder with configuration and platform values.
  Default values are "Debug" for Configuration and "Any Cpu" for platform.

 . Parameter configuration
 . 

 .Example
   # Build with defaults
   Build

 .Example
   # Build with specific values
   Build -configuration "Release" -platform "x86"
#>
function Build
{
  param
  (
    [string] $Configuration = "Debug",
    [string] $Platform = "Any Cpu",
    [string] $Solution = "",
    [string] $LogFile = "c:\logs\msbuild\msbuild.log",
    [string] $Verbosity = "Normal",
    [string] $FileLoggerParameters = "LogFile=$LogFile;Verbosity=$Verbosity",
    [string] $ConsoleVerbosity = "Minimal",
    [string] $ConsoleLoggerParameters = "Verbosity=$ConsoleVerbosity",
    [string] $Target = "Clean;Build",
    [string] $RunCodeAnalysis = "Always"
  )

  Write-Host "Building $Solution ..." -foreground "green"; `

  try
  {
    & 'C:\Program Files (x86)\MSBuild\12.0\Bin\amd64\MSBuild.exe' `
    /maxCpuCount `
    /p:BuildInParallel=true `
    /nologo `
    /target:$Target `
    /p:Configuration=$Configuration `
    /p:Platform=$Platform $Solution `
    /p:RunCodeAnalysis=$RunCodeAnalysis `
    /fileLogger `
    /fileLoggerParameters:$FileLoggerParameters `
    /consoleLoggerParameters:$ConsoleLoggerParameters `
  }
  catch [Exception]
  {
    Add-Content $LogFile $_.Exception.Message;
    Write-Host "There was a problem with the Build, check logfile '$LogFile'" -foreground "red";
  }
}

<# 
  .SYNOPSIS

  Builds all .sln files under the current folder

  .DESCRIPTION

  Builds all .sln files under the current folder.
  Depends in another function on the module "Build".
  Since the goal is to shorcut common usage, some of the extra options on the Build function
  are not extended on the recurse build.  

  .PARAMETER $Configuration
  The Configuration to use, defaults to "Debug" if not provided.

  .PARAMETER $Platform
  The Platform to use (x86, x64, Any Cpu). Defaults to "Any Cpu" if not provided.

  .PARAMETER $Verbosity
  The Amount of logging information to provide for the log file. Defaults to "Normal" if not provided.

  .PARAMETER $ConsoleLoggerParameters
  The Parameters to pass to the Console Logger. Defaults to "ErrorsOnly;" if not provided.

  .PARAMETER $LogPath
  The Log folder path. The log will be created under this folder. If the folder does not exist, it will be created.

  .PARAMETER $LogPrefix
  The Log File Prefix. Recurse build handles the log by appending to it, after first clearing the file (prior to the first build).
  The File name will be the Prefix plus the full date, with the "msbuild" file extension.

  .EXAMPLE

  C:\source>Recurse-Build

  This command will build all the solutions found recursively under the "source" folder with the default parameter values.

  .EXAMPLE

  C:\source>Recurse-Build -Configuration Debug -Platform x64

  This command will build all the solutions found recursively under the "source" folder using the "Debug" configuration and targeting the x64 platform.

  .EXAMPLE

  C:\source>Recurse-Build -Verbosity Normal -ConsoleLoggerParameters ShowTimestamp;Verbosity:

  This command will build all the solutions found recursively under the "source" folder with 

  .EXAMPLE

  C:\source>Recurse-Build -LogPath c:\temp -LogPrefix blah

  This command will build all the solutions found recursively under the "source" and output the a log to the "C:\temp\blahYYYYMMDD-hhmmss.msbuild"
  where YYYYMMDD-hhmmss will be the actual date-time of creation.
#>

function Recurse-Build
{
  param
  (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Configuration = "Debug",
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Platform = "Any Cpu",
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Verbosity = "Normal",
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $RunCodeAnalysis = "Always",
    [Parameter()]
    [string] $ConsoleLoggerParameters = "ErrorsOnly;",
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $LogPrefix = "recurse-build-",
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $LogPath = "C:\logs\msbuild"
  )

  try
  {

    $ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew();

    [string] $LogFile = New-Log -Path $LogPath  -LogName $LogPrefix -UseDate -LogExtension msbuild;

    Write-Host "Recurse Building with the following setup" -foreground "black" -background "gray";
    Write-Host "   Configuration:          $Configuration" -foreground "black" -background "gray";
    Write-Host "   Platform:               $Platform" -foreground "black" -background "gray";
    Write-Host "   Run Code Analysis:      $RunCodeAnalysis" -foreground "black" -background "gray";
    Write-Host "   Log File:               $LogFile" -foreground "black" -background "gray";
    Write-Host "   Log File Verbosity:     $Verbosity" -foreground "black" -background "gray";
    Write-Host "   Console Log Parameters: $ConsoleLoggerParameters" -foreground "black" -background "gray";
    Write-Host "`r`n";

    $ConfigurationPhrase           = "-Configuration `"$Configuration`"";
    $PlatformPhrase                = "-Platform `"$Platform`"";
    $CodeAnalysisPhrase            = "-RunCodeAnalysisis `"$RunCodeAnalysis`"";
    $FileLoggerParametersPhrase    = "-FileLoggerParameters `"LogFile=$LogFile;Verbosity=$Verbosity;Append`"";
    $ConsoleLoggerParametersPhrase = if ($ConsoleLoggerParameters) { "-ConsoleLoggerParameters `"$ConsoleLoggerParameters`"" } else { "" };
    $VerbosityPhrase               = "-Verbosity `"$Verbosity`"";
    
    $Solutions = Get-ChildItem -path . -recurse -include *.sln;

    ForEach ($Solution in $Solutions) 
    { 
      $BuildPhrase = "Build " +
                     $ConfigurationPhrase + " " + 
                     $PlatformPhrase + " " + 
                     $CodeAnalysisPhrase + " " + 
                     $FileLoggerParametersPhrase + " " + 
                     $ConsoleLoggerParametersPhrase + " " + 
                     $VerbosityPhrase + " " +
                     "-Solution " + "`"$Solution`"";

      Write-Debug "Executing `"$BuildPhrase`"";
  
      Invoke-Expression $BuildPhrase;
    }

    Write-Host "   Done - Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -foreground "black" -background "gray";

  }
  catch [Exception]
  {
    Add-Content $LogFile $_.Exception.Message;
    Write-Host "There was a problem with the Recurse Build, check logfile '$LogFile'" -foreground "red";
  } 
}

<# 
  .SYNOPSIS

  Rebuilds all solutions found under the current folder using both "Debug" and "Release".

  .DESCRIPTION
  Rebuilds all solutions found under the current folder using both "Debug" and "Release".
  This is just a shortcut to call the two most common configurations. For more granular 
  control, use "Recurse-Build" and specify parameters for each configuration.

  .EXAMPLE

  C:\source>Recurse-BuildAll

  This command will build all the solutions found recursively under the "source" folder with 
#>
function Recurse-BuildAll
{
  Recurse-Build -configuration Debug; Recurse-Build -configuration Release
}

# Exports
Export-ModuleMember -function Build
Export-ModuleMember -function Recurse-Build
Export-ModuleMember -function Recurse-BuildAll
 
