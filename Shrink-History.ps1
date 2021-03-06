﻿param
(
    [int] $MaxCommandCount = -1,
    [switch] $Verbose
)

Set-StrictMode -Version Latest

# list of commands

$CommandList = New-Object "System.Collections.ArrayList"

# get history file path

$HistoryFilePath = (Get-PSReadlineOption).HistorySavePath

# iterate through lines of history file

$Command = ""
$OldCommandCount = 0

Get-Content -Path $HistoryFilePath | ForEach-Object `
{
    # skip blank lines

    if ($_ -ne "")
    {
        # deal with multi-line commands

        if ($Command -ne "") { $Command += "`n" }

        $Command += $_

        # make sure command is complete

        if (-not $Command.EndsWith('`'))
        {
            # look for command in list

            $Index = $CommandList.IndexOf($Command)

            if ($Index -ne -1)
            {
                # remove previous command from list

                $CommandList.RemoveAt($Index)

                if ($Verbose) { "Deleted $Command" }
            }

            # add command to end of list

            $CommandList.Add($Command) | Out-Null

            $OldCommandCount += 1

            # start new command

            $Command = ""
        }
    }
}

# purge excess commands

$NewCommandCount = $CommandList.Count

if (($MaxCommandCount -gt 0) -and ($NewCommandCount -gt $MaxCommandCount))
{
    $CommandList.RemoveRange(0, $NewCommandCount - $MaxCommandCount)

    $NewCommandCount = $CommandList.Count
}

# rewrite history file

Set-Content -Path $HistoryFilePath -Value $CommandList -Encoding UTF8NoBOM

# show statistics

$DelCommandCount = $OldCommandCount - $NewCommandCount

"{0} command{1} deleted, {2} command{3} remaining" -f $DelCommandCount, (Get-Plural $DelCommandCount),
    $NewCommandCount, (Get-Plural $NewCommandCount)
