$LocalScripts = Get-ChildItem -Recurse -path C:\Scripts

$remoteScripts = Get-ChildItem -Recurse -path H:\Scripts

Compare-Object -ReferenceObject $LocalScripts -DifferenceObject $remoteScripts