#=======================================================================================================================

Set-StrictMode -Version Latest

#=======================================================================================================================

function prompt
{
	# get current path

	$PathInfo = $ExecutionContext.SessionState.Path.CurrentLocation

	$CurrentPath = ($PathInfo.Drive -ne $null) ? $PathInfo.Path : $PathInfo.ProviderPath

	# abbreviate home directory

	if ($CurrentPath.StartsWith($Home, [System.StringComparison]::OrdinalIgnoreCase))
	{
		$CurrentPath = "~" + $CurrentPath.SubString($Home.Length)
	}

	# set window title

	$Administrator = (Test-Administrator) ? "Administrator: " : ""

	$Instance = (Test-Path "Variable:ConsoleTitle") ? "$ConsoleTitle - " : ""

	$Version = $PSVersionTable.PSVersion

	$Arch = Get-ProcessArchitecture

	$WindowTitle = "{0}{1}PowerShell {2}.{3}.{4} ({5}) {6}" -f $Administrator, $Instance, $Version.Major,
		$Version.Minor, $Version.Patch, $Arch, $CurrentPath

	$Host.UI.RawUI.WindowTitle = $WindowTitle

	# set prompt

	"{0}{1} " -f $CurrentPath, (">" * ($NestedPromptLevel + 1))
}

#=======================================================================================================================
