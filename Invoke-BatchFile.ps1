#===================================================================================================

param
(
    [Parameter(Mandatory)]
    [string] $Path,

    [Parameter(ValueFromRemainingArguments)]
    [string] $Parms
)

#===================================================================================================

# derived from https://github.com/Pscx/Pscx/blob/master/Src/Pscx/Modules/Utility/Pscx.Utility.psm1

#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

# execute batch file

CMD.exe /c "`"$Path`" $Parms && SET" | ForEach-Object `
{
    # write output

    if (($_.StartsWith("[DEBUG:")) -or ($_.StartsWith("[ERROR:")) -or ($_ -notmatch "([^=]+)=(.+)"))
    {
        Write-Output $_
    }

    # set environment variable

    elseif (-not $_.StartsWith("PROMPT="))
    {
        Set-Item "Env:$($matches[1])" $matches[2]
    }
}

#===================================================================================================
