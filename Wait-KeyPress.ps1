﻿#=======================================================================================================================

using namespace System.Management.Automation.Host

#=======================================================================================================================

Set-StrictMode -Version Latest

#=======================================================================================================================

$Host.UI.Write("`e[32mPress any key to continue . . . `e[37m")

$Host.UI.RawUI.FlushInputBuffer()

[void] $Host.UI.RawUI.ReadKey([ReadKeyOptions]::NoEcho -bor [ReadKeyOptions]::IncludeKeyDown)

#=======================================================================================================================
