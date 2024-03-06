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
        'Analyze Line Length' = @{
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
        'Analyze Function Count' = @{
            MaximumFunctionCount = 30
        }
        # other settings
    }
}
```
The severity is `information`.
