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

$StringBuilder = [System.Text.StringBuilder]::new($Width)

# iterate through screen buffer lines

for ($Row = 0; $Row -lt $Height; $Row++)
{
	# empty line chars buffer

	[void] $StringBuilder.Clear()

	# concatenate line chars

	for ($Col = 0; $Col -lt $Width; $Col++)
	{
		[void] $StringBuilder.Append(($ScreenBuffer[$Row, $Col]).Character)
	}

	# output line

	Write-Output $StringBuilder.ToString().TrimEnd()
}

#=======================================================================================================================
