$import = Import-csv .\CleanupUsers.csv
$Domain = "amer.EvilCorpcorp.com"
$NewPath = "OU=Delete,OU=Exchange-Team,DC=amer,DC=EvilCorpCORP,DC=COM"

foreach ($DistinguishedName in $Import){

# Set-ADUser -identity $DistinguishedName.DistinguishedName -Description "DELETE" -Server $Domain


# Move-ADObject $DistinguishedName.DistinguishedName -Server $Domain -TargetPath $NewPath
}
