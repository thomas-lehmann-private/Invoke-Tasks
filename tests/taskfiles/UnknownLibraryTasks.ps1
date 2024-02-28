Use-Task -Name "Say Hello World" -LibraryTaskName "Unknown" {
    param ([hashtable] $TaskData)
    $TaskData.Parameters.Message = "hello world!"
}
