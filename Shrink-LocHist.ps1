﻿#=======================================================================================================================

param
(
	[int] $MaxLocationCount = 0,
	[switch] $Verbose
)

#=======================================================================================================================

Set-StrictMode -Version Latest

#=======================================================================================================================

# list of locations

$LocationList = [System.Collections.Generic.List[string]]::new(10000)

# get location history file path

$HistoryFolder = [System.IO.Path]::GetDirectoryName((Get-PSReadlineOption).HistorySavePath)
$HistoryFilePath = Join-Path $HistoryFolder "ConsoleHost_lochist.txt"

# iterate through lines of location history file

$OldLocationCount = 0

Get-Content $HistoryFilePath | ForEach-Object `
{
	# skip blank lines

	if ($_.Length -ne 0)
	{
		$Location = $_

		# make sure location exists

		if (-not (Test-Path -LiteralPath $Location))
		{
			if ($Verbose)
			{
				Write-Host "Deleted $Location" -ForegroundColor Red
			}
		}

		else
		{
			# look for location in list

			$Index = $LocationList.IndexOf($Location)

			if ($Index -ne -1)
			{
				# remove previous location from list

				$LocationList.RemoveAt($Index)

				if ($Verbose)
				{
					Write-Host "Removed $Location" -ForegroundColor Yellow
				}
			}

			# add location to end of list

			$LocationList.Add($Location)
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

Set-Content $HistoryFilePath $LocationList -Encoding utf8NoBOM

# show statistics

$DifLocationCount = $OldLocationCount - $NewLocationCount

Write-Host ("{0} duplicate location{1} removed, {2} location{3} retained" -f $DifLocationCount, (Get-Plural $DifLocationCount),
	$NewLocationCount, (Get-Plural $NewLocationCount)) -ForegroundColor Cyan

#=======================================================================================================================
