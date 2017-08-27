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
    [string] $collection = $TfsDefaultCollection
  )
  
  <# if ($TfsDefaultCollection -eq "" -and $collection -eq "")
  {
    throw "The collection is blank (if not supplied, it also means the environment variable 'TfsDefaultCollection' is also empty)"
  }
  
  if ($workspace -eq "" -or $tfsPath -eq "" -or $localPath -eq "")
  {
    throw "Usage: tf -workspace myWorkspace -tfsPath $/root/path/source -localPath C:\localpath"
  } #>
  
  Write-Output "*********************************************************"
  Write-Output "Creating Workspace with"
  Write-Output " - TFS Collection: '$TfsDefaultCollection'"
  Write-Output " - Workspace Name: '$workspace'"
  Write-Output " - TFS Path: '$tfsPath'"
  Write-Output " - Local Path: '$localPath'"
  Write-Output "*********************************************************"

  if (Test-Path $localPath)
  {
    pushd $localPath
  }
  else
  {
    Write-Output "Local Path '$localPath' does not exist. Do you want to create the folder?"
    $answer = Read-Host "Yes or No"
   
    while("yes","no" -notcontains $answer)
    {
    	$answer = Read-Host "Yes or No"
    }

    if ($answer -Contains "yes")
    {
      New-Item -type directory -Path $localPath
      pushd $localPath
    }
    else
    {
      Write-Host "Aborting"
      return;
    }
  }

  # Create the workspace
  tf workspace /new $workspace`;juan_m_medina /collection:$TfsDefaultCollection /noprompt
  
  # Map it to the right folder
  tf workfold /collection:$TfsDefaultCollection /workspace:$workspace /map "$tfsPath" "$localPath"

  popd
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
    [string] $collection = $TfsDefaultCollection,
    [switch] $removeLocal = $true
  )

  if ($collection -eq "")
  {
    throw "The collection is blank (if not supplied, it also means the environment variable 'TfsDefaultCollection' is also empty)"
  }

  if ($workspace -eq "")
  {
      throw "Usage: tf -workspace BLAH"
  }

  $workFolds = Get-WorkFolds -workspace $workspace -excludeCloaked

  tf workspace /delete $workspace /collection:$collection

  if ($removeLocal = $true)
  {
    ForEach($workFold in $workFolds)
    {
      if (Test-Path $workFold.localPath)
      {
        Remove-Item -recurse -force -confirm -Path $workFold.localPath
      }
    }
  }

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
    [string] $collection = $TfsDefaultCollection,
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

function Get-Workfolds
{
  param
  (
    [string] $collection = $TfsDefaultCollection,
    [string] $workspace = $(throw "workspace is mandatory, please provide a value"),
    [switch] $excludeCloaked
  )

  if ($collection -eq "")
  {
    throw "The collection is blank (if not supplied, it also means the environment variable 'TfsDefaultCollection' is also empty)"
  }

  [string[]] $rawWorkFolds = tf workfold /workspace:$workspace /collection:$collection | Select-Object -Skip 3
  [PSObject[]] $workFolds = @();

  foreach($rawWorkFold in $rawWorkFolds)
  {
    [PSObject] $dataPair = $null;
    [string[]] $workFold = @()
    if ($rawWorkFold -match ".*(cloaked).*")
    {
      if ($excludeCloaked -eq $false)
      {
        $workFold = $rawWorkFold.Trim(' ') -split ' ';
        $dataPair = New-Object -type PSObject -Prop @{"type" = $workFold[0]; "tfsPath" = $workFold[1].TrimEnd(':'); "localPath" = ""}; 
        $workFolds += $dataPair; 
      }
    }
    else
    {
      $workFold = $rawWorkFold.Trim(' ') -split ': ';
      $dataPair = New-Object -type PSObject -Prop @{"type" = "normal"; "tfsPath" = $workFold[0]; "localPath" = $workFold[1]}; 
      $workFolds += $dataPair; 
    }
  }

  return  $workFolds;
}

function Get-ParentBranch 
{
  try
  {
    $BranchPath = tf workfold | select -skip 3 @{Name="BranchPath";Expression={($_ -split ":")[0].Trim()}} | select -ExpandProperty "BranchPath"
    $BranchesCommand =  "tf branches " + $BranchPath
    $Branches = Invoke-Expression -Command $BranchesCommand 
    $BranchLineIndex = $Branches | Select-String -pattern ">>.*" | Select-Object -last 1 -ExpandProperty "LineNumber"
  }
  catch 
  {
    throw $_.Exception
  }
  if ($BranchLineIndex -le 0)
  {
    throw "Branch $BranchPath not found on branches list" 
  }
  elseif ($BranchLineIndex -eq 1)
  {
    throw "Branch $BranchPath is at the root level, no parent will be found with this method"
  }
  else
  {
    $regex = New-Object System.Text.RegularExpressions.Regex('\t', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $baseTabCount = 0
    $parentBranch = ""
    for($currentIndex = $BranchLineIndex; $currentIndex -gt 0; $currentIndex--)
    {
      $currentBranchLine = $Branches[$currentIndex - 1];
      if ($currentIndex -eq $BranchLineIndex)
      {
        $tabSectionMatch = $currentBranchLine -match '^>>(.*?)(\$[^\t]*)\t?(.*?)'
        $tabSection = $matches[1]
        $tabMatches = $regex.Matches($tabSection)
        $baseTabCount = $tabMatches.Count
      }
      else
      {
        $tabSectionMatch = $currentBranchLine -match '^(.*?)(\$[^\t]*)\t?(.*?)'
        $tabSection = $matches[1]
        $tabMatches = $regex.Matches($tabSection)
        if ($tabMatches.Count -lt $baseTabCount)
        {
          $parentBranch = $matches[2]
          break 
        }
      }
    }

    if ($parentBranch -eq "")
    {
      throw "Could not find a parent branch (value is blank)"
    }

    return $parentBranch
  }
}

function Merge-FromParent
{
  param
  (
    [switch] $preview = $false
  )

  $parentBranch = Get-ParentBranch
  if ($parentBranch -eq "")
  {
    throw "Could not find a parent branch in the current folder"
  }

  $mergeCommand = "tf merge $parentBranch . -recursive -format:detailed"
  if ($preview)
  {
     $mergeCommand = $mergeCommand + " -preview"
  }

  Invoke-Expression $mergeCommand
   
}

# Exports
Export-ModuleMember -function Add-Workspace
Export-ModuleMember -function Remove-Workspace
Export-ModuleMember -function Get-Workspaces
Export-ModuleMember -function Reset-Workspace
Export-ModuleMember -function Get-Workfolds
Export-ModuleMember -function Get-ParentBranch
Export-ModuleMember -function Merge-FromParent

