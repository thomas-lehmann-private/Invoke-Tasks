# Task Registration

## How it works

The `Invoke-Tasks` tool provides two functions:

 - `Register-Task`
 - `Use-Task`

The first on allows you to define a task and the second one basically also
allows you to define task code but here the scope is to reuse a predefined task.

## Registering a task

### Basic usage
At the beginning we have a **name** and a **scriptblock**. The name has to be unique. 
The scriptblock can be any **Powershell** code. It's advisible to keep such tasks short and understandable.
The example is using the script analyzer tool (see https://github.com/PowerShell/PSScriptAnalyzer)
to analyze a file. If any record has been found (independent of its severity) then
an exception will be thrown which would stop the task processing. It's on you to do the same
or - as an example - to continue processing when there are records with severity 'information' only.

```pwsh
Register-Task -Name "Static code analysis" {
    $results = Invoke-ScriptAnalyzer ./Invoke-Tasks.ps1
    $results | Format-Table
    if ($results.Count -gt 0) {
        throw "ScriptAnalyzer has found issues!"
    }
}
```

You're not allowed to write other code than calling `Register-Task` (and `Use-Task`), so the only code
can be in those script blocks. This is by intention.

### Dependency

Each task can have exactly one idea. Reason for this is that `Invoke-Tasks` does execute all tasks
in a defined order and one task at a time only. You can write a task codeblock that does parallel
logic as you like but tasks do not. The next example demonstrates how to use it:

```pwsh
Register-Task -Name "Message1" -DependOn "Message2" {
    Write-Host "hello world 1!"
}

Register-Task -Name "Message2"  {
    Write-Host "hello world 2!"
}
```

No suprise that second message will be printed before the first message.
The `Invoke-Tasks` does check for cyclic dependencies; if you define that those
two task depend on each other the tool will stop with an error before any
task has been executed.

### Tags

You can specify multiple tags at each task with a comma seperated.
When call `Invoke-Tags` with `-Tags` the tasks are filtered.

```pwsh
Register-Task -Name "Message1" -Tags first {
    Write-Host "hello world 1!"
}

Register-Task -Name "Message2" -Tags second  {
    Write-Host "hello world 2!"
}
```

However following important notes:

 - if you specify more than one tag in `-Tags` then a task have to contain all those tags otherwise the task won't be executed
 - if a task does match depending on another task the dependency will be executed even its tags do not match.

### Skip

You can add `-Skip` to a task and then it is not execute. However if an executable task depend on such a task that
dependency will be executed.
