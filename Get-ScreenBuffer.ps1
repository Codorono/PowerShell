#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

# get screen buffer rectangle

$Width = $Host.UI.RawUI.BufferSize.Width
$Height = $Host.UI.RawUI.CursorPosition.Y

$Rectangle = New-Object "System.Management.Automation.Host.Rectangle" 0, 0, $Width, $Height

# get screen buffer contents

$Buffer = $Host.UI.RawUI.GetBufferContents($Rectangle)

# iterate through screen buffer lines

$Line = New-Object "System.Text.StringBuilder" $Width

for ($Row = 0; $Row -lt $Height; $Row++)
{
    # concatenate line chars

    [void] $Line.Clear()

    for ($Col = 0; $Col -lt $Width; $Col++)
    {
        [void] $Line.Append(($Buffer[$Row, $Col]).Character)
    }

    # output line

    Write-Output $Line.ToString().TrimEnd()
}

#===================================================================================================
