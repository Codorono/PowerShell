#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function prompt
{
    # get current path

    $PathInfo = $ExecutionContext.SessionState.Path.CurrentLocation

    $CurrentPath = ($PathInfo.Drive -ne $null) ? $PathInfo.Path : $PathInfo.ProviderPath

    if ($CurrentPath.StartsWith($Home, [System.StringComparison]::OrdinalIgnoreCase))
    {
        $CurrentPath = "~" + $CurrentPath.SubString($Home.Length)
    }

    # set title

    $PSVersion = $PSVersionTable.PSVersion

    $WindowTitle = "{0} -- PowerShell {1}.{2}.{3} ({4})" -f $CurrentPath, $PSVersion.Major,
        $PSVersion.Minor, $PSVersion.Patch, ((Test-64BitProcess) ? "x64" : "x86")

    if (Test-Path Variable:ConsoleTitle)
    {
        $WindowTitle = $WindowTitle + " -- " + $ConsoleTitle
    }

    if (Test-Administrator)
    {
        $WindowTitle = "Administrator: " + $WindowTitle
    }

    $Host.UI.RawUI.WindowTitle = $WindowTitle

    # set prompt

    "{0}{1} " -f $CurrentPath, ('>' * ($NestedPromptLevel + 1))
}

#===================================================================================================
