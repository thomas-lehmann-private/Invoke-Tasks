# Invoke-Tasks Documentation

Welcome to the documentation of the `Invoke-Tasks` tool.
Please check the user guide on the left side for details
or search for a topic.

Here's   the feature list:

 - Pure Powershell with a single script and no module/assembly dependency
 - Running tasks in defined order
 - Each task can have one dependency that runs first
 - Capturing multiple output by defining named regexes written into a `captured.json`
 - Tasks can be tagged allowing to filter for tasks
 - Tasks can be skipped
 - It's possible to define task libraries (file as well as folder)
 - Scripts are checked to use API functions only.
 - Invoke-Tasks output can be hidden
 - Task data (hashtable) can be shared accross all tasks
 - Performance output for each individual task