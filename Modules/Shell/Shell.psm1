function Compare-Folders
{
  param
  (
    [Parameter()][ValidateNotNullOrEmpty()][string] $SourceFolder=$(throw "Base Folder is required"),
    [Parameter()][ValidateNotNullOrEmpty()][string] $TargetFolder=$(throw "Target Folder is required")
  )

  try
  {
    if (-not (Test-Path $SourceFolder))
    {
      throw "The Source Folder does not exist"
    }
    if (-not (Test-Path $TargetFolder))
    {
      throw "The Target Folder does not exist"
    }

    $source = Get-ChildItem -path $SourceFolder -recurse 
    $target = Get-ChildItem -path $TargetFolder -recurse


    Compare-Object -ReferenceObject $source -DifferenceObject $target
  }
  catch 
  {
    Write-Host "There was a problem comparing the folders: $_"
  } 
}

function Decode-Base64
{
  param
  (
    [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string] $InputText = $input
  )

  [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($InputText))
}

#function Extract-Gz
#{
#  param
#  (
#    [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string] $InputStream = $input
#  )
#
#  Write-Host $InputStream
#
#  #$InputByteArray = [System.Text.Encoding].UTF8.GetBytes($InputStream)
#
#  #$MemoryStream = New-Object System.IO.MemoryStream($InputByteArray)
#  $MemoryStream = New-Object System.IO.MemoryStream($InputStream)
#
#  $Unzipper = New-Object System.IO.Compression.GzipStream $MemoryStream, ([IO.Compression.CompressionMode]::Decompress)
#
#  $buffer = New-Object byte[](1024)
#  while ($true)
#  {
#    $ReadBytes = $Unzipper.Read($buffer, 0, 1024)
#
#    if ($ReadBytes -le 0) { break }
#
#    Write-Output $buffer
#  }
#}



Export-ModuleMember -function Compare-Folders
Export-ModuleMember -function Decode-Base64
#Export-ModuleMember -function Extract-Gz

