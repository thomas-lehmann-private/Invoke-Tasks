# Analyse Task Registration

## Why?

Short: I'm not happy with writing custom rules for the PSSCriptAnalyzer.

## How it works

The `Invoke-Tasks` tool provides two functions:

 - `Register-AnalyseTask`
 - `Initialize-AnalyseTask`

The first one allows you to define a analyse function and the second one
allows you to define one configuration function to change the defaults.

Most optimal you would place a `Register-AnalyseTask` into a library file.
The `Initialize-AnalyseTask` has to be in a task file.

Basically an analyse task provides a function that is capable to traverse
the Powershell AST for each defined file. As a result you might get a list
of informations, warnings or errors with following structure:

```powershell
$results += [PSCustomObject] @{
    Type = $nameOfAnalyseFunction
    File = $PathAndFileName
    Line = $startLineWhereTheProblemHasBeenFound
    Column = $startColumnWhereTheProblemHasBeenFound
    Message = $messageWhatTheProblemExactlyIs
    Severity = $severityOfTheProblem
    Code = $optionalCodeFragmentWhereTheProblemHasBeenFound
}
```

## Registration of an analyse task

### Basic usage (by example)

Best explained by given example which is checking the line length.
The parameters are always those three:

- `$TaskData` to read configuration details (see `$TaskData.analyseConfiguration`) and to write the results (see `$TaskData.analyseResults`)
- `$PathAndFileName` the script that should be analyzed
- `$ScriptBlockAst` the Powershell AST for the script

The names of the parameters are not required to match but the order is important.
The AST is passed since an AST read one time will be used by several analyse tasks.


```powershell
Register-AnalyseTask -Name "AnalyzeLineLength" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration or set default
    $maximumLineLength = if ($TaskData.analyseConfiguration.AnalyzeLineLength) {
        $TaskData.analyseConfiguration.AnalyzeLineLength.MaximumLineLength
    } else {
        100
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.StatementAst]}
    $results = $ScriptBlockAst.FindAll($predicate, $true) | ForEach-Object {
        if ($_.Extent.EndColumnNumber -gt $maximumLineLength) {
            [PSCustomObject] @{
                Type = 'AnalyzeLineLength'
                File = $PathAndFileName
                Line = $_.Extent.StartLineNumber
                Column = $_.Extent.StartColumnNumber
                Message = "Line too long (exceeds {0})" -f $maximumLineLength
                Severity = 'information'
                Code = $_.Extent.Text
            }
        }
    }

    # for each line number take first reported problem only
    $results = $results | Group-Object Line | ForEach-Object {
        $_.Group | Select-Object -First 1
    }

    $TaskData.analyseResults += $results
}
```

When using this it could look like following (temporarily changed the default to 90):

```
Type              File               Line Column Message                    Severity    Code
----              ----               ---- ------ -------                    --------    ----
AnalyzeLineLength ./Invoke-Tasks.ps1  294     13 Line too long (exceeds 90) information $capturedDetails += [PSCustomObject] @{$name = $found.Matches.Groups[1].Value}
AnalyzeLineLength ./Invoke-Tasks.ps1  441      9 Line too long (exceeds 90) information Write-Message ("Running with Powershell in version {0}" -f $PSVersionTable.PSVersio…
AnalyzeLineLength ./Invoke-Tasks.ps1  457     17 Line too long (exceeds 90) information $fileNames = $TaskData.analyseConfiguration.Global.AnalyzePathAndFileNames
AnalyzeLineLength ./Invoke-Tasks.ps1  506      9 Line too long (exceeds 90) information $allowedFunctions = @("Register-Task", 'Initialize-AnalyseTask', 'Register-AnalyseT…
AnalyzeLineLength ./Invoke-Tasks.ps1  560     21 Line too long (exceeds 90) information throw "line {0}: {1} allowed only" `…
AnalyzeLineLength ./Invoke-Tasks.ps1  561     65 Line too long (exceeds 90) information $AllowedFunctions -Join " and "
```


## The initialize task

Enable of analyse tasks is done by providing a call to `Initialize-AnalyseTask`;
you can define one only.

It's important to provide a list of files, otherwise no analyse will be done.
For each file the AST is read and passed to each analyse task. If you
don't specify your own settings for analyse tasks the defaults are used as
documented in [Static code analysis](static-code-analysis.md).

```powershell
Initialize-AnalyseTask {
    param ([hashtable] $TaskData)

    $files = @('./Invoke-Tasks.ps1')
    $files += Get-ChildItem -Path './library' -Filter *.ps1
    $files += Get-ChildItem -Path './tests' -Filter *.ps1

    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = $files
        }
        # other settings
    }
}
```
