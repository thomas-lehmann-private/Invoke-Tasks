Register-Task -Name "First Task" -DependsOn "Second Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'first task'
    $TaskData.Count += 1
}
