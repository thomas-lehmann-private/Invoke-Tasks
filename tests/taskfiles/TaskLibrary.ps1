Register-Task -Name "Say Message" -Tag "library-first" -DependsOn "Say Another Message" {
    param ([hashtable] $TaskData)
    Write-Message $TaskData.Parameters.Message
    $TaskData.Results += $TaskData.Parameters.Message
    $TaskData.Count += 1
}

Register-Task -Name "Say Another Message" -Tag "library-second" {
    param ([hashtable] $TaskData)
    Write-Message "another $($TaskData.Parameters.Message)"
    $TaskData.Results += "another $($TaskData.Parameters.Message)"
    $TaskData.Count += 1
}
