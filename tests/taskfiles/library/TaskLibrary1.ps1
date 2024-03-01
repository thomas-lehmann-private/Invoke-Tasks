Register-Task -Name "Say Message" -Tag "library-first" {
    param ([hashtable] $TaskData)
    Write-Message $TaskData.Parameters.Message
    $TaskData.Results += $TaskData.Parameters.Message
    $TaskData.Count += 1
}
