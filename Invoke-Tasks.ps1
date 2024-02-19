<#PSScriptInfo

.VERSION 1.0.0

.GUID b15fc537-a421-4405-b07f-c5dc945ed3ef

.AUTHOR Thomas Lehmann

.COPYRIGHT (c) 2024 by Thomas Lehmann

.TAGS tasks

.LICENSEURI https://mit-license.org

.PROJECTURI https://github.com/thomas-lehmann-private/Invoke-Tasks

.RELEASENOTES

    1.0.0 - First version
#>

<#
.SYNOPSIS
    Running tasks.
.DESCRIPTION
    Running tasks in order of appearence but also recognize dependencies
    to ensure that those tasks run first. If you throw an exception
    the task processing is stopped with the error printed you have
    choosen.
.PARAMETER TaskFile
    The default is tasks.ps1 in current folder but you also can
    define another one.
.PARAMETER TaskData
    Possibility to give parameters to the tasks (default is empty hashtable)
    The data can be modified by the tasks
.PARAMETER Tags
    When specifying you can filter for tasks, all others will be adjusted to
    completed without being executed then.
.PARAMETER CaptureRegexes
    List of regexes in the format name=<regex>
.PARAMETER Quiet
    Hide all output except errors and task output itself
.NOTES
    Runs on all plattforms
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
param (
    [String] $TaskFile = './tasks.ps1',
    [Hashtable] $TaskData = @{},
    [String[]] $Tags = @(),
    [String[]] $CaptureRegexes = @(),
    [switch] $Quiet = $false
)

$global:tasks = @()

function Write-Message() {
    param([String] $Message)
    Write-Information "Invoke-Tasks :: $Message" -InformationAction Continue
}

function Register-Task() {
    param (
        [String] $Name,
        [scriptblock] $ScriptBlock,
        [String[]] $Tags = @(),
        [String] $DependsOn = $null,
        [Switch] $Skip = $false
    )

    $global:tasks += [PSCustomObject] @{
        Name = $Name
        ScriptBlock = $ScriptBlock
        Tags = $Tags
        DependsOn = $DependsOn
        Skip = $Skip
        Completed = $false
    }
}

# ensure that all tasks are registered
. $TaskFile

$uniqueTasks = $tasks | ForEach-Object { $_.Name} | Get-Unique
if ($uniqueTasks.Count -ne $tasks.Count) {
    Write-Error ("At least one task has same name as another!")
    Exit 1
}

if (-not $Quiet) {
    Write-Message ("Running on OS {0}" -f $PSVersionTable.OS)
    Write-Message ("Running with Powershell in version {0}" -f $PSVersionTable.PSVersion)
    Write-Message ("  ... task data: {0}" -f $($TaskData | ConvertTo-Json).replace("`n", ""))
    Write-Message ("  ... capture regexes: {0}" -f $($CaptureRegexes -Join " , "))
    Write-Message ("  ... {0} tasks found in {1}" -f $tasks.Count, $ScriptFile)

    $tasks | Select-Object Name, DependsOn, Skip, Parameters | Format-Table
}

$capturedDetails = @()

$errorFound = $false
while (-not $errorFound) {
    $count = 0
    foreach ($task in $global:tasks) {
        if ($task.Skip -or $task.Completed) {
            $count += 1
            continue
        }

        if ($Tags.Count -gt 0) {
            $foundTag = $false
            foreach ($tag in $Tags) {
                if ($Task.Tags -contains $tag) {
                    $foundTag = $true
                    break
                }
            }

            if (-not $foundTag) {
                $task.Completed = $true
                continue
            }
        }

        if ($task.DependsOn) {
            $dependencies = $global:tasks | Where-Object { $_.Name -eq $task.DependsOn }
            if ($dependencies.Count -ne 1) {
                Write-Error ("No such task as dependency: {0}" -f $task.DependsOn)
                $errorFound = $true
            }

            if (-not $dependencies.Completed) {
                continue
            }
        }

        if (-not $Quiet) {
            Write-Message ("Running task '{0}'" -f $task.Name)
        }

        try {
            $performance = Measure-Command {
                Invoke-Command `
                    -ScriptBlock $task.ScriptBlock `
                    -ArgumentList $TaskData `
                    6>&1 `
                    | Tee-Object -Variable output | Out-Default

                # trying to capture output for defined regexes
                foreach ($captureRegex in $CaptureRegexes) {
                    $separatorPos = $captureRegex.IndexOf('=')
                    $name = $captureRegex.SubString(0, $separatorPos)
                    $regex = $captureRegex.SubString($separatorPos+1)
                    $found = $($output | Select-String -Pattern $regex)
                    if ($found) {
                        $capturedDetails += [PSCustomObject] @{$name = $found.Matches.Groups[1].Value}
                    }
                }
            }
            if (-not $Quiet) {
                Write-Message (" ... took {0} seconds!" -f $performance.TotalSeconds)
            }
        } catch {
            Write-Error ("{0}" -f $_)
            $errorFound = $true
        }
        $task.Completed = $true
        $count += 1
    }

    if ($count -eq $tasks.Count) {
        break
    }
}

if ($capturedDetails.Count -gt 0) {
    $capturedDetails `
    | ConvertTo-Json `
    | Set-Content -Path captured.json
}

if ($errorFound) {
    Exit 1
}