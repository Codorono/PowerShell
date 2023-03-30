#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function Set-LocationEx
{
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param
    (
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Path", ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Path,

        [Parameter(Mandatory, ParameterSetName = "LiteralPath", ValueFromPipelineByPropertyName)]
        [Alias("PSPath")]
        [Alias("LP")]
        [string] $LiteralPath,

        [switch] $PassThru
    )

    # set location

    Set-Location @PSBoundParameters

    # make sure location history file exists

    $HistoryFolder = [System.IO.Path]::GetDirectoryName((Get-PSReadlineOption).HistorySavePath)
    $LocHistFilePath = Join-Path $HistoryFolder "ConsoleHost_lochist.txt"

    if (-not (Test-Path $LocHistFilePath))
    {
        New-Item -Path $LocHistFilePath | Out-Null
    }

    # get current location

    $PathInfo = $ExecutionContext.SessionState.Path.CurrentLocation

    $CurrentPath = ($PathInfo.Drive -ne $null) ? $PathInfo.Path : $PathInfo.ProviderPath

    # add current location to location history file

    Add-Content -Path $LocHistFilePath -Value $CurrentPath -Encoding UTF8NoBOM
}

#===================================================================================================

Set-Alias "cd" Set-LocationEx -Option AllScope

#===================================================================================================
