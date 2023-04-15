#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function Extract-EscSeq($EscSeq)
{
    $EscSeq.Substring(2, $EscSeq.Length - 3)
}

#===================================================================================================

$ForegroundCodes = 30, 34, 32, 36, 31, 35, 33, 37, 90, 94, 92, 96, 91, 95, 93, 97
$BackgroundCodes = 40, 44, 42, 46, 41, 45, 43, 47, 100, 104, 102, 106, 101, 105, 103, 107

$DefaultForegroundCode = $ForegroundCodes[[int] $Host.UI.RawUI.ForegroundColor]
$DefaultBackgroundCode = $BackgroundCodes[[int] $Host.UI.RawUI.BackgroundColor]

$DefaultEscSeq = "`e[{0};{1}m" -f $DefaultForegroundCode, $DefaultBackgroundCode

Write-Host "Color Table"

foreach ($ForegroundCode in $ForegroundCodes)
{
    $Line = " "

    foreach ($BackgroundCode in $BackgroundCodes)
    {
        $Line += "`e[{0};{1}m {0};{1} " -f $ForegroundCode, $BackgroundCode
    }

    $Line += $DefaultEscSeq

    Write-Host $Line
}

Write-Host "PowerShell Colors"

Write-Host ("{0}  DefaultColor      - {1};{2}" -f $DefaultEscSeq, $DefaultForegroundCode, $DefaultBackgroundCode)

$FormatAccentCode = $ForegroundCodes[[int] $Host.PrivateData.FormatAccentColor]
Write-Host ("`e[{0}m  FormatAccentColor - {0}{1}" -f $FormatAccentCode, $DefaultEscSeq)

$ErrorAccentCode = $ForegroundCodes[[int] $Host.PrivateData.ErrorAccentColor]
Write-Host ("`e[{0}m  ErrorAccentColor  - {0}{1}" -f $ErrorAccentCode, $DefaultEscSeq)

$ErrorForegroundCode = $ForegroundCodes[[int] $Host.PrivateData.ErrorForegroundColor]
$ErrorBackgroundCode = $BackgroundCodes[[int] $Host.PrivateData.ErrorBackgroundColor]
Write-Host ("`e[{0};{1}m  ErrorColor        - {0};{1}{2}" -f $ErrorForegroundCode, $ErrorBackgroundCode, $DefaultEscSeq)

$WarningForegroundCode = $ForegroundCodes[[int] $Host.PrivateData.WarningForegroundColor]
$WarningBackgroundCode = $BackgroundCodes[[int] $Host.PrivateData.WarningBackgroundColor]
Write-Host ("`e[{0};{1}m  WarningColor      - {0};{1}{2}" -f $WarningForegroundCode, $WarningBackgroundCode, $DefaultEscSeq)

$DebugForegroundCode = $ForegroundCodes[[int] $Host.PrivateData.DebugForegroundColor]
$DebugBackgroundCode = $BackgroundCodes[[int] $Host.PrivateData.DebugBackgroundColor]
Write-Host ("`e[{0};{1}m  DebugColor        - {0};{1}{2}" -f $DebugForegroundCode, $DebugBackgroundCode, $DefaultEscSeq)

$VerboseForegroundCode = $ForegroundCodes[[int] $Host.PrivateData.VerboseForegroundColor]
$VerboseBackgroundCode = $BackgroundCodes[[int] $Host.PrivateData.VerboseBackgroundColor]
Write-Host ("`e[{0};{1}m  VerboseColor      - {0};{1}{2}" -f $VerboseForegroundCode, $VerboseBackgroundCode, $DefaultEscSeq)

$ProgressForegroundCode = $ForegroundCodes[[int] $Host.PrivateData.ProgressForegroundColor]
$ProgressBackgroundCode = $BackgroundCodes[[int] $Host.PrivateData.ProgressBackgroundColor]
Write-Host ("`e[{0};{1}m  ProgressColor     - {0};{1}{2}" -f $ProgressForegroundCode, $ProgressBackgroundCode, $DefaultEscSeq)

Write-Host "PSReadLine Colors"

$PSConsoleReadLineOptions = Get-PSReadLineOption

$CommandEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.CommandColor
Write-Host ("`e[{0}m  CommandColor                - {0}{1}" -f $CommandEscSeq, $DefaultEscSeq)

$CommentEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.CommentColor
Write-Host ("`e[{0}m  CommentColor                - {0}{1}" -f $CommentEscSeq, $DefaultEscSeq)

$ContinuationPromptEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.ContinuationPromptColor
Write-Host ("`e[{0}m  ContinuationPromptColor     - {0}{1}" -f $ContinuationPromptEscSeq, $DefaultEscSeq)

$DefaultTokenEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.DefaultTokenColor
Write-Host ("`e[{0}m  DefaultTokenColor           - {0}{1}" -f $DefaultTokenEscSeq, $DefaultEscSeq)

$EmphasisEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.EmphasisColor
Write-Host ("`e[{0}m  EmphasisColor               - {0}{1}" -f $EmphasisEscSeq, $DefaultEscSeq)

$ErrorEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.ErrorColor
Write-Host ("`e[{0}m  ErrorColor                  - {0}{1}" -f $ErrorEscSeq, $DefaultEscSeq)

$ErrorEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.InlinePredictionColor
Write-Host ("`e[{0}m  InlinePredictionColor       - {0}{1}" -f $ErrorEscSeq, $DefaultEscSeq)

$KeywordEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.KeywordColor
Write-Host ("`e[{0}m  KeywordColor                - {0}{1}" -f $KeywordEscSeq, $DefaultEscSeq)

$ErrorEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.ListPredictionColor
Write-Host ("`e[{0}m  ListPredictionColor         - {0}{1}" -f $ErrorEscSeq, $DefaultEscSeq)

$ErrorEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.ListPredictionSelectedColor
Write-Host ("`e[{0}m  ListPredictionSelectedColor - {0}{1}" -f $ErrorEscSeq, $DefaultEscSeq)

$MemberEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.MemberColor
Write-Host ("`e[{0}m  MemberColor                 - {0}{1}" -f $MemberEscSeq, $DefaultEscSeq)

$NumberEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.NumberColor
Write-Host ("`e[{0}m  NumberColor                 - {0}{1}" -f $NumberEscSeq, $DefaultEscSeq)

$OperatorEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.OperatorColor
Write-Host ("`e[{0}m  OperatorColor               - {0}{1}" -f $OperatorEscSeq, $DefaultEscSeq)

$ParameterEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.ParameterColor
Write-Host ("`e[{0}m  ParameterColor              - {0}{1}" -f $ParameterEscSeq, $DefaultEscSeq)

$SelectionEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.SelectionColor
Write-Host ("`e[{0}m  SelectionColor              - {0}{1}" -f $SelectionEscSeq, $DefaultEscSeq)

$StringEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.StringColor
Write-Host ("`e[{0}m  StringColor                 - {0}{1}" -f $StringEscSeq, $DefaultEscSeq)

$TypeEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.TypeColor
Write-Host ("`e[{0}m  TypeColor                   - {0}{1}" -f $TypeEscSeq, $DefaultEscSeq)

$VariableEscSeq = Extract-EscSeq $PSConsoleReadLineOptions.VariableColor
Write-Host ("`e[{0}m  VariableColor               - {0}{1}" -f $VariableEscSeq, $DefaultEscSeq)

#===================================================================================================
