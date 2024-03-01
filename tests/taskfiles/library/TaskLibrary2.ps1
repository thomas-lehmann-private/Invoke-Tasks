Register-Task -Name "Say Another Message" -Tag "library-second" {
    param ([hashtable] $TaskData)
    Write-Message "another $($TaskData.Parameters.Message)"
    $TaskData.Results += "another $($TaskData.Parameters.Message)"
    $TaskData.Count += 1
}
