﻿function Set-LocationEx
{
    [CmdletBinding(DefaultParameterSetName="Path")]
    param
    (
        [Parameter(Position=0, ParameterSetName="Path", ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Path,

        [Parameter(ParameterSetName="LiteralPath", ValueFromPipelineByPropertyName=$true)]
        [Alias("PSPath")]
        [Alias("LP")]
        [string] $LiteralPath,

        [Parameter()]
        [switch] $PassThru
    )

    if ($PSCmdlet.ParameterSetName -eq "LiteralPath")
    {
        Set-Location -LiteralPath $LiteralPath -PassThru: $PassThru
    }

    else
    {
        Set-Location -Path $Path -PassThru: $PassThru
    }

    # make sure location history file exists

    $HistoryFolder = [System.IO.Path]::GetDirectoryName((Get-PSReadlineOption).HistorySavePath)
    $LocHistFilePath = Join-Path $HistoryFolder "ConsoleHost_lochist.txt"

    if (-not (Test-Path $LocHistFilePath)) { New-Item -Path $LocHistFilePath | Out-Null }

    # get current location

    $PathInfo = $ExecutionContext.SessionState.Path.CurrentLocation

    $CurrentLocation = ($PathInfo.Drive -ne $null) ? $PathInfo.Path : $PathInfo.ProviderPath

    # add current location to location history file

    Add-Content -Path $LocHistFilePath -Value $CurrentLocation -Encoding UTF8NoBOM
}

Set-Alias "cd" Set-LocationEx -Option AllScope
