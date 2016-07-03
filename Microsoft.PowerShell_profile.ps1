$PowerTabPath = "$env:homedrive$env:homepath\Documents\WindowsPowerShell\"
$PowerTabConfig = "PowerTabConfig.xml"

Import-Module "PowerTab" -ArgumentList "$(Join-Path $PowerTabPath $PowerTabConfig)"

#Set environment variables for Visual Studio Command Prompt
pushd 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC'
cmd /c "vcvarsall.bat&set" |
foreach {
  if ($_ -match "=") {
    $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  }
}
popd

write-host "`nVisual Studio Command Prompt variables set." -ForegroundColor Yellow

# Load posh-git profile
. 'C:\Users\juan_m_medina\Documents\WindowsPowerShell\Modules\posh-git\juanprofile.ps1'
$GitPromptSettings.EnableFileStatus=$false


function Build-DSA
{
  iex "Recurse-Build -include:Dell*.sln -exclude:*.Models.sln,*.SequenceDiagrams.sln"
}
