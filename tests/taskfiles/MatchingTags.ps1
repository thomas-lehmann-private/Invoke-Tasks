Register-Task -Name "First Task" -tag First, Simple, Short {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world (first)!'
    $TaskData.Count += 1
}

Register-Task -Name "Second task" -Tag Second, Simple, Short {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world (second)!'
    $TaskData.Count += 1
}
