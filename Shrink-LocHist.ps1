﻿param
(
    [int] $MaxLocationCount = -1,
    [switch] $Verbose
)

Set-StrictMode -Version Latest

# list of locations

$LocationList = New-Object "System.Collections.ArrayList"

# get location history file path

$HistoryFolder = [System.IO.Path]::GetDirectoryName((Get-PSReadlineOption).HistorySavePath)
$LocHistFilePath = Join-Path $HistoryFolder "ConsoleHost_lochist.txt"

# iterate through lines of location history file

$OldLocationCount = 0

Get-Content -Path $LocHistFilePath | ForEach-Object `
{
    # skip blank lines

    if ($_ -ne "")
    {
        $Location = $_

        # make sure location exists

        if (-not (Test-Path $Location))
        {
            if ($Verbose) { "Deleted $Location" }
        }

        else
        {
            # look for location in list

            $Index = $LocationList.IndexOf($Location)

            if ($Index -ne -1)
            {
                # remove previous location from list

                $LocationList.RemoveAt($Index)

                if ($Verbose) { "Removed $Location" }
            }

            # add location to end of list

            $LocationList.Add($Location) | Out-Null
        }

        $OldLocationCount += 1
    }
}

# purge excess locations

$NewLocationCount = $LocationList.Count

if (($MaxLocationCount -gt 0) -and ($NewLocationCount -gt $MaxLocationCount))
{
    $LocationList.RemoveRange(0, $NewLocationCount - $MaxLocationCount)

    $NewLocationCount = $LocationList.Count
}

# rewrite location history file

Set-Content -Path $LocHistFilePath -Value $LocationList -Encoding UTF8NoBOM

# show statistics

$DifLocationCount = $OldLocationCount - $NewLocationCount

"{0} location{1} removed, {2} location{3} retained" -f $DifLocationCount, (Get-Plural $DifLocationCount),
    $NewLocationCount, (Get-Plural $NewLocationCount)
