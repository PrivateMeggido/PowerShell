$PowerTabPath = "$env:homedrive$env:homepath\Documents\WindowsPowerShell\"
$PowerTabConfig = "PowerTabConfig.xml"

Import-Module "PowerTab" -ArgumentList "$(Join-Path $PowerTabPath $PowerTabConfig)"

#Set environment variables for Visual Studio Command Prompt

pushd 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools'
cmd /c VsDevCmd.bat
popd

#write-host "`nVisual Studio Command Prompt variables set." -ForegroundColor Yellow

# Load posh-git profile
. 'C:\Users\juan_m_medina\Documents\WindowsPowerShell\Modules\posh-git\juanprofile.ps1'
$GitPromptSettings.EnableFileStatus=$false


# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

$CodePath = "c:\code"
$TfsDefaultCollection="http://tfs2.dell.com:8080/tfs/edell"
