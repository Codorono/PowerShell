#=======================================================================================================================

Set-StrictMode -Version Latest

#=======================================================================================================================

$RawUI = $Host.UI.RawUI

# get screen buffer size

$Width = $RawUI.BufferSize.Width
$Height = $RawUI.CursorPosition.Y

# get screen buffer contents

$ScreenBuffer = $RawUI.GetBufferContents(@{Left = 0; Top = 0; Right = $Width; Bottom = $Height})

# get line chars buffer

$LineChars = [System.Text.StringBuilder]::new($Width)

# iterate through screen buffer lines

for ($Line = 0; $Line -lt $Height; $Line++)
{
	# get line length excluding trailing spaces

	$Length = $Width

	while (($Length -gt 0) -and ($ScreenBuffer[$Line, ($Length - 1)].Character -eq " "))
	{
		$Length--
	}

	# empty line chars buffer

	[void] $LineChars.Clear()

	# concatenate line chars

	for ($Column = 0; $Column -lt $Length; $Column++)
	{
		[void] $LineChars.Append(($ScreenBuffer[$Line, $Column]).Character)
	}

	# output line

	Write-Output $LineChars.ToString()
}

#=======================================================================================================================
