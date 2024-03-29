﻿#=======================================================================================================================

[CmdletBinding(DefaultParameterSetName = "Path")]
param
(
	[Parameter(Position = 0, ParameterSetName = "Path", ValueFromPipeline, ValueFromPipelineByPropertyName)]
	[SupportsWildCards()]
	[string[]] $Path,

	[Parameter(Position = 1)]
	[SupportsWildCards()]
	[string] $Filter,

	[Parameter(ParameterSetName = "LiteralPath", ValueFromPipelineByPropertyName)]
	[Alias("PSPath")]
	[Alias("LP")]
	[string[]] $LiteralPath,

	[SupportsWildCards()]
	[string[]] $Include,

	[SupportsWildCards()]
	[string[]] $Exclude,

	[switch] $Recurse,
	[uint] $Depth,
	[switch] $Force
)

#=======================================================================================================================

Set-StrictMode -Version Latest

#=======================================================================================================================

# hash table

$Hashes = @{}

# iterate through files

Get-ChildItem @PSBoundParameters -Attributes !Offline -File | ForEach-Object `
{
	# get file hash

	$Hash = (Get-FileHash -LiteralPath $_ -Algorithm MD5).Hash

	# determine if hash is duplicate

	if ($Hashes.ContainsKey($Hash))
	{
		$File = $Hashes[$Hash]

		Write-Host ($_.FullName + " is identical to " + $File) -ForegroundColor Red
	}

	# add file to hash table

	else
	{
		$Hashes.Add($Hash, $_.FullName)

		Write-Output ($Hash + " " + $_.FullName)
	}
}

#=======================================================================================================================
