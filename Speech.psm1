#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function Out-Speak
{
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline, ValueFromRemainingArguments)] [string] $Text)

    begin
    {
        if ($SpeechAssembly -eq $null)
        {
            $Script:SpeechAssembly = [System.Reflection.Assembly]::Load("System.Speech")
        }
    }

    process
    {
        if ($Text.Length -ne 0)
        {
            $SpeechSynthesizer = New-Object -TypeName "System.Speech.Synthesis.SpeechSynthesizer"

            $SpeechSynthesizer.Speak($Text)
        }
    }
}

#===================================================================================================

# speech assembly

$SpeechAssembly = $null

#===================================================================================================
