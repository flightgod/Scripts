$Server = 'P054ADSAMDC02.amer.Epiqcorp.com'
$Password = 'Password'
$name = 'User'
    Set-ADAccountPassword $name -Server $server -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
    Write-Host $name ' Set to ' $Password 




$Server = 'P054ADSAMDC02.amer.Epiqcorp.com'
$import = Import-csv .\IrisPasswords.csv
foreach ($User in $import) 
{
    Set-ADAccountPassword $User.name -Server $Server -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $User.Password -Force)
    Write-Host $User.name ' Set to ' $User.Password 
}