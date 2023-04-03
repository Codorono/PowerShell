#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function Format-ByteSize([long] $Number, [switch] $Truncate)
{
    $Flags = $Truncate ? $SFBS_FLAGS_TRUNCATE_UNDISPLAYED_DECIMAL_DIGITS : $SFBS_FLAGS_ROUND_TO_NEAREST_DISPLAYED_DIGIT

    $StringBuilder = New-Object "System.Text.StringBuilder" -ArgumentList 16

    [Win32.Shlwapi]::StrFormatByteSizeEx($Number, $Flags, $StringBuilder, $StringBuilder.Capacity)

    $StringBuilder.ToString()
}

#===================================================================================================

Set-Variable "SFBS_FLAGS_ROUND_TO_NEAREST_DISPLAYED_DIGIT" 0x0001 -Option Constant
Set-Variable "SFBS_FLAGS_TRUNCATE_UNDISPLAYED_DECIMAL_DIGITS" 0x0002 -Option Constant

#===================================================================================================

$MemberDefinition =
@"
[DllImport("shlwapi.dll", ExactSpelling = true, PreserveSig = false, SetLastError = false)]
public static extern void StrFormatByteSizeEx(long ull, int flags,
    [MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszBuf, uint cchBuf);
"@

Add-Type "Shlwapi" $MemberDefinition -Namespace "Win32"

#===================================================================================================
