#=======================================================================================================================

Set-StrictMode -Version Latest

#=======================================================================================================================

enum SFBS_FLAGS
{
	ROUND_TO_NEAREST_DISPLAYED_DIGIT = 0x0001
	TRUNCATE_UNDISPLAYED_DECIMAL_DIGITS = 0x0002
}

#=======================================================================================================================

function Format-ByteSize([long] $Number, [switch] $Truncate)
{
	$Flags = [SFBS_FLAGS]::ROUND_TO_NEAREST_DISPLAYED_DIGIT

	if ($Truncate)
	{
		$Flags = [SFBS_FLAGS]::TRUNCATE_UNDISPLAYED_DECIMAL_DIGITS
	}

	$StringBuilder = [System.Text.StringBuilder]::new(16)

	[Win32.Shlwapi]::StrFormatByteSizeEx($Number, $Flags, $StringBuilder, $StringBuilder.Capacity)

	$StringBuilder.ToString()
}

#=======================================================================================================================

$MemberDefinition =
@"
[DllImport("shlwapi.dll", ExactSpelling = true, PreserveSig = false, SetLastError = false)]
public static extern void StrFormatByteSizeEx(long ull, int flags,
	[MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszBuf, uint cchBuf);
"@

Add-Type "Shlwapi" $MemberDefinition -Namespace "Win32"

#=======================================================================================================================
