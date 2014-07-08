Set-StrictMode -Version Latest

<# 
 .Synopsis
  Adds a workspace for the current user.

 .Description
  Using the Team Explorer Everywhere, add a workspace for the current user.
  Uses the "TfsDefaultCollection" if no collection is provided.

 .Parameter WorkspaceName
  The name to be given to the Workspace.

 .Parameter TFSPath
  The default remote path to link to the Workspace.

 .Parameter LocalPath
  The local path to link to the Workspace.

 .Example
   # Add a workspace
   Add-Workspace -Workspace MyWorkspace -TFSPath $/ROOT/Blah/MyPath -LocalPath C:\MyLocalPath
#>
function Add-Workspace
{
  # TODO: Add check for local path to exist or create
  # TODO: Add verification that remote repo is not mispelled
  param
  (
    [Parameter(Mandatory=$true)] [string] $workspace,
    [Parameter(Mandatory=$true)] [string] $tfsPath,
    [Parameter(Mandatory=$true)] [string] $localPath,
    [string] $collection = $env:TfsDefaultCollection
  )
  
  <# if ($env:TfsDefaultCollection -eq "" -and $collection -eq "")
  {
    throw "The collection is blank (if not supplied, it also means the environment variable 'TfsDefaultCollection' is also empty)"
  }
  
  if ($workspace -eq "" -or $tfsPath -eq "" -or $localPath -eq "")
  {
    throw "Usage: tf -workspace myWorkspace -tfsPath $/root/path/source -localPath C:\localpath"
  } #>
  
  Write-Output "*********************************************************"
  Write-Output "Creating Workspace with"
  Write-Output " - TFS Collection: '$env:TfsDefaultCollection'"
  Write-Output " - Workspace Name: '$workspace'"
  Write-Output " - TFS Path: '$tfsPath'"
  Write-Output " - Local Path: '$localPath'"
  Write-Output "*********************************************************"
  
  # Create the workspace
  tf workspace /new $workspace`;juan_m_medina /collection:$env:TfsDefaultCollection /noprompt
  
  # Map it to the right folder
  tf workfold /collection:$env:TfsDefaultCollection /workspace:$workspace /map "$tfsPath" "$localPath"
}

<# 
 .Synopsis
  Deletes a workspace from the default collection.

 .Description
  Using the Team Explorer Everywhere, delete a workspace.
  Uses the "TfsDefaultCollection" if no collection is provided.

 .Parameter WorkspaceName
  The name of the workspace to delete.

 .Example
   # Remove a workspace
   Remove-Workspace -Workspace MyWorkspace
#>
function Remove-Workspace
{
  param
  (
    [string] $workspace,
    [string] $collection = $env:TfsDefaultCollection
  )

  if ($collection -eq "")
  {
    throw "The collection is blank (if not supplied, it also means the environment variable 'TfsDefaultCollection' is also empty)"
  }

  if ($workspace -eq "")
  {
      throw "Usage: tf -workspace BLAH"
  }

  tf workspace /delete $workspace /collection:$collection
}

<# 
 .Synopsis
  Gets a listing of the workspaces for the default collection.

 .Description
  Using the Team Explorer Everywhere, get the list of available workspaces.
  Uses the "TfsDefaultCollection" if no collection is provided.

 .Example
   # Get Workspaces
   Get-Workspaces /collection:https://myserver.dell.com:8080/root/subroot
#>
function Get-Workspaces
{
  param
  (
    [string] $collection = $env:TfsDefaultCollection,
    [string] $format  = "Brief"
  )

  if ($collection -eq "")
  {
    throw "The collection is blank (if not supplied, it also means the environment variable 'TfsDefaultCollection' is also empty)"
  }

  tf workspaces /collection:$collection /format:$format
}

<# 
 .Synopsis
  Reset the workspace. Use with caution, it wipes out the directory it is called in recursively.

 .Description
  Clears the workspace. Use with caution, it wipes out the directory it is called in recursively.
  Restores the workspace fully from TFS after it clears out the folder.
  Because it does wipe out the folder recursively, there is a prompt to confirm the deletions.

 .Example
   # Reset the Current Workspace 
   c:\TheWorkspaceFolder\Reset-Workspace
#>
function Reset-Workspace
{
  Remove-Item -recurse -force -confirm *
  tf get -force
}

# Exports
Export-ModuleMember -function Add-Workspace
Export-ModuleMember -function Remove-Workspace
Export-ModuleMember -function Get-Workspaces
Export-ModuleMember -function Reset-Workspace

