# Invoke-Tasks
Powershell based task processing

## Quickstart

Define a **tasks.ps1** with following content:

```powershell
Register-Task -Name "Demo" {
    Write-Host 'hello world!'
}
```

When executing `Invoke-Tasks` the result looks like following (OS and Powershell version depend on your system):

```
Invoke-Tasks :: Running on OS Darwin 23.2.0 Darwin Kernel Version 23.2.0: Wed Nov 15 21:53:18 PST 2023; root:xnu-10002.61.3~2/RELEASE_ARM64_T6000
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

You also can use `Invoke-Tasks -TaskFile demo.ps1` for specifying another path
and filename.
