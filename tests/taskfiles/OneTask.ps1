Register-Task -Name "One And Only Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world!'
    $TaskData.Count += 1
}
