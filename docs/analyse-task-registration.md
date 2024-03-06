# Analyse Task Registration

## Why?

While writing AST functions can be challenging (but solvable) writing PSScriptAnalyzer rules
didn't work for me. Also I did write the code exactly as defined in documentation
(which is well documented) the using of the rules simply fails and I don't know
why. That's why I considered to extent the `Invoke-Task` by a mechanism that is
really simple to use and it works. Also in some cases I got false positives which
are really annoying and with the static code analysis mechanism under control I can
provide a mechanism that is more easier to handle (future updates).


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
Register-AnalyseTask -Name "Analyze Line Length" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration or set default
    $maximumLineLength = if ($TaskData.analyseConfiguration.'Analyze Line Length') {
        $TaskData.analyseConfiguration.'Analyze Line Length'.MaximumLineLength
    } else {
        100
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.StatementAst]}
    $results = $ScriptBlockAst.FindAll($predicate, $true) | ForEach-Object {
        if ($_.Extent.EndColumnNumber -gt $maximumLineLength) {
            [PSCustomObject] @{
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
File               Line Column Message                    Severity    Code
----               ---- ------ -------                    --------    ----
./Invoke-Tasks.ps1  294     13 Line too long (exceeds 90) information $capturedDetails += [PSCustomObject] @{$name = $found.Matches.Groups[1].Value}
./Invoke-Tasks.ps1  441      9 Line too long (exceeds 90) information Write-Message ("Running with Powershell in version {0}" -f $PSVersionTable.PSVersion)
./Invoke-Tasks.ps1  457     17 Line too long (exceeds 90) information $fileNames = $TaskData.analyseConfiguration.Global.AnalyzePathAndFileNames
./Invoke-Tasks.ps1  506      9 Line too long (exceeds 90) information $allowedFunctions = @("Register-Task", 'Initialize-AnalyseTask', 'Register-AnalyseTask')
./Invoke-Tasks.ps1  560     21 Line too long (exceeds 90) information throw "line {0}: {1} allowed only" `…
./Invoke-Tasks.ps1  561     65 Line too long (exceeds 90) information $AllowedFunctions -Join " and "
```
