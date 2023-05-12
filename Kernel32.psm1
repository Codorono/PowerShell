#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function Out-Beep([uint] $Freq = 750, [uint] $Duration = 250)
{
    [void] [Win32.Kernel32]::Beep($Freq, $Duration)
}

#===================================================================================================

function Out-Debug
{
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline, ValueFromRemainingArguments)] [string] $Text)

    process
    {
        if ($Text.Length -ne 0)
        {
            [Win32.Kernel32]::OutputDebugStringW($Text)
        }
    }
}

#===================================================================================================

function Get-FileType([System.IntPtr] $Handle)
{
    [Win32.Kernel32]::GetFileType($Handle)
}

#===================================================================================================

function Get-DriveType([string] $DriveRoot)
{
    if (-not $DriveRoot.EndsWith("\"))
    {
        $DriveRoot += "\"
    }

    [Win32.Kernel32]::GetDriveTypeW($DriveRoot)
}

#===================================================================================================

function Set-BackgroundPriorityMode([switch] $Begin, [switch] $End)
{
    # get process pseudo handle

    $ProcessHandle = [Win32.Kernel32]::GetCurrentProcess()

    # get requested mode

    $BackgroundMode = $Begin ? $PROCESS_MODE_BACKGROUND_BEGIN : $End ? $PROCESS_MODE_BACKGROUND_END : 0

    # set background mode

    if ($BackgroundMode -ne 0)
    {
        if ([Win32.Kernel32]::SetPriorityClass($ProcessHandle, $BackgroundMode) -eq 0)
        {
            throw ([System.ComponentModel.Win32Exception]::new())
        }
    }

    # get priority class

    $PriorityClass = [Win32.Kernel32]::GetPriorityClass($ProcessHandle)

    if ($PriorityClass -eq 0)
    {
        throw ([System.ComponentModel.Win32Exception]::new())
    }

    # display priority class name

    $PriorityClassName = switch ($PriorityClass)
    {
        $NORMAL_PRIORITY_CLASS { "Normal" }
        $IDLE_PRIORITY_CLASS { "Idle" }
        $HIGH_PRIORITY_CLASS { "High" }
        $REALTIME_PRIORITY_CLASS { "Realtime" }
        $BELOW_NORMAL_PRIORITY_CLASS { "Below Normal" }
        $ABOVE_NORMAL_PRIORITY_CLASS] { "Above Normal" }
        default { "Unknown" }
    }

    Write-Output ("{0} priority class" -f $PriorityClassName)
}

#===================================================================================================

function Set-DosDevice([string] $Drive, [string] $Path, [switch] $Remove)
{
    $Flags = $Remove ? $DDD_REMOVE_DEFINITION : 0

    [void] [Win32.Kernel32]::DefineDosDeviceW($Flags, $Drive, $Path)
}

#===================================================================================================

function Get-VolumeInformation([string] $DriveRoot)
{
    if (-not $DriveRoot.EndsWith("\"))
    {
        $DriveRoot += "\"
    }

    $VolumeName = [System.Text.StringBuilder]::new(256)
    $VolumeSerialNumber = [uint] 0
    $MaximumComponentLength = [uint] 0
    $FileSystemFlags = [uint] 0
    $FileSystemName = [System.Text.StringBuilder]::new(256)

    [void] [Win32.Kernel32]::GetVolumeInformationW($DriveRoot, $VolumeName, $VolumeName.Capacity,
        [ref] $VolumeSerialNumber, [ref] $MaximumComponentLength, [ref] $FileSystemFlags,
        $FileSystemName, $FileSystemName.Capacity)

    Write-Output ($VolumeName.ToString())
    Write-Output ("{0:X4}-{1:X4}" -f ($VolumeSerialNumber -shr 16), ($VolumeSerialNumber -band 0xFFFF))
    Write-Output ($MaximumComponentLength)
    Write-Output ("0x{0:X8}" -f $FileSystemFlags)
    Write-Output ($FileSystemName.ToString())
}

#===================================================================================================

function Get-VolumeName([string] $DriveRoot)
{
    if (-not $DriveRoot.EndsWith("\"))
    {
        $DriveRoot += "\"
    }

    $VolumeName = [System.Text.StringBuilder]::new(256)

    [void] [Win32.Kernel32]::GetVolumeInformationW($DriveRoot, $VolumeName, $VolumeName.Capacity,
        [System.IntPtr]::Zero, [System.IntPtr]::Zero, [System.IntPtr]::Zero,
        [System.IntPtr]::Zero, 0)

    Write-Output ($VolumeName.ToString())
}

#===================================================================================================

function Get-VolumeSerialNumber([string] $DriveRoot)
{
    if (-not $DriveRoot.EndsWith("\"))
    {
        $DriveRoot += "\"
    }

    $VolumeSerialNumber = [uint] 0

    [void] [Win32.Kernel32]::GetVolumeInformationW($DriveRoot, [System.IntPtr]::Zero, 0,
        [ref] $VolumeSerialNumber, [System.IntPtr]::Zero, [System.IntPtr]::Zero,
        [System.IntPtr]::Zero, 0)

    Write-Output ("{0:X4}-{1:X4}" -f ($VolumeSerialNumber -shr 16), ($VolumeSerialNumber -band 0xFFFF))
}

#===================================================================================================

function Get-MemoryInfo
{
    # get process pseudo handle

    $ProcessHandle = [Win32.Kernel32]::GetCurrentProcess()

    # create memory basic information structure

    $MemoryBasicInformation = [Win32.Kernel32+MEMORY_BASIC_INFORMATION]::new()

    # query virtual memory

    $Result = [Win32.Kernel32]::VirtualQueryEx($ProcessHandle, [System.IntPtr]::Zero, [ref] $MemoryBasicInformation,
        [System.Runtime.InteropServices.Marshal]::SizeOf($MemoryBasicInformation))

    if ($Result -eq 0)
    {
        throw ([System.ComponentModel.Win32Exception]::new())
    }

    Write-Output $MemoryBasicInformation
}

#===================================================================================================

Set-Variable "GENERIC_READ" 0x80000000u -Option Constant
Set-Variable "GENERIC_WRITE" 0x40000000u -Option Constant

Set-Variable "FILE_SHARE_READ" 0x00000001u -Option Constant
Set-Variable "FILE_SHARE_WRITE" 0x00000002u -Option Constant
Set-Variable "FILE_SHARE_DELETE" 0x00000004u -Option Constant

Set-Variable "CREATE_NEW" 1u -Option Constant
Set-Variable "CREATE_ALWAYS" 2u -Option Constant
Set-Variable "OPEN_EXISTING" 3u -Option Constant
Set-Variable "OPEN_ALWAYS" 4u -Option Constant
Set-Variable "TRUNCATE_EXISTING" 5u -Option Constant

Set-Variable "FILE_TYPE_UNKNOWN" 0x0000u -Option Constant
Set-Variable "FILE_TYPE_DISK" 0x0001u -Option Constant
Set-Variable "FILE_TYPE_CHAR" 0x0002u -Option Constant
Set-Variable "FILE_TYPE_PIPE" 0x0003u -Option Constant
Set-Variable "FILE_TYPE_REMOTE" 0x8000u -Option Constant

Set-Variable "NORMAL_PRIORITY_CLASS" 0x00000020u -Option Constant
Set-Variable "IDLE_PRIORITY_CLASS" 0x00000040u -Option Constant
Set-Variable "HIGH_PRIORITY_CLASS" 0x00000080u -Option Constant
Set-Variable "REALTIME_PRIORITY_CLASS" 0x00000100u -Option Constant
Set-Variable "BELOW_NORMAL_PRIORITY_CLASS" 0x00004000u -Option Constant
Set-Variable "ABOVE_NORMAL_PRIORITY_CLASS" 0x00008000u -Option Constant

Set-Variable "PROCESS_MODE_BACKGROUND_BEGIN" 0x00100000u -Option Constant
Set-Variable "PROCESS_MODE_BACKGROUND_END" 0x00200000u -Option Constant

Set-Variable "DDD_REMOVE_DEFINITION" 0x00000002u -Option Constant

Set-Variable "INVALID_HANDLE_VALUE" ([System.IntPtr] -1) -Option Constant

#===================================================================================================

$MemberDefinition =
@"
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

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool Beep(uint uFreq, uint uDuration);

[DllImport("kernel32.dll", ExactSpelling = true)]
public static extern void OutputDebugStringW([MarshalAs(UnmanagedType.LPWStr)] string lpOutputString);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = false)]
public static extern System.IntPtr GetCurrentProcess();

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern uint GetFileType(System.IntPtr hFile);

[DllImport("kernel32.dll", ExactSpelling = true)]
public static extern uint GetDriveTypeW([MarshalAs(UnmanagedType.LPWStr)] string lpRootPathName);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern uint GetPriorityClass(System.IntPtr hProcess);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int SetPriorityClass(System.IntPtr hProcess, uint uPriorityClass);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int DefineDosDeviceW(uint uFlags,
    [MarshalAs(UnmanagedType.LPWStr)] string lpDeviceName,
    [MarshalAs(UnmanagedType.LPWStr)] string lpTargetPath);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int GetVolumeInformationW(
    [MarshalAs(UnmanagedType.LPWStr)] string lpRootPathName,
    [MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder lpVolumeNameBuffer, uint nVolumeNameSize,
    out uint lpVolumeSerialNumber, out uint lpMaximumComponentLength, out uint lpFileSystemFlags,
    [MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder lpFileSystemNameBuffer, uint nFileSystemNameSize);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int GetVolumeInformationW(
    [MarshalAs(UnmanagedType.LPWStr)] string lpRootPathName,
    [MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder lpVolumeNameBuffer, uint nVolumeNameSize,
    System.IntPtr lpVolumeSerialNumber, System.IntPtr lpMaximumComponentLength, System.IntPtr lpFileSystemFlags,
    System.IntPtr lpFileSystemNameBuffer, uint nFileSystemNameSize);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int GetVolumeInformationW(
    [MarshalAs(UnmanagedType.LPWStr)] string lpRootPathName,
    System.IntPtr lpVolumeNameBuffer, uint nVolumeNameSize,
    out uint lpVolumeSerialNumber, System.IntPtr lpMaximumComponentLength, System.IntPtr lpFileSystemFlags,
    System.IntPtr lpFileSystemNameBuffer, uint nFileSystemNameSize);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern System.IntPtr VirtualQueryEx(System.IntPtr hProcess, System.IntPtr lpAddress,
    ref MEMORY_BASIC_INFORMATION lpBuffer, System.IntPtr dwLength);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
public static extern System.IntPtr CreateFileW(
    [MarshalAs(UnmanagedType.LPWStr)] string lpFileName, uint dwDesiredAccess, uint dwShareMode,
    System.IntPtr lpSecurityAttributes, uint dwCreationDisposition, uint dwFlagsAndAttributes,
    System.IntPtr hTemplateFile);

[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
    public static extern int CloseHandle(System.IntPtr hObject);
"@

Add-Type "Kernel32" $MemberDefinition -Namespace "Win32"

# Types are:
# Win32.Kernel32
# Win32.Kernel32+MEMORY_BASIC_INFORMATION

#===================================================================================================
