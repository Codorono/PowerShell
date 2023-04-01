#===================================================================================================

param
(
    [Parameter(Mandatory)]
    [string] $Path,

    [string] $Parameters
)

#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

# derived from https://github.com/Pscx/Pscx/blob/master/Src/Pscx/Modules/Utility/Pscx.Utility.psm1

#===================================================================================================

# create temp file

$TempFile = [System.IO.Path]::GetTempFileName()

# execute batch file

CMD.exe /c "`"$Path`" $Parameters && SET" | Out-File $TempFile -Encoding UTF8NoBOM

# loop through batch file output

Get-Content $TempFile | ForEach-Object `
{
    # write output

    if (($_.StartsWith("[DEBUG:")) -or ($_.StartsWith("[ERROR:")) -or ($_ -notmatch "([^=]+)=(.+)"))
    {
       $_
    }

    # set environment variable

    elseif (-not $_.StartsWith("PROMPT="))
    {
        Set-Item "Env:$($matches[1])" $matches[2]
    }
}

# delete temp file

Remove-Item $TempFile

#===================================================================================================
