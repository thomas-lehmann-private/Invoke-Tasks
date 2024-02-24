Register-Task -Name "First Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'first task'
    $TaskData.Count += 1
}

Register-Task -Name "Second Task" -DependsOn "Third Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'second task'
    $TaskData.Count += 1
}


Register-Task -Name "Third Task" -DependsOn "Second Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'third task'
    $TaskData.Count += 1
}
