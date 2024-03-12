# Static code analysis

## Checking for line length

The default is 100. You can change it like following:

```powershell
Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./Invoke-Tasks.ps1')
        }
        AnalyzeLineLength = @{
            MaximumLength = 80
        }
        # other settings
    }
}
```
The severity is `information`.

## Checking for count of functions

The default is 20. You can change it like following:

```powershell
Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./Invoke-Tasks.ps1')
        }
        AnalyzeFunctionCount = @{
            MaximumCount = 30
        }
        # other settings
    }
}
```
The severity is `information`.

## Checking for line count

The default is 1000. You can change it like following:

```powershell
Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./Invoke-Tasks.ps1')
        }
        AnalyzeLineCount = @{
            MaximumCount = 500
        }
        # other settings
    }
}
```
The severity is `information`.

## Checking for function line count

The default is 50. You can change it like following:

```powershell
Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./Invoke-Tasks.ps1')
        }
        AnalyzeFunctionLineCount = @{
            MaximumCount = 45
        }
        # other settings
    }
}
```
The severity is `warning`.


## Checking for function parameter count

The default is 5. You can change it like following:

```powershell
Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./Invoke-Tasks.ps1')
        }
        AnalyzeFunctionParameterCount = @{
            MaximumCount = 2
        }
        # other settings
    }
}
```
The severity is `warning`.

## Checking for function name

The name should be always like this:

- Using a known verb before the dash like `Initialize` (see Get-Verb)
- The name in CamelCase after the dash like `AnalyseTask` 

You cannot change the verb checking. But you can Change the regex for the name
after the dash like this (showing the default here):

```powershell
Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./Invoke-Tasks.ps1')
        }
        AnalyzeFunctionName = @{
            FunctionNameRegex = "^[A-Z][a-z]+([A-Z][a-z]+)*$"
        }
        # other settings
    }
}
```

The severity is `warning`.

## Checking for script block line count

The default is 50. You can change it like following:

```powershell
Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./Invoke-Tasks.ps1')
        }
        AnalyzeScriptBlockLineCount = @{
            MaximumCount = 45
        }
        # other settings
    }
}
```
The severity is `warning`.

**Please note**: The limit includes also functions since
a function does have a script block too. The main focus
of course a script block that are not function (eventually
I can filter out those ones later one)
