#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

# Set F6 for location history

Set-PSReadlineKeyHandler -Chord "F6" -ScriptBlock `
{
    # get match string from command prompt

    $Match = $null

    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $Match, [ref] $null)

    # get location history file path

    $HistoryFolder = [System.IO.Path]::GetDirectoryName((Get-PSReadlineOption).HistorySavePath)
    $LocHistFilePath = Join-Path $HistoryFolder "ConsoleHost_lochist.txt"

    if (Test-Path $LocHistFilePath)
    {
        # list of locations

        $LocationList = New-Object "System.Collections.ArrayList"

        # iterate through lines of location history file

        Get-Content -Path $LocHistFilePath | ForEach-Object `
        {
            # skip blank lines

            if ($_ -ne "")
            {
                $Location = $_

                # make sure location is valid

                if (($Match -eq "") -or ($Location -like "*$Match*"))
                {
                    # remove duplicate location from list

                    $LocationList.Remove($Location)

                    # add location to end of list

                    $LocationList.Add($Location) | Out-Null
                }
            }
        }

        if ($LocationList.Count -eq 0)
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
        }

        else
        {
            # put most recent locations at top of list

            $LocationList.Reverse()

            # display location history in gridview

            $Location = $LocationList | Out-GridView -Title "Locations" -Outputmode Single

            if ($Location -ne $null)
            {
                Set-LocationEx -Path $Location

                [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
            }
        }
    }
}

#===================================================================================================

# Set F7 for recent command history

Set-PSReadLineKeyHandler -Chord "F7" -ScriptBlock `
{
    # get match string from command prompt

    $Match = $null

    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $Match, [ref] $null)

    # list of commands

    $CommandList = New-Object "System.Collections.ArrayList"

    # iterate through history items

    [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems() | ForEach-Object `
    {
        # get command

        $Command = $_.CommandLine

        # make sure command is valid

        if (($Match -eq "") -or ($Command -like "*$Match*"))
        {
            # remove duplicate command from list

            $CommandList.Remove($Command)

            # add command to end of list

            $CommandList.Add($Command) | Out-Null
        }
    }

    if ($CommandList.Count -eq 0)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
    }

    else
    {
        # put most recent commands at top of list

        $CommandList.Reverse()

        # display command history in gridview

        $Command = $CommandList | Out-GridView -Title "Commands" -Outputmode Single

        if ($Command -ne $null)
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($Command)
        }
    }
}

#===================================================================================================

# Set Ctrl-F7 for complete command history

Set-PSReadLineKeyHandler -Chord "Ctrl+F7" -ScriptBlock `
{
    # get match string from command prompt

    $Match = $null

    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $Match, [ref] $null)

    # get command history file path

    $HistoryFilePath = (Get-PSReadlineOption).HistorySavePath

    if (Test-Path $HistoryFilePath)
    {
        # list of commands

        $CommandList = New-Object "System.Collections.ArrayList"

        # iterate through lines of history file

        $Command = ""

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
                    # make sure command is valid

                    if (($Match -eq "") -or ($Command -like "*$Match*"))
                    {
                        # remove duplicate command from list

                        $CommandList.Remove($Command)

                        # add command to end of list

                        $CommandList.Add($Command) | Out-Null
                    }

                    # start new command

                    $Command = ""
                }
            }
        }

        if ($CommandList.Count -eq 0)
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
        }

        else
        {
            # put most recent commands at top of list

            $CommandList.Reverse()

            # display command history in gridview

            $Command = $CommandList | Out-GridView -Title "Commands" -Outputmode Single

            if ($Command -ne $null)
            {
                [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($Command)
            }
        }
    }
}

#===================================================================================================
