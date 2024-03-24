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
        $TaskData.analyseConfiguration.AnalyzeMagicValues.Excludes # custom
    } else { @(0, 1, "`"`"", "`"{0}`"") } # default
    # get all tokens of the file
    $statistics = @{}
    $tokens = @()
    [System.Management.Automation.Language.Parser]::ParseInput(`
        $ScriptBlockAst.Extent.Text, [ref]$tokens, [ref]$null) | Out-Null
    # filtering for following token kinds
    $magicValuesKinds = @(
        [System.Management.Automation.Language.TokenKind]::Number,
        [System.Management.Automation.Language.TokenKind]::StringLiteratal,
        [System.Management.Automation.Language.TokenKind]::StringExpandable
    )
    
    foreach ($token in $tokens) {
        if ($token.Kind -in $magicValuesKinds) { # searched token kind?
            if ($token.Extent.Text -in $excludes) { # excluded?
                continue
            }

            if ($statistics.ContainsKey($token.Extent.Text)) {
                $statistics[$token.Extent.Text].Count += 1 # is one of those magic values
            } else {
                $statistics[$token.Extent.Text] = [PSCustomObject] @{Token=$token; Count=1} # first
            }
        }
    }

    foreach ($item in $statistics.GetEnumerator()) {
        if ($item.Value.Count -gt 1) { # if a magic value appears more than once
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeMagicValues'                         # type of analyse
                File = $PathAndFileName                             # file that has been analyzed
                Line = $item.Value.Token.Extent.StartLineNumber     # line of the issue
                Column = $item.Value.Token.Extent.StartColumnNumber # column of the issue
                Message = "Magic value: ({0} used more than once)" -f $item.Value.Token.Kind
                Severity = 'warning'                                # severity of the issue
                Code = $item.Value.Token.Extent.Text                # magic value
            }
        }
    }
}
