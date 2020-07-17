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

function Get-ConsoleWindow
{
    [Win32.Kernel32]::GetConsoleWindow();
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

            $ConsoleScreenBufferInfo.ColorTable[0] = [System.Drawing.ColorTranslator]::ToWin32($Color)

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

function Set-ConsoleColorScheme([string] $Scheme)
{
    $Colors = @()
    $Attributes = 0x0007
    $PopupAttributes = 0x00F5

    if ($Scheme -eq "")
    {
        #get colors from registry

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

[DllImport("kernel32.dll", ExactSpelling = true)]
public static extern System.IntPtr GetConsoleWindow();

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
