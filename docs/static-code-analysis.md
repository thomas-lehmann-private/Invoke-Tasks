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
            MaximumLineLength = 80
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
            MaximumFunctionCount = 30
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
            MaximumLineCount = 500
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
        # other settings
    }
}
```
The severity is `warning`.
