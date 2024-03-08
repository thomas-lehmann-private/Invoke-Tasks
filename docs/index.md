# Invoke-Tasks Documentation

Welcome to the documentation of the `Invoke-Tasks` tool.
Please check the user guide on the left side for details
or search for a topic.

Here's   the feature list:

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
