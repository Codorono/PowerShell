#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function Get-ConsoleWindow
{
    [Win32.Console]::GetConsoleWindow()
}

#===================================================================================================

function Test-StdOutputConsole
{
    $Console = $false

    # get standard output handle

    $StdOutputHandle = [Win32.Console]::GetStdHandle($STD_OUTPUT_HANDLE)

    if (($StdOutputHandle -ne [System.IntPtr]::Zero) -and ($StdOutputHandle -ne $INVALID_HANDLE_VALUE))
    {
        # determine if standard output is character device

        if ([Win32.Console]::GetFileType($StdOutputHandle) -eq $FILE_TYPE_CHAR)
        {
            # determine if standard output is console buffer

            $NotUsed = 0

            $Console = ([Win32.Console]::GetConsoleMode($StdOutputHandle, [ref] $NotUsed) -ne 0)
        }
    }

    $Console
}

#===================================================================================================

function Enable-ConsoleVTProcessing
{
    # get screen buffer

    $Screen = [Win32.Console]::CreateFileW("CONOUT$", ($GENERIC_READ -bor $GENERIC_WRITE),
        $FILE_SHARE_WRITE, [System.IntPtr]::Zero, $OPEN_EXISTING, 0, [System.IntPtr]::Zero)

    if ($Screen -eq $INVALID_HANDLE_VALUE)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # get console mode

    $ConsoleMode = 0

    if ([Win32.Console]::GetConsoleMode($Screen, [ref] $ConsoleMode) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # determine if console mode needs adjustment

    if (($ConsoleMode -band $ENABLE_VIRTUAL_TERMINAL_PROCESSING) -eq 0)
    {
        # set console mode

        $ConsoleMode = $ConsoleMode -bor $ENABLE_VIRTUAL_TERMINAL_PROCESSING

        if ([Win32.Console]::SetConsoleMode($Screen, $ConsoleMode) -eq 0)
        {
            throw (New-Object "System.ComponentModel.Win32Exception")
        }

        Write-Output ("Console mode: 0x{0:X8}" -f $ConsoleMode)
    }

    # close screen buffer

    if ([Win32.Kernel32]::CloseHandle($Screen) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }
}

#===================================================================================================

function Clear-Screen
{
    # get screen buffer

    $Screen = [Win32.Console]::CreateFileW("CONOUT$", ($GENERIC_READ -bor $GENERIC_WRITE),
        $FILE_SHARE_WRITE, [System.IntPtr]::Zero, $OPEN_EXISTING, 0, [System.IntPtr]::Zero)

    if ($Screen -eq $INVALID_HANDLE_VALUE)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # get console screen buffer info

    $ConsoleScreenBufferInfo = New-Object "Win32.Console+CONSOLE_SCREEN_BUFFER_INFO"

    if ([Win32.Console]::GetConsoleScreenBufferInfo($Screen, [ref] $ConsoleScreenBufferInfo) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # get fill size

    $FillSize = $ConsoleScreenBufferInfo.dwSize.X * $ConsoleScreenBufferInfo.dwCursorPosition.Y

    # get top left coord

    $Coord = New-Object "Win32.Console+COORD"

    $Coord.X = 0
    $Coord.Y = 0

    # fill screen buffer with spaces

    $FillCount = 0

    if ([Win32.Console]::FillConsoleOutputCharacterW($Screen, [char] " ", $FillSize, $Coord, [ref] $FillCount) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # fill screen buffer attributes

    if ([Win32.Console]::FillConsoleOutputAttribute($Screen, $ConsoleScreenBufferInfo.wAttributes, $FillSize, $Coord, [ref] $FillCount) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # move cursor to top left corner

    if ([Win32.Console]::SetConsoleCursorPosition($Screen, $Coord) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # close screen buffer

    if ([Win32.Kernel32]::CloseHandle($Screen) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }
}

#===================================================================================================

function Set-ConsoleBackgroundColor
{
    $Color = [System.Drawing.Color]::Empty

    if ($args.Count -eq 0)
    {
        # get default color

        $Color = [System.Drawing.ColorTranslator]::FromWin32((Get-ItemPropertyValue -Path "HKCU:\Console" -Name "ColorTable00"))
    }

    elseif ($args.Count -eq 1)
    {
        $Arg = $args[0]

        # use integer color

        if ($Arg -is [int])
        {
            $Color = [System.Drawing.ColorTranslator]::FromWin32($Arg)
        }

        # use html or named color

        elseif ($Arg -is [string])
        {
            $Color = [System.Drawing.ColorTranslator]::FromHtml($Arg)
        }

        # use .net color

        elseif ($Arg -is [System.Drawing.Color])
        {
            $Color = $Arg
        }

        # use rgb array

        elseif (($Arg -is [System.Object[]]) -and ($Arg.Count -eq 3))
        {
            $Color = [System.Drawing.Color]::FromArgb($Arg[0], $Arg[1], $Arg[2])
        }
    }

    # use rgb triple

    elseif ($args.Count -eq 3)
    {
        $Red, $Green, $Blue = $args

        $Color = [System.Drawing.Color]::FromArgb($Red, $Green, $Blue)
    }

    # make sure color is valid

    if ($Color.IsEmpty)
    {
        throw "Set-ConsoleBackgroundColor: Invalid color"
    }

    # get screen buffer

    $Screen = [Win32.Console]::CreateFileW("CONOUT$", ($GENERIC_READ -bor $GENERIC_WRITE),
        $FILE_SHARE_WRITE, [System.IntPtr]::Zero, $OPEN_EXISTING, 0, [System.IntPtr]::Zero)

    if ($Screen -eq $INVALID_HANDLE_VALUE)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # create console screen buffer info structure

    $ConsoleScreenBufferInfo = New-Object "Win32.Console+CONSOLE_SCREEN_BUFFER_INFOEX"

    $ConsoleScreenBufferInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($ConsoleScreenBufferInfo)

    # get console screen buffer info

    if ([Win32.Console]::GetConsoleScreenBufferInfoEx($Screen, [ref] $ConsoleScreenBufferInfo) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # set console background color

    $ConsoleScreenBufferInfo.ColorTable[0] = [System.Drawing.ColorTranslator]::ToWin32($Color)

    # compensate for windows bug

    $WindowRect = $ConsoleScreenBufferInfo.srWindow

    $WindowRect.Right += 1
    $WindowRect.Bottom += 1

    $ConsoleScreenBufferInfo.srWindow = $WindowRect

    # set console screen buffer info

    if ([Win32.Console]::SetConsoleScreenBufferInfoEx($Screen, [ref] $ConsoleScreenBufferInfo) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # close screen buffer

    if ([Win32.Kernel32]::CloseHandle($Screen) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }
}

#===================================================================================================

function Set-ConsoleColorScheme([string] $Scheme)
{
    $Colors = @()
    $Attributes = 0x0007
    $PopupAttributes = 0x00F5

    if ($Scheme.Length -eq 0)
    {
        # get colors from registry

        for ($Color = 0; $Color -lt 16; $Color++)
        {
            $Colors += Get-ItemPropertyValue -Path "HKCU:\Console" -Name ("ColorTable{0:d2}" -f $Color)
        }

        $Attributes = Get-ItemPropertyValue -Path "HKCU:\Console" -Name "ScreenColors"
        $PopupAttributes = Get-ItemPropertyValue -Path "HKCU:\Console" -Name "PopupColors"
    }

    else
    {
        switch ($Scheme)
        {
            "Campbell"
            {
                $Colors = 0x0C0C0C, 0xDA3700, 0x0EA113, 0xDD963A, 0x1F0FC5, 0x981788, 0x009CC1, 0xCCCCCC,
                    0x767676, 0xFF783B, 0x0CC616, 0xD6D661, 0x5648E7, 0x9E00B4, 0xA5F1F9, 0xF2F2F2
            }

            "Vintage"
            {
                $Colors = 0x000000, 0x800000, 0x008000, 0x808000, 0x000080, 0x800080, 0x008080, 0xC0C0C0,
                    0x808080, 0xFF0000, 0x00FF00, 0xFFFF00, 0x0000FF, 0xFF00FF, 0x00FFFF, 0xFFFFFF
            }

            "OneHalfDark"
            {
                $Colors = 0x342C28, 0xEFAF61, 0x79C398, 0xC2B656, 0x756CE0, 0xDD78C6, 0x7BC0E5, 0xE4DFDC,
                    0x74635A, 0xEFAF61, 0x79C398, 0xC2B656, 0x756CE0, 0xDD78C6, 0x7BC0E5, 0xE4DFDC
            }

            "OneHalfLight"
            {
                $Colors = 0x423A38, 0xBC8401, 0x4FA150, 0xB39709, 0x4956E4, 0xA426A6, 0x0183C1, 0xFAFAFA,
                    0x5D524F, 0xEFAF61, 0x79C398, 0xC1B556, 0x756CDF, 0xDD77C5, 0x7AC0E4, 0xFFFFFF

                $Attributes = 0x0070
            }

            "SolarizedDark"
            {
                $Colors = 0x423607, 0xD28B26, 0x009985, 0x98A12A, 0x2F32DC, 0x8236D3, 0x0089B5, 0xD5E8EE,
                    0x362B00, 0x969483, 0x756E58, 0xA1A193, 0x164BCB, 0xC4716C, 0x837B65, 0xE3F6FD

                $Attributes = 0x0089
            }

            "SolarizedLight"
            {
                $Colors = 0x423607, 0xD28B26, 0x009985, 0x98A12A, 0x2F32DC, 0x8236D3, 0x0089B5, 0xD5E8EE,
                    0x362B00, 0x969483, 0x756E58, 0xA1A193, 0x164BCB, 0xC4716C, 0x837B65, 0xE3F6FD

                $Attributes = 0x00FE
            }

            "TangoDark"
            {
                $Colors = 0x000000, 0xA46534, 0x069A4E, 0x9A9806, 0x0000CC, 0x7B5075, 0x00A0C4, 0xCFD7D3,
                    0x535755, 0xCF9F72, 0x34E28A, 0xE2E234, 0x2929EF, 0xA87FAD, 0x4FE9FC, 0xECEEEE
            }

            "TangoLight"
            {
                $Colors = 0x000000, 0xA46534, 0x069A4E, 0x9A9806, 0x0000CC, 0x7B5075, 0x00A0C4, 0xCFD7D3,
                    0x535755, 0xCF9F72, 0x34E28A, 0xE2E234, 0x2929EF, 0xA87FAD, 0x4FE9FC, 0xECEEEE

                $Attributes = 0x00F8
            }

            "Windows10"
            {
                $Colors = 0x0C0C0C, 0xDA3700, 0x0EA113, 0xDD963A, 0x1F0FC5, 0x981788, 0x009CC1, 0xCCCCCC,
                    0x767676, 0xFF783B, 0x0CC616, 0xD6D661, 0x5648E7, 0x9E00B4, 0xA5F1F9, 0xF2F2F2
            }

            "PowerShell"
            {
                $Colors = 0x0C0C0C, 0xDA3700, 0x0EA113, 0xDD963A, 0x1F0FC5, 0x562401, 0xF0EDEE, 0xCCCCCC,
                    0x767676, 0xFF783B, 0x0CC616, 0xD6D661, 0x5648E7, 0x9E00B4, 0xA5F1F9, 0xF2F2F2

                $Attributes = 0x0056
                $PopupAttributes = 0x00F3
            }

            "Pmac"
            {
                $Colors = 0x000000, 0xEFAF61, 0x0CC616, 0xE2E234, 0x5648E7, 0xDD78C6, 0x4FE9FC, 0xF2F2F2,
                    0xC0C0C0, 0xEFAF61, 0x0CC616, 0xE2E234, 0x5648E7, 0xDD78C6, 0x4FE9FC, 0xFFFFFF
            }

            "PmacLight"
            {
                $Colors = 0xFFFFFF, 0xFF0000, 0x008000, 0xFF8000, 0x0000FF, 0xFF00FF, 0x0080FF, 0x000000,
                    0x404040, 0xFF0000, 0x008000, 0xFF8000, 0x0000FF, 0xFF00FF, 0x0080FF, 0x000000
            }

            default { throw "Set-ConsoleColorScheme: Invalid scheme: '$Scheme'" }
        }
    }

    # get screen buffer

    $Screen = [Win32.Console]::CreateFileW("CONOUT$", ($GENERIC_READ -bor $GENERIC_WRITE),
        $FILE_SHARE_WRITE, [System.IntPtr]::Zero, $OPEN_EXISTING, 0, [System.IntPtr]::Zero)

    if ($Screen -eq $INVALID_HANDLE_VALUE)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # create console screen buffer info structure

    $ConsoleScreenBufferInfo = New-Object "Win32.Console+CONSOLE_SCREEN_BUFFER_INFOEX"

    $ConsoleScreenBufferInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($ConsoleScreenBufferInfo)

    # get console screen buffer info

    if ([Win32.Console]::GetConsoleScreenBufferInfoEx($Screen, [ref] $ConsoleScreenBufferInfo) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # set console colors

    for ($Color = 0; $Color -lt 16; $Color++)
    {
        $ConsoleScreenBufferInfo.ColorTable[$Color] = $Colors[$Color]
    }

    $ConsoleScreenBufferInfo.wAttributes = $Attributes
    $ConsoleScreenBufferInfo.wPopupAttributes = $PopupAttributes

    # compensate for windows bug

    $WindowRect = $ConsoleScreenBufferInfo.srWindow

    $WindowRect.Right += 1
    $WindowRect.Bottom += 1

    $ConsoleScreenBufferInfo.srWindow = $WindowRect

    # set console screen buffer info

    if ([Win32.Console]::SetConsoleScreenBufferInfoEx($Screen, [ref] $ConsoleScreenBufferInfo) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }

    # close screen buffer

    if ([Win32.Kernel32]::CloseHandle($Screen) -eq 0)
    {
        throw (New-Object "System.ComponentModel.Win32Exception")
    }
}

#===================================================================================================

Set-Variable -Name "STD_INPUT_HANDLE" -Value 0xFFFFFFF6u -Option Constant
Set-Variable -Name "STD_OUTPUT_HANDLE" -Value 0xFFFFFFF5u -Option Constant
Set-Variable -Name "STD_ERROR_HANDLE" -Value 0xFFFFFFF4u -Option Constant

Set-Variable -Name "GENERIC_READ" -Value 0x80000000u -Option Constant
Set-Variable -Name "GENERIC_WRITE" -Value 0x40000000u -Option Constant

Set-Variable -Name "FILE_SHARE_READ" -Value 0x00000001u -Option Constant
Set-Variable -Name "FILE_SHARE_WRITE" -Value 0x00000002u -Option Constant
Set-Variable -Name "FILE_SHARE_DELETE" -Value 0x00000004u -Option Constant

Set-Variable -Name "CREATE_NEW" -Value 1u -Option Constant
Set-Variable -Name "CREATE_ALWAYS" -Value 2u -Option Constant
Set-Variable -Name "OPEN_EXISTING" -Value 3u -Option Constant
Set-Variable -Name "OPEN_ALWAYS" -Value 4u -Option Constant
Set-Variable -Name "TRUNCATE_EXISTING" -Value 5u -Option Constant

Set-Variable -Name "FILE_TYPE_UNKNOWN" -Value 0x0000u -Option Constant
Set-Variable -Name "FILE_TYPE_DISK" -Value 0x0001u -Option Constant
Set-Variable -Name "FILE_TYPE_CHAR" -Value 0x0002u -Option Constant
Set-Variable -Name "FILE_TYPE_PIPE" -Value 0x0003u -Option Constant
Set-Variable -Name "FILE_TYPE_REMOTE" -Value 0x8000u -Option Constant

Set-Variable -Name "ENABLE_VIRTUAL_TERMINAL_PROCESSING" -Value 0x0004u -Option Constant

Set-Variable -Name "INVALID_HANDLE_VALUE" -Value ([System.IntPtr] -1) -Option Constant

#===================================================================================================

$MemberDefinition =
@"
[StructLayout(LayoutKind.Sequential)]
public struct COORD
{
    public short X;
    public short Y;
}

[StructLayout(LayoutKind.Sequential)]
public struct SMALL_RECT
{
    public short Left;
    public short Top;
    public short Right;
    public short Bottom;
}

[StructLayout(LayoutKind.Sequential)]
public struct CONSOLE_SCREEN_BUFFER_INFO
{
    public COORD dwSize;
    public COORD dwCursorPosition;
    public ushort wAttributes;
    public SMALL_RECT srWindow;
    public COORD dwMaximumWindowSize;
}

[StructLayout(LayoutKind.Sequential)]
public struct CONSOLE_SCREEN_BUFFER_INFOEX
{
    public uint cbSize;
    public COORD dwSize;
    public COORD dwCursorPosition;
    public ushort wAttributes;
    public SMALL_RECT srWindow;
    public COORD dwMaximumWindowSize;
    public ushort wPopupAttributes;
    public int bFullscreenSupported;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
    public uint[] ColorTable;
}

[DllImport("kernel32.dll", ExactSpelling = true)]
public static extern System.IntPtr GetConsoleWindow();

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern System.IntPtr GetStdHandle(uint nStdHandle);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern uint GetFileType(System.IntPtr hFile);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int GetConsoleMode(System.IntPtr hConsoleHandle, out uint lpMode);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int SetConsoleMode(System.IntPtr hConsoleHandle, uint dwMode);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int GetConsoleScreenBufferInfo(System.IntPtr hConsoleOutput,
    ref CONSOLE_SCREEN_BUFFER_INFO lpConsoleScreenBufferInfo);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int GetConsoleScreenBufferInfoEx(System.IntPtr hConsoleOutput,
    ref CONSOLE_SCREEN_BUFFER_INFOEX lpConsoleScreenBufferInfoEx);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int SetConsoleScreenBufferInfoEx(System.IntPtr hConsoleOutput,
    ref CONSOLE_SCREEN_BUFFER_INFOEX lpConsoleScreenBufferInfoEx);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int FillConsoleOutputCharacterW(System.IntPtr hConsoleHandle,
    char cCharacter, uint nLength, COORD dwWriteCoord, out uint lpNumberOfCharsWritten);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int FillConsoleOutputAttribute(System.IntPtr hConsoleHandle,
    ushort wAttribute, uint nLength, COORD dwWriteCoord, out uint lpNumberOfAttrsWritten);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int SetConsoleCursorPosition(
    System.IntPtr hConsoleHandle, COORD dwCursorPosition);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern System.IntPtr CreateFileW(
    [MarshalAs(UnmanagedType.LPWStr)] string lpFileName, uint dwDesiredAccess, uint dwShareMode,
    System.IntPtr lpSecurityAttributes, uint dwCreationDisposition, uint dwFlagsAndAttributes,
    System.IntPtr hTemplateFile);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int CloseHandle(System.IntPtr hObject);
"@

Add-Type -MemberDefinition $MemberDefinition -Name "Console" -Namespace "Win32"

# Types are:
# Win32.Console
# Win32.Console+COORD
# Win32.Console+SMALL_RECT
# Win32.Console+CONSOLE_SCREEN_BUFFER_INFO
# Win32.Console+CONSOLE_SCREEN_BUFFER_INFOEX

#===================================================================================================
