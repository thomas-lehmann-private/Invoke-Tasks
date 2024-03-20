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
Register-AnalyseTask -Name "AnalyzeMagicValues" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $excludes = if ($TaskData.analyseConfiguration.AnalyzeMagicValues) {
        $TaskData.analyseConfiguration.AnalyzeMagicValues.Excludes
    } else { @(0, 1, "`"`"", "`"{0}`"") }

    $statistics = @{}
    $tokens = @()
    [System.Management.Automation.Language.Parser]::ParseInput(`
        $ScriptBlockAst.Extent.Text, [ref]$tokens, [ref]$null) | Out-Null

    $magicValuesKinds = @(
        [System.Management.Automation.Language.TokenKind]::Number,
        [System.Management.Automation.Language.TokenKind]::StringLiteratal,
        [System.Management.Automation.Language.TokenKind]::StringExpandable
    )
    
    foreach ($token in $tokens) {
        if ($token.Kind -in $magicValuesKinds) {
            if ($token.Extent.Text -in $excludes) {
                continue
            }

            if ($statistics.ContainsKey($token.Extent.Text)) {
                $statistics[$token.Extent.Text].Count += 1
            } else {
                $statistics[$token.Extent.Text] = [PSCustomObject] @{Token=$token; Count=1}
            }
        }
    }

    foreach ($item in $statistics.GetEnumerator()) {
        if ($item.Value.Count -gt 1) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeMagicValues'
                File = $PathAndFileName
                Line = $item.Value.Token.Extent.StartLineNumber
                Column = $item.Value.Token.Extent.StartColumnNumber
                Message = "Magic value: ({0} used more than once)" -f $item.Value.Token.Kind
                Severity = 'warning'
                Code = $item.Value.Token.Extent.Text
            }
        }
    }
}
