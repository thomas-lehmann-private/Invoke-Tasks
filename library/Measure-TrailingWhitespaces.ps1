<#
    The MIT License

    Copyright 2024 Thomas Lehmann.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
#>
Register-AnalyseTask -Name "AnalyzeTrailingWhitepaces" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    $MESSAGE = "Trailing whitespaces after {0}"
    $tokens = @()
    [System.Management.Automation.Language.Parser]::ParseInput( `
        $ScriptBlockAst.Extent.Text, [ref]$tokens, [ref]$null) | Out-Null

    for ($pos = 1; $pos -lt $tokens.Count; ++$pos) {
        # searching for a newline
        if ($tokens[$pos].Kind -ne [System.Management.Automation.Language.TokenKind]::NewLine) {
            continue
        }
        # a token before newline has to be on same line
        if ($tokens[$pos].Extent.StartLineNumber -ne $tokens[$pos-1].Extent.StartLineNumber) {
            continue
        }
        # between last token and newline (on same line) are spaces?
        if ($tokens[$pos].Extent.StartColumnNumber - $tokens[$pos-1].Extent.EndColumnNumber) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeTrailingWhitespaces'
                File = $PathAndFileName
                Line = $tokens[$pos].Extent.StartLineNumber
                Column = $tokens[$pos-1].Extent.EndColumnNumber
                Message = $MESSAGE -f $tokens[$pos-1].Kind
                Severity = 'information'
                Code = ''
            }
        } elseif ($tokens[$pos-1].Kind `
            -eq [System.Management.Automation.Language.TokenKind]::Comment) {
            if ($tokens[$pos-1].Extent.Text.EndsWith(' ')) {
                $TaskData.analyseResults += [PSCustomObject] @{
                    Type = 'AnalyzeTrailingWhitespaces'
                    File = $PathAndFileName
                    Line = $tokens[$pos].Extent.StartLineNumber
                    Column = $tokens[$pos-1].Extent.EndColumnNumber
                    Message = $MESSAGE -f $tokens[$pos-1].Kind
                    Severity = 'information'
                    Code = ''
                }
            }
        }
    }
}
