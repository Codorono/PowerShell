#===================================================================================================

function ql { $args }

function qs { "$args" }

#===================================================================================================

function Get-Plural([int] $Number) { ($Number -eq 1) ? "" : "s" }

function Get-Plurale([int] $Number) { ($Number -eq 1) ? "" : "es" }

#===================================================================================================

function Get-OSVersion
{
    $OSVersion = [System.Environment]::OSVersion.Version

    ($OSVersion.Major -shl 8) -bor $OSVersion.Minor
}

#===================================================================================================

function Test-64BitProcess
{
    [System.Environment]::Is64BitProcess
}

#===================================================================================================

function Test-64BitSystem
{
    [System.Environment]::Is64BitOperatingSystem
}

#===================================================================================================

function Test-Administrator
{
    $CurrentUser = New-Object "System.Security.Principal.WindowsPrincipal" `
        -ArgumentList ([System.Security.Principal.WindowsIdentity]::GetCurrent())

    $CurrentUser.IsInRole([System.Security.Principal.WindowsBuiltinRole]::Administrator)
}

#===================================================================================================

function Join-Strings([string] $String1, [string] $Separator, [string] $String2)
{
    if ($String2 -ne "")
    {
        if ($String1 -ne "")
        {
            if (-not (($String1.EndsWith($Separator)) -or ($String2.StartsWith($Separator))))
            {
                $String1 += $Separator
            }
        }

        $String1 += $String2
    }

    $String1
}

#===================================================================================================
