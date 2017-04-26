function Show-Menu
{
     param (
           [string]$Title = 'Add/Remove User from DL'
     )
     cls
     Write-Host "================ $Title ================"
     
     Write-Host "1: Press '1' for Add User."
     Write-Host "2: Press '2' for Remove User."
     Write-Host "Q: Press 'Q' to quit."
}

function AddUser
{
    Write-Host "Enter Distribution Name:"
    $DLName = Read-Host (" ")
    Write-Host "Enter Users Email address:"
    $user = Read-Host (" ")
    Add-DistributionGroupMember -Identity $DLName -Member $User 
    Write-Host "User " + $User + " added to Distribution List " + $DLName
    Start-Sleep -s 5
}

function Removeuser
{
    Write-Host "Enter Distribution Name:"
    $DLName = Read-Host (" ")
    Write-Host "Enter Users Email address:"
    $user = Read-Host (" ")
    Remove-DistributionGroupMember -Identity $DLName -Member $User
    Write-Host "User " + $User + " Removed From Distribution List " + $DLName
    Start-Sleep -s 5
}

do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                cls
                AddUser
           } '2' {
                cls
                RemoveUser
           } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')