#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function Get-ShellWindow()
{
    [Win32.User32]::GetShellWindow()
}

#===================================================================================================

function Send-Message
(
    [System.IntPtr] $HWnd,
    [uint] $Msg,
    [System.IntPtr] $WParam,
    [System.IntPtr] $LParam,
    [switch] $Post
)
{
    if ($Post)
    {
        [Win32.User32]::PostMessageW($HWnd, $Msg, $WParam, $LParam)
    }

    else
    {
        [Win32.User32]::SendMessageW($HWnd, $Msg, $WParam, $LParam)
    }
}

#===================================================================================================

function Disable-MonitorPower
{
    [void] [Win32.User32]::PostMessageW((Get-ShellWindow), $WM_SYSCOMMAND, $SC_MONITORPOWER, 2)
}

#===================================================================================================

function Out-MessageBeep([MB_BEEP] $Type = [MB_BEEP]::MB_DEFAULT)
{
    [void] [Win32.User32]::MessageBeep([System.BitConverter]::ToUInt32([System.BitConverter]::GetBytes([int] $Type), 0))
}

#===================================================================================================

function Show-MessageBox
(
    [Parameter(Mandatory)] [string] $Text,
    [string] $Caption,
    [uint] $Seconds = 0,
    [switch] $Ok,
    [switch] $OkCancel,
    [switch] $AbortRetryIgnore,
    [switch] $YesNoCancel,
    [switch] $YesNo,
    [switch] $RetryCancel,
    [switch] $CancelTryContinue,
    [switch] $IconStop,
    [switch] $IconExclamation,
    [switch] $IconInformation,
    [switch] $IconQuestion,
    [switch] $DefButton1,
    [switch] $DefButton2,
    [switch] $DefButton3,
    [switch] $DefButton4,
    [switch] $ApplModal,
    [switch] $SystemModal,
    [switch] $TaskModal,
    [switch] $NoFocus,
    [switch] $SetForeground,
    [switch] $DefaultDesktopOnly,
    [switch] $Topmost
)
{
    # get console window

    $Hwnd = Get-ConsoleWindow

    # get caption

    if ($Caption.Length -eq 0)
    {
        $ScriptName = $MyInvocation.ScriptName

        if ($ScriptName.Length -ne 0)
        {
            $Caption =[System.IO.Path]::GetFileNameWithoutExtension($ScriptName)
        }

        else
        {
            $Caption = $MyInvocation.MyCommand.Name
        }
    }

    # get buttons

    $Buttons = $Ok ? [MB_TYPE]::MB_OK : `
        $OkCancel ? [MB_TYPE]::MB_OKCANCEL : `
        $AbortRetryIgnore ? [MB_TYPE]::MB_ABORTRETRYIGNORE : `
        $YesNoCancel ? [MB_TYPE]::MB_YESNOCANCEL : `
        $YesNo ? [MB_TYPE]::MB_YESNO : `
        $RetryCancel ? [MB_TYPE]::MB_RETRYCANCEL : `
        $CancelTryContinue ? [MB_TYPE]::MB_CANCELTRYCONTINUE : 0

    # get icon

    $Icon = $IconStop ? [MB_ICON]::MB_ICONSTOP : `
        $IconExclamation ? [MB_ICON]::MB_ICONEXCLAMATION : `
        $IconInformation ? [MB_ICON]::MB_ICONINFORMATION : `
        $IconQuestion ? [MB_ICON]::MB_ICONQUESTION : 0

    # get default button

    $DefButton = $DefButton1 ? [MB_DEFBUTTON]::MB_DEFBUTTON1 : `
        $DefButton2 ? [MB_DEFBUTTON]::MB_DEFBUTTON2 : `
        $DefButton3 ? [MB_DEFBUTTON]::MB_DEFBUTTON3 : `
        $DefButton4 ? [MB_DEFBUTTON]::MB_DEFBUTTON4 : 0

    # get mode

    $Mode = $ApplModal ? [MB_MODE]::MB_APPLMODAL : `
        $SystemModal ? [MB_MODE]::MB_SYSTEMMODAL : `
        $TaskModal ? [MB_MODE]::MB_TASKMODAL : 0

    # get misc flags

    $Misc = 0

    if ($NoFocus) { $Misc = $Misc -bor [MB_MISC]::MB_NOFOCUS }
    if ($SetForeground) { $Misc = $Misc -bor [MB_MISC]::MB_SETFOREGROUND }
    if ($DefaultDesktopOnly) { $Misc = $Misc -bor [MB_MISC]::MB_DEFAULTDESKTOPONLY }
    if ($Topmost) { $Misc = $Misc -bor [MB_MISC]::MB_TOPMOST }

    # get type

    $Type = $Buttons -bor $Icon -bor $DefButton -bor $Mode -bor $Misc

    # show message box

    $Result = 0

    if ($Seconds -eq 0)
    {
        $Result = [Win32.User32]::MessageBoxW($Hwnd, $Text, $Caption, $Type)
    }

    else
    {
        $Result = [Win32.User32]::MessageBoxTimeoutW($Hwnd, $Text, $Caption, $Type, 0, $Seconds * 1000)
    }

    if ($Result -eq 0)
    {
        throw (New-Object -TypeName "System.ComponentModel.Win32Exception")
    }

    $Result
}

#===================================================================================================

enum MB_TYPE
{
    MB_OK = 0x00000000
    MB_OKCANCEL = 0x00000001
    MB_ABORTRETRYIGNORE = 0x00000002
    MB_YESNOCANCEL = 0x00000003
    MB_YESNO = 0x00000004
    MB_RETRYCANCEL = 0x00000005
    MB_CANCELTRYCONTINUE = 0x00000006
}

enum MB_ICON
{
    MB_ICONSTOP = 0x00000010
    MB_ICONQUESTION = 0x00000020
    MB_ICONEXCLAMATION = 0x00000030
    MB_ICONINFORMATION = 0x00000040
}

enum MB_DEFBUTTON
{
    MB_DEFBUTTON1 = 0x00000000
    MB_DEFBUTTON2 = 0x00000100
    MB_DEFBUTTON3 = 0x00000200
    MB_DEFBUTTON4 = 0x00000300
}

enum MB_MODE
{
    MB_APPLMODAL = 0x00000000
    MB_SYSTEMMODAL = 0x00001000
    MB_TASKMODAL = 0x00002000
}

enum MB_MISC
{
    MB_NOFOCUS = 0x00008000
    MB_SETFOREGROUND = 0x00010000
    MB_DEFAULT_DESKTOP_ONLY = 0x00020000
    MB_TOPMOST = 0x00040000
}

enum MB_BEEP
{
    MB_OK = 0x00000000
    MB_STOP = 0x00000010
    MB_QUESTION = 0x00000020
    MB_EXCLAMATION = 0x00000030
    MB_INFORMATION = 0x00000040
    MB_DEFAULT = 0xFFFFFFFF
}

Set-Variable -Name "WM_SYSCOMMAND" -Value 0x0112 -Option Constant
Set-Variable -Name "SC_MONITORPOWER" -Value 0xF170 -Option Constant

#===================================================================================================

$MemberDefinition =
@"
[DllImport("user32.dll", ExactSpelling = true, SetLastError = false)]
public static extern System.IntPtr GetShellWindow();

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
public static extern System.IntPtr SendMessageW(System.IntPtr hWnd, uint uMsg,
    System.IntPtr wParam, System.IntPtr lParam);

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool PostMessageW(System.IntPtr hWnd, uint uMsg,
    System.IntPtr wParam, System.IntPtr lParam);

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool MessageBeep(uint uType);

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int MessageBoxW(System.IntPtr hWnd, [MarshalAs(UnmanagedType.LPWStr)] String lpText,
    [MarshalAs(UnmanagedType.LPWStr)] String lpCaption, uint uType);

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int MessageBoxTimeoutW(System.IntPtr hWnd, [MarshalAs(UnmanagedType.LPWStr)] String lpText,
    [MarshalAs(UnmanagedType.LPWStr)] String lpCaption, uint uType, ushort wLanguageId, uint dwMilliseconds);
"@

Add-Type -MemberDefinition $MemberDefinition -Name "User32" -Namespace "Win32"

#===================================================================================================
