Set-StrictMode -version Latest

<# 
  .SYNOPSIS

    Retrieves the latest for the current directory workspace, then compiles Debug and Release modes.

  .DESCRIPTION

    Retrieves the latest for the current directory workspace, then compiles Debug and Release modes.
    When executed on a folder that is under TFS, it will update the current folder and using
    the Recurse-Build module functions recusively find all solutions under the directory, then build
    them in both Debug and Release

  .EXAMPLE

    Catch-Up

  .NOTES

    No validation is being currently made to ensure the update from TFS has no conflicts, so attention
    must be paid to the error messages on that end.
#>
function Catch-Up
{
  & tf get
  Recurse-Build -configuration Debug
  Recurse-Build -configuration Release
}

# Exports
Export-ModuleMember -function Catch-Up
