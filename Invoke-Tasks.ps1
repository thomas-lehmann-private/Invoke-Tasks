<#
    The MIT License

    Copyright 2022 Thomas Lehmann.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
#>

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
    Running Powershell tasks in order (default)
.DESCRIPTION
    Running tasks in order of appearence but also recognize dependencies
    to ensure that those tasks run first. If you throw an exception
    the task processing is stopped with the error printed you have
    choosen.
.PARAMETER TaskFile
    The default is tasks.ps1 in current folder but you also can
    define another path and filename.
.PARAMETER TaskData
    Possibility to give parameters to the tasks (default is empty hashtable)
    The data can be modified by the tasks
.PARAMETER Tags
    When specifying you can filter for tasks, all others will be adjusted to
    completed without being executed then.
.PARAMETER CaptureRegexes
    List of regexes in the format name=<regex>
    Matching text in task outputs will be written to a 'captured.json' after processing.
.PARAMETER TaskLibraryPath
    Path with a Powershell script that does provide reusable tasks.
    Can also be a folder with scripts.
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
    [String] $TaskLibraryPath = "",
    [switch] $Quiet = $false
)

# all globally registered library tasks
$global:libraryTasks = @()

# all globally registered tasks
$global:tasks = @()

# all globally registered initializion function for analyse tasks
$global:initializeAnalyseTasks = $null

# all globally registered analyse tasks
$global:analyseTasks = @()

<#
    .SYNOPSIS
    writing a message to console

    .PARAMETER Message
    the message to print to console.
#>
function Write-Message() {
    param([String] $Message)
    Write-Information "Invoke-Tasks :: $Message" -InformationAction Continue
}


<#
    .SYNOPSIS
    register a task for execution (defined in the user script)

    .PARAMETER Name
    name (title) of the task

    .PARAMETER ScriptBlock
    the task script code that should be executed

    .PARAMETER Tags
    optional list of tags that can be defined to filter tasks on demand

    .PARAMETER DependOn
    optional name of a task that must exist to be executed bevor given one

    .PARAMETER Skip
    optional skipping of given task (default: false)
#>
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


<#
    .SYNOPSIS
    Registration of a analyse task

    .DESCRIPTION
    Registration of a analyse task. Those will be executed in given order
    before any other task will be executed.

    .PARAMETER Name
    Unique name of the analyse task

    .PARAMETER ScriptBlock
    The analyse code block

    .PARAMETER Tags
    Defined tags to allow
#>
function Register-AnalyseTask() {
    param (
        [String] $Name,
        [scriptblock] $ScriptBlock,
        [String[]] $Tags = @()
    )

    # same elements cannot be added twice
    if (-not $($global:analyseTasks | Where-Object{ $_.Name -eq $Name})) {
        $global:analyseTasks += [PSCustomObject] @{
            Name = $Name
            ScriptBlock = $ScriptBlock
            Tags = $Tags
        }
    }
}


<#
    .SYNOPSIS
    Providing configuration as hashtable for specific language and related analyse tasks

    .PARAMETER Language
    Initialization for given language for analyze tasks depending on it

    .PARAMETER ScriptBlock
    Initialization Code providing hashtable with the configuration
#>
function Initialize-AnalyseTask() {
    param([scriptblock] $ScriptBlock)

    if ($null -ne $global:initializeAnalyseTasks) {
        throw "Initialization for analyse tasks already registered!"
    }

    $global:initializeAnalyseTasks = $ScriptBlock
}


<#
    .SYNOPSIS
    Function called by the user to register a task with input for a library task

    .DESCRIPTION
    In the script block you can define parameters that will be evaluated by
    the library task.

    .PARAMETER Name
    Unique name of the task

    .PARAMETER LibraryTaskName
    Unique name of the library task

    .PARAMETER ScriptBlock
    The scriptblock to be used to define parameters before the library task is executed.
#>


function Use-Task() {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'ScriptBlock',
    Justification = 'False positive as rule does not know that the newly created scriptblock operates within the same scope')]
    param (
        [String] $Name,
        [String] $LibraryTaskName,
        [scriptblock] $ScriptBlock
    )

    $libraryTask = $global:libraryTasks | Where-Object { $_.Name -eq $LibraryTaskName }
    if ($libraryTask) {
        $dependencies = @($libraryTask)

        # fetching all dependencies
        $dependency = $libraryTask
        while ($dependency.DependsOn) {
            $name = $dependency.DependsOn
            $dependency = $global:libraryTasks | Where-Object { $_.Name -eq $name }
            if (-not $dependency) {
                throw ("Unknown dependency for library task {0}" -f $name)
            }
            $dependencies += $dependency
        }

        $global:tasks += [PSCustomObject]@{
            Name = $Name
            ScriptBlock = {
                param([hashtable] $TaskData)
                & $ScriptBlock $TaskData
                # running all dependencies
                foreach ($dependency in $dependencies) {
                    & $dependency.ScriptBlock $TaskData
                }
            }.GetNewClosure()
            Tags = $libraryTask.Tags
            DependsOn = $null
            Skip = $libraryTask.Skip
            Completed = $false
        }
    } else {
        throw ("Unknown library task {0}" -f $LibraryTaskName)
    }
}


<#
    .SYNOPSIS
    searching output by list of named regexes

    .PARAMETER Output
    The captured output

    .PARAMETER CapturedRegexes
    The list of named regexes
#>
function Search-Output() {
    param (
        [String] $Output,
        [String[]] $CaptureRegexes = @()
    )

    $capturedDetails = @()

    # trying to capture output for defined regexes
    foreach ($captureRegex in $CaptureRegexes) {
        $separatorPos = $captureRegex.IndexOf('=')
        $name = $captureRegex.SubString(0, $separatorPos)
        $regex = $captureRegex.SubString($separatorPos+1)
        $found = $($Output | Select-String -Pattern $regex)
        if ($found) {
            $capturedDetails += [PSCustomObject] @{$name = $found.Matches.Groups[1].Value}
        }
    }

    return $capturedDetails
}


<#
    .SYNOPSIS
    Verify that all tags specified on Invoke-Tasks (command line) do match

    .PARAMETER TaskName
    The description of a parameter

    .PARAMETER Tags
    Those tags specified on Invoke-Tasks (command line)
#>
function Test-AllTag() {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'TaskName',
    Justification = 'False positive as rule does not know that Where-Object operates within the same scope')]
    param(
        [String] $TaskName,
        [String[]] $Tags
    )

    $task = $global:tasks | Where-Object { $_.Name -eq $TaskName }
    $count = 0

    foreach ($tag in $Tags) {
        if ($task.Tags -contains $tag) {
            $count += 1
        }
    }

    return $count -eq $Tags.Count
}


<#
    .SYNOPSIS
    Executing task by given name

    .DESCRIPTION
    Executing task by given name executing the dependencies first

    .PARAMETER Name
    The name of the task

    .PARAMETER TaskData
    The possibility to share data accross all task.

    .Parameter Depth
    internally used parameter

    .NOTES
    The parameter 'privateContext' in $TaskData is reserved by this tool.
#>
function Invoke-Task() {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Name',
    Justification = 'False positive as rule does not know that Where-Object operates within the same scope')]
    param(
        [String] $Name,
        [Hashtable] $TaskData,
        [Int] $Depth = 0
    )

    if ($Depth -gt $global:tasks.Count) {
        throw "Cyclic dependencies are not allowed!"
    }

    $task = $global:tasks | Where-Object { $_.Name -eq $Name }
    if (-not $task) {
        throw "Unknown task (or dependency)"
    }

    if ($task.DependsOn) {
        Invoke-Task -Name $task.DependsOn -TaskData $TaskData -Depth $($Depth+1)
    }

    if ($TaskData.privateContext.checkMode) {
        $task.Completed = $true
        return
    }

    if (-not $Quiet) {
        Write-Message ("Running task '{0}'" -f $task.Name)
    }

    try {
        $performance = Measure-Command {
            & $task.ScriptBlock $TaskData 6>&1 `
                | Tee-Object -Variable output | Out-Default

            # remember outputs
            $TaskData.privateContext.capturedDetails `
                += $(Search-Output $output $TaskData.privateContext.captureRegexes)
        }

        if (-not $Quiet) {
            Write-Message (" ... took {0} seconds!" -f $performance.TotalSeconds)
        }

        $task.Completed = $true
    } catch {
        Write-Error ("{0}" -f $_)
        $TaskData.privateContext.errorFound = $true
    }
}


<#
    .SYNOPSIS
    Running analyse tasks for each configured file

    .PARAMETER TaskData
    Required for configuration as well as results of a analyse task
#>
function Invoke-AllAnalyseTask() {
    param([Hashtable] $TaskData)

    if (($global:analyseTasks.Count -gt 0) -and (-not $TaskData.privateContext.checkMode)) {
        if ($global:initializeAnalyseTasks) {
            foreach ($analyseTask in $global:analyseTasks) {
                if (-not $TaskData.analyseConfiguration) {
                    & $global:initializeAnalyseTasks $TaskData
                }

                $fileNames = $TaskData.analyseConfiguration.Global.AnalyzePathAndFileNames
                foreach ($pathAndFileName in $fileNames) {
                    $content = Get-Content $pathAndFileName -Raw
                    $scriptBlockAst = [System.Management.Automation.Language.Parser]::ParseInput(`
                        $content, [ref]$null, [ref]$null)
                    & $analyseTask.ScriptBlock $TaskData $pathAndFileName $scriptBlockAst
                }
            }
        }
    }
}


<#
    .SYNOPSIS
    Main logic for running all tasks

    .PARAMETER TaskFile
    The specified file with the user specific tasks

    .PARAMETER TaskData
    Sharing this hashtable accross all tasks
#>
function Invoke-AllTask() {
    param(
        [String] $TaskFile,
        [Hashtable] $TaskData
    )

    # ensure that all tasks are registered
    . $TaskFile

    if ($TaskData.privateContext.checkMode) {
        $uniqueTasks = $global:tasks | ForEach-Object { $_.Name} | Get-Unique
        if ($uniqueTasks.Count -ne $tasks.Count) {
            Write-Error ("At least one task has same name as another!")
            $TaskData.privateContext.errorFound = $true
            return
        }
    }

    if ((-not $Quiet) -and (-not $TaskData.privateContext.checkMode)) {
        Write-Message ("Running on OS {0}" -f $PSVersionTable.OS)
        Write-Message ("Running with Powershell in version {0}" -f $PSVersionTable.PSVersion)
        Write-Message ("  ... capture regexes: {0}" `
            -f $($TaskData.privateContext.captureRegexes -Join " , "))

        $global:tasks | Select-Object Name, DependsOn, Skip, Parameters | Format-Table
    }

    Invoke-AllAnalyseTask -TaskData $TaskData

    foreach ($task in $global:tasks) {
        if ($task.Skip -or $task.Completed) {
            continue
        }

        if (-not $(Test-AllTag $task.Name $TaskData.privateContext.tags)) {
            $task.Completed = $true
            continue
        }

        try {
            Invoke-Task -Name $task.Name -TaskData $TaskData
        } catch {
            Write-Error ("{0}" -f $_)
            $TaskData.privateContext.errorFound = $true
        }

        if ($TaskData.privateContext.errorFound) {
            break
        }
    }
}


<#
    .SYNOPSIS
    Loading the library when given

    .PARAMETER TaskLibraryPath
    Path and filename of library file or a folder with multiple files

    .PARAMETER TaskData
    Required for error handling
#>
function Initialize-Library() {
    param([String] $TaskLibraryPath)

    if ($TaskLibraryPath) {
        $allowedFunctions = @("Register-Task", 'Initialize-AnalyseTask', 'Register-AnalyseTask')

        # is a file?
        if (Test-Path -Path $TaskLibraryPath -Type Leaf) {
            Write-Message ("Loading Library File {0}" -f $TaskLibraryPath)
            Test-Script -Path $TaskLibraryPath -AllowedFunctions $allowedFunctions
            . $TaskLibraryPath
            Write-Message("  ... done.")
        } else {
            Write-Message ("Loading Library Files from Path {0}" -f $TaskLibraryPath)
            # is a folder
            $files = Get-ChildItem -Path $TaskLibraryPath -Filter *.ps1
            foreach ($file in $files) {
                Write-Message ("  ... loading Library File {0}" -f $TaskLibraryPath)
                Test-Script -Path $file -AllowedFunctions $allowedFunctions
                . $file
                Write-Message("   ...... done.")
            }
        }

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '$global:libraryTasks',
        Justification = 'False positive as rule does not know that it is used via function Use-Task')]
        $global:libraryTasks = $global:tasks
        $global:tasks = @()
    }
}


<#
    .SYNOPSIS
    Testing for existing of file and for valid code

    .PARAMETER Path
    path and name of script file

    .PARAMETER AllowedFunctions
    names of the allowed functions to be called
#>
function Test-Script() {
    param(
        [String] $Path,
        [String[]] $AllowedFunctions
    )

    if (Test-Path -Path $Path) {
        $fileContent = Get-Content $Path -Raw
        # parsing script
        $scriptAst = [System.Management.Automation.Language.Parser]::ParseInput(
            $fileContent, [ref]$null, [ref]$null)

        foreach ($statement in $scriptAst.EndBlock.Statements) {
            $name = $($statement -Split " ")[0]
            if ($name) {
                if ($name -notin $AllowedFunctions) {
                    throw "line {0}: {1} allowed only" `
                        -f $statement.Extent.StartLineNumber, $($AllowedFunctions -Join " and ")
                }
            }
        }
    } else {
        throw "Script {0} not found!" -f $Path
    }
}


# private Invoke-Task context
$privateContext = @{
    errorFound = $false
    tags = $Tags
    quiet = $Quiet
    captureRegexes = $CaptureRegexes
    capturedDetails = @()
    checkMode = $false
    taskFile = $TaskFile
}

# the reserved attribute required for whole task processing
$TaskData.privateContext = $privateContext
$TaskData.analyseConfiguration = $null
$TaskData.analyseResults = @()
$TaskData.Parameters = @{}

try {
    # Trying to load library (when given)
    Initialize-Library -TaskLibraryPath $TaskLibraryPath -TaskData $TaskData
} catch {
    Write-Error ("{0}" -f $_)
    $TaskData.privateContext.errorFound = $true
}

if (-not $TaskData.privateContext.errorFound) {
    try {
        $allowedFunctions = @(`
            'Register-Task', 'Use-Task', `
            'Initialize-AnalyseTask', 'Register-AnalyseTask')

        Test-Script -Path $TaskFile -AllowedFunctions $allowedFunctions
        # checking the tasks
        $privateContext.checkMode = $true
        Invoke-AllTask -TaskFile $TaskFile -TaskData $TaskData
    } catch {
        Write-Error ("{0}" -f $_)
        $TaskData.privateContext.errorFound = $true
    }
}

if (-not $TaskData.privateContext.errorFound) {
    # reset tasks
    $global:tasks = @()
    $global:initializeAnalyseTasks = $null
    # running the tasks
    $privateContext.checkMode = $false
    Invoke-AllTask -TaskFile $TaskFile -TaskData $TaskData
}

if ($TaskData.analyseResults.Count -gt 0) {
    $TaskData.analyseResults | Format-Table
    $TaskData.privateContext.errorFound = $true
}

# writing captured output to json file
if ($TaskData.privateContext.capturedDetails.Count -gt 0) {
    $TaskData.privateContext.capturedDetails `
        | ConvertTo-Json `
        | Set-Content -Path captured.json
}

if ($TaskData.privateContext.errorFound) {
    Exit 1
}
