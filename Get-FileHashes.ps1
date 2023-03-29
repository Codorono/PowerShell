#===================================================================================================

param
(
    [string[]] $Path,
    [switch] $Recurse,
    [switch] $Force
)

#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

# hash table

$Hashes = @{}

# iterate through files

Get-ChildItem -Path: $Path -Recurse: $Recurse -Force: $Force -Attributes !Offline -File | ForEach-Object `
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

#===================================================================================================
