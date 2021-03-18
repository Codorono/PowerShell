function prompt
{
    # set prompt

    $PathInfo = $ExecutionContext.SessionState.Path.CurrentLocation

    $CurrentPath = ($PathInfo.Drive -ne $null) ? $PathInfo.Path : $PathInfo.ProviderPath

    if ($CurrentPath.StartsWith($Home, [System.StringComparison]::OrdinalIgnoreCase))
    {
        $CurrentPath = "~" + $CurrentPath.SubString($Home.Length)
    }

    "{0}{1} " -f $CurrentPath, ('>' * ($NestedPromptLevel + 1))

    # set title

    $PSVersion = $PSVersionTable.PSVersion

    $Title = "{0}{1} ~ PowerShell {2}.{3} {4}" -f ((Test-Administrator) ? "Admin: " : ""), $CurrentPath,
        $PSVersion.Major, $PSVersion.Minor, ((Test-64BitProcess) ? "(x64)" : "(x86)")

    $Host.UI.RawUI.WindowTitle = $Title
}
