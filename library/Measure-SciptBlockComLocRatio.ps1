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
# ignore AnalyzeScriptBlockLineCount on line 25 because this is an acceptable exception
Register-AnalyseTask -Name "AnalyzeScriptBlockComLocRatio" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    $comLocRatio = 0.25 # default ration
    $minimumLines = 3   # default minimum lines in a block
    # get configuration
    if ($TaskData.analyseConfiguration.AnalyzeScriptBlockComLocRatio) {
        $comLocRatio = $TaskData.analyseConfiguration.AnalyzeScriptBlockComLocRatio.Ratio
        $minimumLines = $TaskData.analyseConfiguration.AnalyzeScriptBlockComLocRatio.MinimumLines
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.ScriptBlockAst]}
    $blocks = $ScriptBlockAst.FindAll($predicate, $true)
    $blocks
        | Where-Object {
            $_.Parent -and $($_.Parent.GetType() `
                -ne [System.Management.Automation.Language.FunctionDefinitionAst])
        }
        | ForEach-Object {
            $block = $_        # block ast
            $tokens = @()      # list of tokens inside a block
            $linesBlock = 0    # lines in a block
            $tokenCount = 0    # tokens before end of line
            $linesComment = 0  # lines with comment

            [System.Management.Automation.Language.Parser]::ParseInput(`
                $block.Extent.Text, [ref]$tokens, [ref]$null) | Out-Null
            foreach ($token in $tokens) {
                if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment) {
                    $linesComment += 1 # one more lines of comments
                } elseif ($token.Kind -eq `
                    [System.Management.Automation.Language.TokenKind]::NewLine) {
                    if ($tokenCount -gt 0) {
                        $linesBlock += 1 # one more line in the block
                    }
                    $tokenCount = 0
                } else {
                    $tokenCount += 1
                }
            }
            $ratio = $linesComment / $linesBlock # calculate the ratio
            if (($ratio -lt $comLocRatio) -and ($linesBlock -ge $minimumLines)) {
                $TaskData.analyseResults += [PSCustomObject] @{
                    Type = 'AnalyzeScriptBlockComLocRatio'   # type of analyse
                    File = $PathAndFileName                  # file that has been analyzed
                    Line = $block.Extent.StartLineNumber     # line of the issue
                    Column = $block.Extent.StartColumnNumber # column of the issue
                    Message = "Too less comments in script block ({0}/{1}={2:F2} is below {3})" `
                        -f $linesComment, $linesBlock, $ratio, $comLocRatio
                    Severity = 'warning'                     # severity of the issue
                    Code = ""                                # code is not used here
                }
            }
        }
}
