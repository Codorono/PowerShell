#=======================================================================================================================

Set-StrictMode -Version Latest

#=======================================================================================================================

function ql
{
	$args
}

#=======================================================================================================================

function qs
{
	"$args"
}

#=======================================================================================================================

function Get-Plural($Number)
{
	($Number -eq 1) ? "" : "s"
}

#=======================================================================================================================

function Get-Plurale($Number)
{
	($Number -eq 1) ? "" : "es"
}

#=======================================================================================================================

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

#=======================================================================================================================

function Get-OSVersion
{
	# Win7=0x0601, Win8=0x0602, Win81=0x0603, Win10=0x0A00

	$OSVersion = [System.Environment]::OSVersion.Version

	(($OSVersion.Major -shl 8) -bor $OSVersion.Minor)
}

#=======================================================================================================================

function Test-64BitProcess
{
	[System.Environment]::Is64BitProcess
}

#=======================================================================================================================

function Test-64BitSystem
{
	[System.Environment]::Is64BitOperatingSystem
}

#=======================================================================================================================

function Test-Administrator
{
#   (([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544")
	([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

#=======================================================================================================================

function Test-RegistryValue([string] $RegKey, [string] $Value)
{
	((Test-Path $RegKey) -and ((Get-ItemProperty -Path $RegKey -Name $Value -ErrorAction Ignore) -ne $null))
}

#=======================================================================================================================

function Test-VirtualPC
{
	$Baseboard = Get-CimInstance -Namespace "root\CIMV2" -ClassName "Win32_Baseboard"

	(($Baseboard.Manufacturer -eq "Microsoft Corporation") -and ($Baseboard.Product -eq "Virtual Machine"))
}

#=======================================================================================================================

function Search-Path([Parameter(Mandatory)] [string] $FileSpec)
{
	# WHERE.exe "$FileSpec"

	foreach ($EnvPath in ($Env:Path -split ";"))
	{
		$FilePath = Join-Path $EnvPath $FileSpec

		if (Test-Path $FilePath)
		{
			Get-ChildItem $FilePath -File | ForEach-Object { $_.FullName }
		}
	}
}

#=======================================================================================================================

function Test-SearchPath([Parameter(Mandatory)] [string] $FileSpec)
{
	# WHERE.exe /q "$FileSpec"
	# $LastExitCode -eq 0

	# Get-Command $FileSpec -CommandType "Application" -ErrorAction "Ignore"

	foreach ($EnvPath in ($Env:Path -split ";"))
	{
		if (Test-Path (Join-Path $EnvPath $FileSpec))
		{
			return $true
		}
	}

	return $false
}

#=======================================================================================================================

function Clear-Screen2
{
	$RawUI = $Host.UI.RawUI

	# get screen buffer size

	$Width = $RawUI.BufferSize.Width
	$Height = $RawUI.CursorPosition.Y

	# move cursor to top left

	$RawUI.CursorPosition = @{X = 0; Y = 0}

	# set screen buffer contents

	$RawUI.SetBufferContents(
		@{Left = 0; Top = 0; Right = $Width; Bottom = $Height},
		@{Character = ' '; ForegroundColor = $RawUI.ForegroundColor; BackgroundColor = $RawUI.BackgroundColor; BufferCellType = 0})
}

#=======================================================================================================================

function Clear-Screen3
{
	$RawUI = $Host.UI.RawUI

	$RawUI.CursorPosition = @{X = 0; Y = 0}

	$RawUI.SetBufferContents(
		@{Left = -1; Top = -1; Right = -1; Bottom = -1},
		@{Character = ' '; ForegroundColor = $RawUI.ForegroundColor; BackgroundColor = $RawUI.BackgroundColor; BufferCellType = 0})
}

#=======================================================================================================================

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

#=======================================================================================================================

function Out-Speak
{
	[CmdletBinding()]
	param([Parameter(ValueFromPipeline, ValueFromRemainingArguments)] [string] $Text)

	begin
	{
		$SpeechSynthesizer = [System.Speech.Synthesis.SpeechSynthesizer]::new()
	}

	process
	{
		if ($Text.Length -ne 0)
		{
			$SpeechSynthesizer.Speak($Text)
		}
	}
}

#=======================================================================================================================

function MkLink
{
	CMD.exe /c MKLINK $args
}

#=======================================================================================================================

function Code
{
	CMD.exe /c (Join-Path (Get-KnownFolderPath "UserProgramFiles") "Microsoft VS Code\bin\code.cmd") $args
}

#=======================================================================================================================

function GitHub
{
	CMD.exe /c (Join-Path (Get-KnownFolderPath "LocalAppData") "GitHubDesktop\bin\github.bat") $args
}

#=======================================================================================================================

function Npm
{
	CMD.exe /c (Join-Path (Get-KnownFolderPath "ProgramFiles") "nodejs\npm.cmd") $args
}

#=======================================================================================================================

function Npx
{
	CMD.exe /c (Join-Path (Get-KnownFolderPath "ProgramFiles") "nodejs\npx.cmd") $args
}

#=======================================================================================================================
