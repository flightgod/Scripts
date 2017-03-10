<#
.SYNOPSIS
    Keeps computer from going to sleep
.DESCRIPTION
    Moves the curser 1 px to the right then back to original location every 10 seconds
.EXAMPLE
    .\DontAway.ps1
#>


for ($i = 0; $i -lt $minutes; $i++) {
  Start-Sleep -Seconds 10
  $Pos = [System.Windows.Forms.Cursor]::Position
  [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($Pos.X) + 1) , $Pos.Y)
  #[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($Pos.X , $Pos.Y)
}

param($minutes = 120)

$myshell = New-Object -com "Wscript.Shell"

for ($i = 0; $i -lt $minutes; $i++) {
  Start-Sleep -Seconds 60
  $myshell.sendkeys(" ")
}


