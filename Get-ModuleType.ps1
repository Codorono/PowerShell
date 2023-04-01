#===================================================================================================

param([Parameter(Mandatory)] [string] $FileSpec)

#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

$ModuleType = "invalid"

# open file stream

$FilePath = (Get-ChildItem $FileSpec).FullName

$FileStream = New-Object "System.IO.FileStream" -ArgumentList $FilePath,
    ([System.IO.FileMode]::Open), ([System.IO.FileAccess]::Read), ([System.IO.FileShare]::Read)

try
{
    # get binary stream reader

    $BinaryReader = New-Object "System.IO.BinaryReader" -ArgumentList $FileStream

    try
    {
        # verify image_dos_header magic is MZ

        $Magic = $BinaryReader.ReadUInt16()

        if ($Magic -ne 0x5A4D)
        {
            throw "Missing MZ signature"
        }

        # get lfanew member in image_dos_header

        [void] $FileStream.Seek(60, [System.IO.SeekOrigin]::Begin)

        $LfaNew = $BinaryReader.ReadUInt32()

        # seek to image_nt_headers

        [void] $FileStream.Seek($LfaNew, [System.IO.SeekOrigin]::Begin)

        # verify signature is PE00

        $Signature = $BinaryReader.ReadUInt32()

        if ($Signature -ne 0x00004550)
        {
            throw "Missing PE signature"
        }

        # get machine

        $Machine = $BinaryReader.ReadUInt16()

        $ModuleType = switch ($Machine)
        {
            0 { "unknown" }
            0x014C { "x86" }
            0x01C0 { "arm" }
            0x01C2 { "arm Thumb/Thumb-2" }
            0x01C4 { "arm Thumb-2" }
            0x0200 { "Itanium" }
            0x8664 { "x64" }
            0xAA64 { "arm64" }
            default { "0x{0:X4}" -f $Machine }
        }
    }

    finally
    {
        $BinaryReader.Dispose()
    }
}

finally
{
    $FileStream.Dispose()
}

$ModuleType

#===================================================================================================
