#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function Get-ShellWindow()
{
    [Win32.User32]::GetShellWindow()
}

#===================================================================================================

function Post-Message
(
    [System.IntPtr] $HWnd,
    [uint] $Msg,
    [System.IntPtr] $WParam,
    [System.IntPtr] $LParam
)
{
    [Win32.User32]::PostMessageW($HWnd, $Msg, $WParam, $LParam)
}

#===================================================================================================

function Send-Message
(
    [System.IntPtr] $HWnd,
    [uint] $Msg,
    [System.IntPtr] $WParam,
    [System.IntPtr] $LParam
)
{
    [Win32.User32]::SendMessageW($HWnd, $Msg, $WParam, $LParam)
}

#===================================================================================================

function Disable-MonitorPower
{
    [void] [Win32.User32]::PostMessageW((Get-ShellWindow), $WM_SYSCOMMAND, $SC_MONITORPOWER, 2)
}

#===================================================================================================

function Out-MessageBeep
(
    [switch] $Ok,
    [switch] $Stop,
    [switch] $Exclamation,
    [switch] $Information,
    [switch] $Question
)
{
    [uint] $Type = $Ok ? $MB_OK : `
        $Stop ? $MB_ICONSTOP : `
        $Exclamation ? $MB_ICONEXCLAMATION : `
        $Information ? $MB_ICONINFORMATION : `
        $Question ? $MB_ICONQUESTION : 0xFFFFFFFFu

    [void] [Win32.User32]::MessageBeep($Type)
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

    $Buttons = $Ok ? $MB_OK : `
        $OkCancel ? $MB_OKCANCEL : `
        $AbortRetryIgnore ? $MB_ABORTRETRYIGNORE : `
        $YesNoCancel ? $MB_YESNOCANCEL : `
        $YesNo ? $MB_YESNO : `
        $RetryCancel ? $MB_RETRYCANCEL : `
        $CancelTryContinue ? $MB_CANCELTRYCONTINUE : 0

    # get icon

    $Icon = $IconStop ? $MB_ICONSTOP : `
        $IconExclamation ? $MB_ICONEXCLAMATION : `
        $IconInformation ? $MB_ICONINFORMATION : `
        $IconQuestion ? $MB_ICONQUESTION : 0

    # get default button

    $DefButton = $DefButton1 ? $MB_DEFBUTTON1 : `
        $DefButton2 ? $MB_DEFBUTTON2 : `
        $DefButton3 ? $MB_DEFBUTTON3 : `
        $DefButton4 ? $MB_DEFBUTTON4 : 0

    # get mode

    $Mode = $ApplModal ? $MB_APPLMODAL : `
        $SystemModal ? $MB_SYSTEMMODAL : `
        $TaskModal ? $MB_TASKMODAL : 0

    # get misc flags

    $Misc = 0

    if ($NoFocus)
    {
        $Misc = $Misc -bor $MB_NOFOCUS
    }

    if ($SetForeground)
    {
        $Misc = $Misc -bor $MB_SETFOREGROUND
    }

    if ($DefaultDesktopOnly)
    {
        $Misc = $Misc -bor $MB_DEFAULTDESKTOPONLY
    }

    if ($Topmost)
    {
        $Misc = $Misc -bor $MB_TOPMOST
    }

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
        throw ([System.ComponentModel.Win32Exception]::new())
    }

    $Result
}

#===================================================================================================

Set-Variable "MB_OK" 0x00000000u -Option Constant
Set-Variable "MB_OKCANCEL" 0x00000001u -Option Constant
Set-Variable "MB_ABORTRETRYIGNORE" 0x00000002u -Option Constant
Set-Variable "MB_YESNOCANCEL" 0x00000003u -Option Constant
Set-Variable "MB_YESNO" 0x00000004u -Option Constant
Set-Variable "MB_RETRYCANCEL" 0x00000005u -Option Constant
Set-Variable "MB_CANCELTRYCONTINUE" 0x00000006u -Option Constant

Set-Variable "MB_ICONSTOP" 0x00000010u -Option Constant
Set-Variable "MB_ICONQUESTION" 0x00000020u -Option Constant
Set-Variable "MB_ICONEXCLAMATION" 0x00000030u -Option Constant
Set-Variable "MB_ICONINFORMATION" 0x00000040u -Option Constant

Set-Variable "MB_DEFBUTTON1" 0x00000000u -Option Constant
Set-Variable "MB_DEFBUTTON2" 0x00000100u -Option Constant
Set-Variable "MB_DEFBUTTON3" 0x00000200u -Option Constant
Set-Variable "MB_DEFBUTTON4" 0x00000300u -Option Constant

Set-Variable "MB_APPLMODAL" 0x00000000u -Option Constant
Set-Variable "MB_SYSTEMMODAL" 0x00001000u -Option Constant
Set-Variable "MB_TASKMODAL" 0x00002000u -Option Constant

Set-Variable "MB_NOFOCUS" 0x00008000u -Option Constant
Set-Variable "MB_SETFOREGROUND" 0x00010000u -Option Constant
Set-Variable "MB_DEFAULT_DESKTOP_ONLY" 0x00020000u -Option Constant
Set-Variable "MB_TOPMOST" 0x00040000u -Option Constant

Set-Variable "WM_SYSCOMMAND" 0x0112u -Option Constant

Set-Variable "SC_MONITORPOWER" 0xF170u -Option Constant

#===================================================================================================

$MemberDefinition =
@"
[DllImport("user32.dll", ExactSpelling = true, SetLastError = false)]
public static extern System.IntPtr GetShellWindow();

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool PostMessageW(System.IntPtr hWnd, uint uMsg,
    System.IntPtr wParam, System.IntPtr lParam);

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
public static extern System.IntPtr SendMessageW(System.IntPtr hWnd, uint uMsg,
    System.IntPtr wParam, System.IntPtr lParam);

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool MessageBeep(uint uType);

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int MessageBoxW(System.IntPtr hWnd, [MarshalAs(UnmanagedType.LPWStr)] string lpText,
    [MarshalAs(UnmanagedType.LPWStr)] string lpCaption, uint uType);

[DllImport("user32.dll", ExactSpelling = true, SetLastError = true)]
public static extern int MessageBoxTimeoutW(System.IntPtr hWnd, [MarshalAs(UnmanagedType.LPWStr)] string lpText,
    [MarshalAs(UnmanagedType.LPWStr)] string lpCaption, uint uType, ushort wLanguageId, uint dwMilliseconds);
"@

Add-Type "User32" $MemberDefinition -Namespace "Win32"

#===================================================================================================
