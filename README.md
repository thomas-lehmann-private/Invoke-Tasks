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

