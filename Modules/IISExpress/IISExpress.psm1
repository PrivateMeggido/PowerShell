Set-StrictMode -version Latest

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

  $IISExpressPath = "$env:ProgramFiles\IIS Express\iisexpress.exe"
  $Arguments = "/path:$WebAppPath /port:$Port"
  
  Start-Process -FilePath $IISExpressPath -ArgumentList $Arguments 

}

# Exports
Export-ModuleMember -function Start-WebApp
