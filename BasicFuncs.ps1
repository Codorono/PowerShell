﻿#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function ql
{
    $args
}

#===================================================================================================

function qs
{
    "$args"
}

#===================================================================================================

function MkLink
{
    & "cmd.exe" /c MKLINK $args
}

#===================================================================================================

function Get-Plural([int] $Number)
{
    ($Number -eq 1) ? "" : "s"
}

#===================================================================================================

function Get-Plurale([int] $Number)
{
    ($Number -eq 1) ? "" : "es"
}

#===================================================================================================

function Get-OSVersion
{
    # Win7=0x0601, Win8=0x0602, Win81=0x0603, Win10=0x0A00

    $OSVersion = [System.Environment]::OSVersion.Version

    (($OSVersion.Major -shl 8) -bor $OSVersion.Minor)
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

function Test-VirtualPC
{
    $Baseboard = Get-CimInstance -Namespace "root\CIMV2" -ClassName "Win32_Baseboard"

    (($Baseboard.Manufacturer -eq "Microsoft Corporation") -and ($Baseboard.Product -eq "Virtual Machine"))
}

#===================================================================================================

function Test-Administrator
{
    ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

#===================================================================================================

function Test-Elevated
{
    (([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544")
}

#===================================================================================================

function Join-Strings([string] $String1, [string] $Separator, [string] $String2)
{
    if ($String2.Length -ne 0)
    {
        if ($String1.Length -ne 0)
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

function Get-Color
{
    $Color = [System.Drawing.Color]::Empty

    if ($args.Count -eq 1)
    {
        $Arg = $args[0]

        # use integer color

        if ($Arg -is [int])
        {
            $Color = [System.Drawing.ColorTranslator]::FromWin32($Arg)
        }

        # use string color

        elseif ($Arg -is [string])
        {
            $Color = [System.Drawing.ColorTranslator]::FromHtml($Arg)
        }

        # use rgb array

        elseif (($Arg -is [System.Object[]]) -and ($Arg.Count -eq 3))
        {
            $Color = [System.Drawing.Color]::FromArgb($Arg[0], $Arg[1], $Arg[2])
        }
    }

    # use rgb triple

    elseif ($args.Count -eq 3)
    {
        $Red, $Green, $Blue = $args

        $Color = [System.Drawing.Color]::FromArgb($Red, $Green, $Blue)
    }

    $Color
}

#===================================================================================================

function Search-Path([string] $File)
{
    # WHERE.exe "$File"

    foreach ($Path in ($Env:Path -split ";"))
    {
        $FilePath = Join-Path $Path $File

        if (Test-Path $FilePath)
        {
            Get-ChildItem -Path $FilePath -File | ForEach-Object { $_.FullName }
        }
    }
}

#===================================================================================================

function Test-SearchPath([string] $File)
{
    # WHERE.exe /q "$File"
    # $LastExitCode -eq 0

    # Get-Command -Name $File -CommandType "Application" -ErrorAction "SilentlyContinue"

    $Result = $false

    foreach ($Path in ($Env:Path -split ";"))
    {
        if (Test-Path (Join-Path $Path $File))
        {
            $Result = $true
            break
        }
    }

    $Result
}

#===================================================================================================

function Out-Speak
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)] [string] $Text)

    process
    {
        if ($Text.Length -ne 0)
        {
            [System.Reflection.Assembly]::LoadWithPartialName("System.Speech") | Out-Null

            $SpeechSynthesizer = New-Object "System.Speech.Synthesis.SpeechSynthesizer"

            $SpeechSynthesizer.Speak($Text)
        }
    }
}

#===================================================================================================
