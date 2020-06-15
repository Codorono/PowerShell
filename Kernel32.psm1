#===================================================================================================

function Out-Debug
{
    [CmdletBinding()]
    param ([Parameter(Mandatory=$true, ValueFromPipeline=$true)] $Item)

    process
    {
        [Win32.Kernel32]::OutputDebugStringW($Item)
    }
}

#===================================================================================================

function Test-StdOutputConsole
{
    $Console = $false

    # get standard output handle

    $StdOutputHandle = [Win32.Kernel32]::GetStdHandle([STD_HANDLE]::OUTPUT)

    if (($StdOutputHandle -ne [System.IntPtr]::Zero) -and ($StdOutputHandle -ne $INVALID_HANDLE_VALUE))
    {
        # determine if standard output is console buffer

        $NotUsed = 0

        $Console = ([Win32.Kernel32]::GetConsoleMode($StdOutputHandle, [ref] $NotUsed) -ne 0)
    }

    $Console
}

#===================================================================================================

function Set-BackgroundPriorityMode([switch] $Begin, [switch] $End)
{
    # get process pseudo handle

    $ProcessHandle = [Win32.Kernel32]::GetCurrentProcess()

    # get requested mode

    $BackgroundMode = $Begin ? [PROCESS_MODE_BACKGROUND]::BEGIN : $End ? [PROCESS_MODE_BACKGROUND]::END : 0

    # set background mode

    if ($BackgroundMode -ne 0)
    {
        if ([Win32.Kernel32]::SetPriorityClass($ProcessHandle, $BackgroundMode) -eq 0)
        {
            throw ( New-Object "System.ComponentModel.Win32Exception" )
        }
    }

    # get priority class

    $PriorityClass = [Win32.Kernel32]::GetPriorityClass($ProcessHandle)

    if ($PriorityClass -eq 0)
    {
        throw ( New-Object "System.ComponentModel.Win32Exception" )
    }

    # display priority class name

    $PriorityClassName = switch ($PriorityClass)
    {
        ([uint] [PRIORITY_CLASS]::NORMAL) { "Normal" }
        ([uint] [PRIORITY_CLASS]::IDLE) { "Idle" }
        ([uint] [PRIORITY_CLASS]::HIGH) { "High" }
        ([uint] [PRIORITY_CLASS]::REALTIME) { "Realtime" }
        ([uint] [PRIORITY_CLASS]::BELOW_NORMAL) { "Below Normal" }
        ([uint] [PRIORITY_CLASS]::ABOVE_NORMAL) { "Above Normal" }
        default { "Unknown" }
    }

    "{0} priority class" -f $PriorityClassName
}

#===================================================================================================

function Set-ConsoleBackgroundColor
{
    # get color

    $Color = $null

    # use registry default color

    if ($args.Count -eq 0)
    {
        $Color = (Get-ItemProperty -Path "HKCU:\Console" -Name "ColorTable00").ColorTable00
    }

    # use numeric color

    elseif (($args.Count -eq 1) -and ($args[0] -is [int]))
    {
        $Color = $args[0]
    }

    # lookup color in table

    elseif (($args.Count -eq 1) -and ($args[0] -is [string]))
    {
        $Color = $Colors[$args[0]]
    }

    # use rgb color

    elseif ($args.Count -eq 3)
    {
        $Red, $Green, $Blue = $args

        $Color = ($Red -band 0xFF) -bor (($Green -band 0xFF) -shl 8) -bor (($Blue -band 0xFF) -shl 16)
    }

    # make sure color is valid

    if ($Color -eq $null)
    {
        throw "Set-ConsoleBackgroundColor: Invalid color: $args"
    }

    # get standard output handle

    $StdOutputHandle = [Win32.Kernel32]::GetStdHandle([STD_HANDLE]::OUTPUT)

    if (($StdOutputHandle -ne [System.IntPtr]::Zero) -and ($StdOutputHandle -ne $INVALID_HANDLE_VALUE))
    {
        # make sure standard output is console buffer

        $NotUsed = 0

        if ([Win32.Kernel32]::GetConsoleMode($StdOutputHandle, [ref] $NotUsed) -ne 0)
        {
            # create console screen buffer info structure

            $ConsoleScreenBufferInfo = New-Object "Win32.Kernel32+CONSOLE_SCREEN_BUFFER_INFOEX"

            $ConsoleScreenBufferInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($ConsoleScreenBufferInfo)

            # get console screen buffer info

            if ([Win32.Kernel32]::GetConsoleScreenBufferInfoEx($StdOutputHandle, [ref] $ConsoleScreenBufferInfo) -eq 0)
            {
                throw (New-Object "System.ComponentModel.Win32Exception")
            }

            # set console background color

            $ConsoleScreenBufferInfo.ColorTable[0] = $Color

            # compensate for windows bug

            $WindowRect = $ConsoleScreenBufferInfo.srWindow

            $WindowRect.Right += 1
            $WindowRect.Bottom += 1

            $ConsoleScreenBufferInfo.srWindow = $WindowRect

            # set console screen buffer info

            if ([Win32.Kernel32]::SetConsoleScreenBufferInfoEx($StdOutputHandle, [ref] $ConsoleScreenBufferInfo) -eq 0)
            {
                throw (New-Object "System.ComponentModel.Win32Exception")
            }
        }
    }
}

#===================================================================================================

function Get-MemoryInfo
{
    # get process pseudo handle

    $ProcessHandle = [Win32.Kernel32]::GetCurrentProcess()

    # create memory basic information structure

    $MemoryBasicInformation = New-Object "Win32.Kernel32+MEMORY_BASIC_INFORMATION"

    # query virtual memory

    $Result = [Win32.Kernel32]::VirtualQueryEx($ProcessHandle, [System.IntPtr] 0, [ref] $MemoryBasicInformation,
        [System.Runtime.InteropServices.Marshal]::SizeOf($MemoryBasicInformation))

    if ($Result -eq 0)
    {
        throw ( New-Object "System.ComponentModel.Win32Exception" )
    }

    $MemoryBasicInformation
}

#===================================================================================================

Set-StrictMode -Version Latest

enum STD_HANDLE
{
    OUTPUT = -11
}

enum FILE_TYPE
{
    DISK = 0x0001
    CHAR = 0x0002
    PIPE = 0x0003
}

enum PRIORITY_CLASS
{
    NORMAL = 0x00000020
    IDLE = 0x00000040
    HIGH = 0x00000080
    REALTIME = 0x00000100
    BELOW_NORMAL = 0x00004000
    ABOVE_NORMAL = 0x00008000
}

enum PROCESS_MODE_BACKGROUND
{
    BEGIN = 0x00100000
    END = 0x00200000
}

Set-Variable -Name "INVALID_HANDLE_VALUE" -Value ([System.IntPtr] -1) -Option Constant

#===================================================================================================

$Colors =
@{
    "AliceBlue" = 0xFFF8F0
    "AntiqueWhite" = 0xD7EBFA
    "Aqua" = 0xFFFF00
    "Aquamarine" = 0xD4FF7F
    "Azure" = 0xFFFFF0
    "Beige" = 0xDCF5F5
    "Bisque" = 0xC4E4FF
    "Black" = 0x000000
    "BlanchedAlmond" = 0xCDEBFF
    "Blue" = 0xFF0000
    "BlueViolet" = 0xE22B8A
    "Brown" = 0x2A2AA5
    "BurlyWood" = 0x87B8DE
    "CadetBlue" = 0xA09E5F
    "Chartreuse" = 0x00FF7F
    "Chocolate" = 0x1E69D2
    "Coral" = 0x507FFF
    "CornflowerBlue" = 0xED9564
    "Cornsilk" = 0xDCF8FF
    "Crimson" = 0x3C14DC
    "Cyan" = 0xFFFF00
    "DarkBlue" = 0x8B0000
    "DarkCyan" = 0x8B8B00
    "DarkGoldenrod" = 0x0B86B8
    "DarkGray" = 0xA9A9A9
    "DarkGreen" = 0x006400
    "DarkKhaki" = 0x6BB7BD
    "DarkMagenta" = 0x8B008B
    "DarkOliveGreen" = 0x2F6B55
    "DarkOrange" = 0x008CFF
    "DarkOrchid" = 0xCC3299
    "DarkRed" = 0x00008B
    "DarkSalmon" = 0x7A96E9
    "DarkSeaGreen" = 0x8BBC8F
    "DarkSlateBlue" = 0x8B3D48
    "DarkSlateGray" = 0x4F4F2F
    "DarkTurquoise" = 0xD1CE00
    "DarkViolet" = 0xD30094
    "DeepPink" = 0x9314FF
    "DeepSkyBlue" = 0xFFBF00
    "DimGray" = 0x696969
    "DodgerBlue" = 0xFF901E
    "Firebrick" = 0x2222B2
    "FloralWhite" = 0xF0FAFF
    "ForestGreen" = 0x228B22
    "Fuchsia" = 0xFF00FF
    "Gainsboro" = 0xDCDCDC
    "GhostWhite" = 0xFFF8F8
    "Gold" = 0x00D7FF
    "Goldenrod" = 0x20A5DA
    "Gray" = 0x808080
    "Green" = 0x008000
    "GreenYellow" = 0x2FFFAD
    "Honeydew" = 0xF0FFF0
    "HotPink" = 0xB469FF
    "IndianRed" = 0x5C5CCD
    "Indigo" = 0x82004B
    "Ivory" = 0xF0FFFF
    "Khaki" = 0x8CE6F0
    "Lavender" = 0xFAE6E6
    "LavenderBlush" = 0xF5F0FF
    "LawnGreen" = 0x00FC7C
    "LemonChiffon" = 0xCDFAFF
    "LightBlue" = 0xE6D8AD
    "LightCoral" = 0x8080F0
    "LightCyan" = 0xFFFFE0
    "LightGoldenrodYellow" = 0xD2FAFA
    "LightGray" = 0xD3D3D3
    "LightGreen" = 0x90EE90
    "LightPink" = 0xC1B6FF
    "LightSalmon" = 0x7AA0FF
    "LightSeaGreen" = 0xAAB220
    "LightSkyBlue" = 0xFACE87
    "LightSlateGray" = 0x998877
    "LightSteelBlue" = 0xDEC4B0
    "LightYellow" = 0xE0FFFF
    "Lime" = 0x00FF00
    "LimeGreen" = 0x32CD32
    "Linen" = 0xE6F0FA
    "Magenta" = 0xFF00FF
    "Maroon" = 0x000080
    "MediumAquamarine" = 0xAACD66
    "MediumBlue" = 0xCD0000
    "MediumOrchid" = 0xD355BA
    "MediumPurple" = 0xDB7093
    "MediumSeaGreen" = 0x71B33C
    "MediumSlateBlue" = 0xEE687B
    "MediumSpringGreen" = 0x9AFA00
    "MediumTurquoise" = 0xCCD148
    "MediumVioletRed" = 0x8515C7
    "MidnightBlue" = 0x701919
    "MintCream" = 0xFAFFF5
    "MistyRose" = 0xE1E4FF
    "Moccasin" = 0xB5E4FF
    "NavajoWhite" = 0xADDEFF
    "Navy" = 0x800000
    "OldLace" = 0xE6F5FD
    "Olive" = 0x008080
    "OliveDrab" = 0x238E6B
    "Orange" = 0x00A5FF
    "OrangeRed" = 0x0045FF
    "Orchid" = 0xD670DA
    "PaleGoldenrod" = 0xAAE8EE
    "PaleGreen" = 0x98FB98
    "PaleTurquoise" = 0xEEEEAF
    "PaleVioletRed" = 0x9370DB
    "PapayaWhip" = 0xD5EFFF
    "PeachPuff" = 0xB9DAFF
    "Peru" = 0x3F85CD
    "Pink" = 0xCBC0FF
    "Plum" = 0xDDA0DD
    "PowderBlue" = 0xE6E0B0
    "Purple" = 0x800080
    "Red" = 0x0000FF
    "RosyBrown" = 0x8F8FBC
    "RoyalBlue" = 0xE16941
    "SaddleBrown" = 0x13458B
    "Salmon" = 0x7280FA
    "SandyBrown" = 0x60A4F4
    "SeaGreen" = 0x578B2E
    "SeaShell" = 0xEEF5FF
    "Sienna" = 0x2D52A0
    "Silver" = 0xC0C0C0
    "SkyBlue" = 0xEBCE87
    "SlateBlue" = 0xCD5A6A
    "SlateGray" = 0x908070
    "Snow" = 0xFAFAFF
    "SpringGreen" = 0x7FFF00
    "SteelBlue" = 0xB48246
    "Tan" = 0x8CB4D2
    "Teal" = 0x808000
    "Thistle" = 0xD8BFD8
    "Tomato" = 0x4763FF
    "Turquoise" = 0xD0E040
    "Violet" = 0xEE82EE
    "Wheat" = 0xB3DEF5
    "White" = 0xFFFFFF
    "WhiteSmoke" = 0xF5F5F5
    "Yellow" = 0x00FFFF
    "YellowGreen" = 0x32CD9A
    "Admin" = 0x000020
    "Dev" = 0x002000
    "AdminDev" = 0x002020
    "PowerShell" = 0x562401
    "Terminal" = 0x0C0C0C
    "Desktop" = 0xB16300
    "UclaBlue" = 0xD3994B
    "UclaGold" = 0x2ECBFD
}

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

[StructLayout(LayoutKind.Sequential)]
public struct MEMORY_BASIC_INFORMATION
{
    public System.IntPtr BaseAddress;
    public System.IntPtr AllocationBase;
    public uint AllocationProtect;
    public System.IntPtr RegionSize;
    public uint State;
    public uint Protect;
    public uint Type;
}

[DllImport("kernel32", ExactSpelling = true)]
public static extern void OutputDebugStringW([MarshalAs(UnmanagedType.LPWStr)] String lpOutputString);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern System.IntPtr GetStdHandle(int nStdHandle);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern uint GetFileType(System.IntPtr hFile);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = false)]
public static extern System.IntPtr GetCurrentProcess();

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern uint GetPriorityClass(System.IntPtr hProcess);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int SetPriorityClass(System.IntPtr hProcess, uint uPriorityClass);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int GetConsoleMode(System.IntPtr hConsoleHandle, out uint lpMode);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int SetConsoleMode(System.IntPtr hConsoleHandle, uint dwMode);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int GetConsoleScreenBufferInfoEx(System.IntPtr hConsoleOutput,
    ref CONSOLE_SCREEN_BUFFER_INFOEX lpConsoleScreenBufferInfoEx);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int SetConsoleScreenBufferInfoEx(System.IntPtr hConsoleOutput,
    ref CONSOLE_SCREEN_BUFFER_INFOEX lpConsoleScreenBufferInfoEx);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern System.IntPtr VirtualQueryEx(System.IntPtr hProcess, System.IntPtr lpAddress,
    ref MEMORY_BASIC_INFORMATION lpBuffer, System.IntPtr dwLength);
"@

Add-Type -MemberDefinition $MemberDefinition -Name "Kernel32" -Namespace "Win32"

# Types are:
# Win32.Kernel32
# Win32.Kernel32+COORD
# Win32.Kernel32+SMALL_RECT
# Win32.Kernel32+CONSOLE_SCREEN_BUFFER_INFOEX
# Win32.Kernel32+MEMORY_BASIC_INFORMATION

#===================================================================================================
