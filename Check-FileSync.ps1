$Folder1Path = 'c:\Scripts1'
$Folder2Path = 'c:\Scripts2'

$Folder1Files = Get-ChildItem -Path $Folder1Path
$Folder2Files = Get-ChildItem -Path $Folder2Path

$FileDiffs = Compare-Object -ReferenceObject $Folder1Files -DifferenceObject $Folder2Files

$FileDiffs | foreach {
    $copyParams =@{
        'Path' = $_.InputObject.Fullname
        }
    if ($_.SideIndicator -eq '<='){
        $copyParams.Destination = $Folder2Path
        }

    else {
        $copyParams.Destination = $Folder1Path
        }
    Copy-Item @copyParams
}

# another One https://herringsfishbait.com/2015/01/23/powershell-synchronizing-a-folder/