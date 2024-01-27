#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

# get screen buffer rectangle

$Width = $Host.UI.RawUI.BufferSize.Width
$Height = $Host.UI.RawUI.CursorPosition.Y

$Rectangle = [System.Management.Automation.Host.Rectangle]::new(0, 0, $Width, $Height)

# get screen buffer contents

$ScreenBuffer = $Host.UI.RawUI.GetBufferContents($Rectangle)

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

#===================================================================================================
