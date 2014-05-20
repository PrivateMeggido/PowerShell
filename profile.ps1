$PowerTabPath = "$env:homedrive$env:homepath\Documents\WindowsPowerShell\"
$PowerTabConfig = "PowerTabConfig.xml"

Import-Module "PowerTab" -ArgumentList "$(Join-Path $PowerTabPath $PowerTabConfig)"

