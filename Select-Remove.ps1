#===================================================================================================

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
    [switch] $Force,
    [System.Management.Automation.FlagsExpression[System.IO.FileAttributes]] $Attributes,
    [switch] $Directory,
    [switch] $File
)

#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

# delete selected files

if (($Recurse.IsPresent) -or
    (($PSBoundParameters.ContainsKey("Depth") -and ($Depth -ne 0))) -or
    ($PSBoundParameters.ContainsKey("Path") -and ($Path.Length -gt 1)) -or
    ($PSBoundParameters.ContainsKey("LiteralPath") -and ($LiteralPath.Length -gt 1)))
{
    Get-ChildItem @PSBoundParameters | Select-Object -Property Mode, LastWriteTime, Length, FullName | Out-GridView -Title "Select-Remove" -PassThru | ForEach-Object { Remove-Item $_.FullName -Recurse: $Recurse -Force: $Force }
}

else
{
    Get-ChildItem @PSBoundParameters | Out-GridView -Title "Select-Remove" -PassThru | Remove-Item -Recurse: $Recurse -Force: $Force
}

#===================================================================================================
