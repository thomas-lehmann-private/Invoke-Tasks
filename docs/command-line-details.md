# Command line details

## Get-Help Details

```
NAME
    Invoke-Tasks
    
SYNOPSIS
    Running Powershell tasks in order (default)
    
    
SYNTAX
    Invoke-Tasks [[-TaskFile] <String>] [[-TaskData] <Hashtable>] [[-Tags] <String[]>] [[-CaptureRegexes] 
    <String[]>] [[-TaskLibraryPath] <String>] [-Quiet] [<CommonParameters>]
    
    
DESCRIPTION
    Running tasks in order of appearence but also recognize dependencies
    to ensure that those tasks run first. If you throw an exception
    the task processing is stopped with the error printed you have
    choosen.
    

PARAMETERS
    -TaskFile <String>
        The default is tasks.ps1 in current folder but you also can
        define another path and filename.
        
    -TaskData <Hashtable>
        Possibility to give parameters to the tasks (default is empty hashtable)
        The data can be modified by the tasks
        
    -Tags <String[]>
        When specifying you can filter for tasks, all others will be adjusted to
        completed without being executed then.
        
    -CaptureRegexes <String[]>
        List of regexes in the format name=<regex>
        Matching text in task outputs will be written to a 'captured.json' after processing.
        
    -TaskLibraryPath <String>
        Path with a Powershell script that does provide reusable tasks.
        Can also be a folder with scripts.
        
    -Quiet [<SwitchParameter>]
        Hide all output except errors and task output itself
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
REMARKS
    To see the examples, type: "Get-Help Invoke-Tasks -Examples"
    For more information, type: "Get-Help Invoke-Tasks -Detailed"
    For technical information, type: "Get-Help Invoke-Tasks -Full"
```

## Quiet

You can specify `-Quiet` when using `Invoke-Tasks` then you see errors and the output of
the tasks itself only.

## Tags

You can specify multiple tags at each task.
When specifying one of those tags with `Invoke-Tasks`
only those tasks are executed that do match.

```powershell
Register-Task -Name "First Task" -Tags first {
    Write-Host "First Task"
}

Register-Task -Name "Second Task" -Tags second {
    Write-Host "Second Task"
}
```

With `Invoke-Tasks -Tags second` second task will be processed only.

**Please note**: If you have specified a matching task with a task
as dependency that don't match then those task is executed too because
a dependency has higher priority.

## Capturing via regex

Main reason for introducing this was to capture information required for the build
process. In concrete scenario I intended to get the code coverage percentage for
a badge. When your tasks output does print somewhere `Covered 96,67%` you can execute
all with:

```powershell
Invoke-Tasks -CaptureRegexes "coverage=Covered (\d+)" 
```

A `captured.json` does look then like following:

```json
{
  "coverage": "96"
}
```

With following command you simply get the value in your build process:

```powershell
pwsh -Command "$(Get-Content captured.json|ConvertFrom-JSON).coverage"
```

## Library Tasks

It's possible to reuse tasks keeping those task in a library file.
The library file has same syntax using the `Register-Task` mechanism.

**Example for library**:

```powershell
Register-Task -Name "Say Message" {
    param ([hashtable] $TaskData)
    Write-Message $TaskData.Parameters.Message
}
```

**Configuration on commandline**:

```powershell
Invoke-Tasks -TaskLibraryFile ./task-library.ps1
```

Using this task you can do it like following:

```powershell
Use-Task -Name "My Say Message 1" -LibraryTaskName "SayMessage" {
    param ([hashtable] $TaskData)
    $TaskData.Parameters.Message = "hello world!"
}
```

It's a contract that `$TaskData.Parameters` is required to be configured as the library
task has defined. In this scenarion the field `Message` is used. The process is simply
that the codeblock of the `Use-Task` is executed first and then the depedencies (reverse order).
Currently it is not implemented to use tags and dependencies on `Use-Task`
