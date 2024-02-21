![Build](https://github.com/thomas-lehmann-private/Invoke-Tasks/actions/workflows/invoke-tasks-build-actions.yaml/badge.svg) ![CoverageVadge](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/Nachtfeuer/2279dcc04bff0c1ef7b8038821f23d2e/raw/Invoke-Tasks.json)

# Invoke-Tasks
Powershell based task processing. You do not require another module.

## Quickstart

Simply define a **tasks.ps1** with following content:

```powershell
Register-Task -Name "Demo" {
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

## Links

 - https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-powershell
