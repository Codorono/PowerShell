#===================================================================================================

param([string] $Path, [string] $Parameters)

#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

# derived from https://github.com/Pscx/Pscx/blob/master/Src/Pscx/Modules/Utility/Pscx.Utility.psm1

#===================================================================================================

# create temp file

$TempFile = [System.IO.Path]::GetTempFileName()

# execute batch file

CMD /c "`"$Path`" $Parameters && SET" | Out-File -FilePath $TempFile

# loop through batch file output

Get-Content -Path $TempFile | ForEach-Object -Process `
{
    # write output

    if (($_.StartsWith("[DEBUG:")) -or ($_.StartsWith("[ERROR:")) -or ($_ -notmatch "([^=]+)=(.+)"))
    {
       $_
    }

    # set environment variable

    elseif (-not $_.StartsWith("PROMPT="))
    {
        Set-Item -Path "Env:$($matches[1])" -Value $matches[2]
    }
}

# delete temp file

Remove-Item -Path $TempFile

#===================================================================================================
