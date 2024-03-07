![Build](https://github.com/thomas-lehmann-private/Invoke-Tasks/actions/workflows/invoke-tasks-build-actions.yaml/badge.svg) ![CoverageVadge](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/Nachtfeuer/2279dcc04bff0c1ef7b8038821f23d2e/raw/Invoke-Tasks.json) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Documentation](https://img.shields.io/badge/documentation-ok-%2300ff00)](https://thomas-lehmann-private.github.io/Invoke-Tasks)

# Invoke-Tasks
Powershell based task processing. You do not require another module. For detailed documentation please click documentation badge to get to github pages of this repository.

## Feature summary

 - Pure Powershell with a single script and no module/assembly dependency
 - Running tasks in defined order
 - Each task can have one dependency that runs first
 - Capturing multiple output by defining named regexes written into a `captured.json`
 - Tasks can be tagged allowing to filter for tasks
 - Tasks can be skipped
 - It's possible to define task libraries (file as well as folder)
 - Scripts are checked to use API functions only.
 - Invoke-Tasks output can be hidden
 - Task data (hashtable) can be shared accross all tasks
 - Performance output for each individual task
 - Supporting analyse tasks for static code analysis based on Powershell AST

## Quickstart

Simply define a **tasks.ps1** with following content:

```powershell
Register-Task -Name "Hello world!" {
    Write-Host 'hello world!'
}
```

When executing `Invoke-Tasks` the result looks like following (OS and Powershell version depend on your system):

```
Invoke-Tasks :: Running on OS Darwin 23.2.0 Darwin Kernel Version 23.2.0: Wed Nov 15 21:53:18 PST 2023; root:xnu-10002.61.3~2/RELEASE_ARM64_T6000‚
Invoke-Tasks :: Running with Powershell in version 7.4.1
Invoke-Tasks ::   ... task data {}
Invoke-Tasks ::   ... 1 tasks found in 

Name DependsOn Skip  Parameters
---- --------- ----  ----------
Demo           False 

Invoke-Tasks :: Running task 'Demo'
hello world!
Invoke-Tasks ::  ... took 0,0088361 seconds!
```

Invoke-Task does look for a **tasks.ps1** in current working directory.
You also can use `Invoke-Tasks -TaskFile demo.ps1` for specifying another path
and filename.

## Documentation

```
NAME
    /Users/thomaslehmann/Documents/Programmierung/Invoke-Tasks/Invoke-Tasks.ps1

SYNOPSIS
    Running Powershell tasks in order (default)


SYNTAX
    /Users/thomaslehmann/Documents/Programmierung/Invoke-Tasks/Invoke-Tasks.ps1 [[-TaskFile] <String>] [[-TaskData] <Hashtable>] [[-Tags] <String[]>] [[-CaptureRegexes] <String[]>] 
    [[-TaskLibraryFile] <String>] [-Quiet] [<CommonParameters>]

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

    -TaskLibraryFile <String>

    -Quiet [<SwitchParameter>]
        Hide all output except errors and task output itself

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 

REMARKS
    To see the examples, type: "Get-Help /Users/thomaslehmann/Documents/Programmierung/Invoke-Tasks/Invoke-Tasks.ps1 -Examples"
    For more information, type: "Get-Help /Users/thomaslehmann/Documents/Programmierung/Invoke-Tasks/Invoke-Tasks.ps1 -Detailed"
    For technical information, type: "Get-Help /Users/thomaslehmann/Documents/Programmierung/Invoke-Tasks/Invoke-Tasks.ps1 -Full"
```

## Tasks with dependencies

For each task you can specify exactly one dependency by using the
name of the related task. With this you can change the order of
the task execution.

```powershell
Register-Task -Name "First Task" -DependsOn "Second Task" {
    Write-Host "First Task"
}

Register-Task -Name "Second Task" {
    Write-Host "Second Task"
}
```

In this case the output of the second task appears before the output of the first task.

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


## Links

 - https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-powershell
 - https://github.com/marketplace/actions/dynamic-badges
 - https://pester.dev/docs/commands/New-PesterConfiguration

