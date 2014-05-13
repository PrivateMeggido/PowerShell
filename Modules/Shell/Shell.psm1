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

Export-ModuleMember -function Compare-Folders

