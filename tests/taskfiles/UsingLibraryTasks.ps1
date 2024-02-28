Use-Task -Name "Say Hello World 1" -LibraryTaskName "Say Message" {
    param ([hashtable] $TaskData)
    $TaskData.Parameters.Message = "hello world!"
}

Use-Task -Name "Say Hello World 2" -LibraryTaskName "Say Another Message" {
    param ([hashtable] $TaskData)
    $TaskData.Parameters.Message = "hello world 2!"
}
