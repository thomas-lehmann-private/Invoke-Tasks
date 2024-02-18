Register-Task -Name "First Task" -tag First -DependsOn "Second task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world (first)!'
    $TaskData.Count += 1
}

Register-Task -Name "Second task" -Tag Second {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world (second)!'
    $TaskData.Count += 1
}
