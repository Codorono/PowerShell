#===================================================================================================

param
(
    [int] $MaxCommandCount = 0,
    [switch] $IgnoreCase,
    [switch] $Verbose
)

#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

# list of commands

$CommandList = [System.Collections.Generic.List[string]]::new(50000)

# get history file path

$HistoryFilePath = (Get-PSReadlineOption).HistorySavePath

# iterate through lines of history file

$Command = ""
$OldCommandCount = 0

Get-Content $HistoryFilePath | ForEach-Object `
{
    # skip blank lines

    if ($_.Length -ne 0)
    {
        # deal with multi-line commands

        if ($Command.Length -ne 0)
        {
            $Command += "`n"
        }

        $Command += $_

        # make sure command is complete

        if (-not $Command.EndsWith("``"))
        {
            if ($IgnoreCase)
            {
                # look for command in list

                if ([System.Linq.Enumerable]::Contains($CommandList, $Command, [System.StringComparer]::OrdinalIgnoreCase))
                {
                    $Predicate = { param($Item) ([System.String]::Compare($Item, $Command, $true) -eq 0) }

                    $Index = $CommandList.FindIndex($Predicate)

                    if ($Index -ne -1)
                    {
                        # remove previous command from list

                        $Remove = $CommandList[$Index]

                        $CommandList.RemoveAt($Index)

                        if ($Verbose)
                        {
                            Write-Host "Removed $Remove" -ForegroundColor Yellow
                        }
                    }
                }
            }

            else
            {
                # look for command in list

                $Index = $CommandList.IndexOf($Command)

                if ($Index -ne -1)
                {
                    # remove previous command from list

                    $CommandList.RemoveAt($Index)

                    if ($Verbose)
                    {
                        Write-Host "Removed $Command" -ForegroundColor Yellow
                    }
                }
            }

            # add command to end of list

            $CommandList.Add($Command)

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

Set-Content $HistoryFilePath $CommandList -Encoding utf8NoBOM

# show statistics

$DifCommandCount = $OldCommandCount - $NewCommandCount

Write-Host ("{0} duplicate command{1} removed, {2} command{3} retained" -f $DifCommandCount, (Get-Plural $DifCommandCount),
    $NewCommandCount, (Get-Plural $NewCommandCount)) -ForegroundColor Cyan

#===================================================================================================
