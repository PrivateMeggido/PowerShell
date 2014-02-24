function Clear-ASPTempFiles()
{
  $versionArray = @('v1.0.3705','v1.1.4322','v2.0.50727','v3.0','v3.5','v4.0.30319')

  foreach ($version in $versionArray) 
  {
    $currentFolder = "$env:SystemRoot\Microsoft.Net\Framework\$version\Temporary ASP.NET Files"
    if (Test-Path $currentFolder) 
    {
      Remove-Item -recurse -force "$currentFolder\*"
    }
  }
}

Export-ModuleMember -function Clear-ASPTempFiles


