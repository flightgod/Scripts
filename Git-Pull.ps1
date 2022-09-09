#change your github location
$git_dir = "c:\temp"


Get-ChildItem  $git_dir | ForEach-Object {
    if($_.Attributes -eq "Directory")
    {
      Write-Host $_.FullName
      Set-Location $_.FullName
      git fetch
      git pull
    }
  }