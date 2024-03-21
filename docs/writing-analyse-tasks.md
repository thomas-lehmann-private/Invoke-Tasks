# Writing analyse tasks

## Parsing AST

Parsing of a powershell AST can be done like following:

```powershell
$content = Get-Content Invoke-Tasks.ps1 -Raw
$scriptBlockAst = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, [ref]$null)
```

With this you get a **ScriptBlockAst** which is the root ast node for a complete script.
This is used in `Invoke-Tasks.ps1` (as an example)

After this you usally will have to filter for AST nodes you are interested in. 
Filtering for functions would look like following:

```powershell
$predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
$functions = $ScriptBlockAst.FindAll($predicate, $true)
$functions | ForEach-Object {
    $function = $_
    # do something
}
```


## Parsing tokens

In some situations you cannot work with AST only. As an example the comments (`# some comment`) inside a script
you won't find in the AST. Therefor you have to explizit parse the tokens like following:

```powershell
$tokens = @()
[System.Management.Automation.Language.Parser]::ParseInput(`
    $scriptBlockAst.Extent.Text, [ref]$tokens, [ref]$null) | Out-Null

foreach ($token in $tokens) {
    # do something
}
```

Of course you can use both but in the example the focus was to have the tokens only.
This is used in `Measure-FunctionComLocRatio.ps1` (as an example).

Using `$token.Kind` is then the way to go.

```powershell
if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment) {
    # do something
}
```

## The analyse task registration

It's best explained by a given example:

```powershell
Register-AnalyseTask -Name "AnalyzeFunctionLineCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeFunctionLineCount) {
        $TaskData.analyseConfiguration.AnalyzeFunctionLineCount.MaximumCount
    } else {
        50
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    $functions | ForEach-Object {
        $function = $_

        $lineCount = $function.Extent.EndLineNumber - $function.Extent.StartLineNumber

        if ($lineCount -gt $maximumCount) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionLineCount'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Too many lines in function '{0}' ({1} exceeds {2})" `
                    -f $function.Name, $lineCount, $maximumCount
                Severity = 'warning'
                Code = ""
            }
        }
    }
}
```

### Using $TaskData

The Parameter `$TaskData` is used to share input and output across multiple tasks executions
indepent of the kind of task. It's a (advisible) convention to use certain attributes of
this Hastable as documented:

 - `$TaskData.analyseConfiguration`: it's the Hashtable for all configurations for the analyse tasks.
   The concrete configuration in the example is `$TaskData.analyseConfiguration.AnalyzeFunctionLineCount`
   which is documented in [Static code analysis](static-code-analysis.md).
 - `$TaskData.analyseResults`: it's a list of reported issued. Each issue should be a hashtable with the attributes **Type**,
   **File**, **Line**, **Column**, **Message**, **Severity** and **Code**.

