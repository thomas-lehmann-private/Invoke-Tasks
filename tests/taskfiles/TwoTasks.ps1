Register-Task -Name "First Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'first task'
    $TaskData.Count += 1
}

Register-Task -Name "Second Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'second task'
    $TaskData.Count += 1
}
