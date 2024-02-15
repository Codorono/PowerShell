#=======================================================================================================================

[CmdletBinding(DefaultParameterSetName = "Path")]
param
(
	[Parameter(Mandatory, Position = 0)]
	[string] $HashFile,

	[Parameter(Position = 1, ParameterSetName = "Path")]
	[SupportsWildCards()]
	[string[]] $Path,

	[Parameter(Position = 2)]
	[SupportsWildCards()]
	[string] $Filter,

	[Parameter(ParameterSetName = "LiteralPath")]
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

# iterate through lines of hash file

Get-Content $HashFile | ForEach-Object `
{
	$Hash = $_.Substring(0, 32)
	$File = $_.Substring(33)

	# determine if hash is duplicate

	if ($Hashes.ContainsKey($Hash))
	{
		Write-Host ($File + " is identical to " + $Hashes[$Hash]) -ForegroundColor Red
	}

	# add file to hash table

	else
	{
		$Hashes.Add($Hash, $File)
	}
}

# iterate through files

[void] $PSBoundParameters.Remove("HashFile")

Get-ChildItem @PSBoundParameters -Attributes !Offline -File | ForEach-Object `
{
	# get file hash

	$Hash = (Get-FileHash -LiteralPath $_ -Algorithm MD5).Hash

	# determine if hash is duplicate

	if ($Hashes.ContainsKey($Hash))
	{
		Write-Output ($_.FullName + " is identical to " + $Hashes[$Hash])
	}
}

#=======================================================================================================================
