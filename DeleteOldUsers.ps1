$import = Import-csv .\CleanupUsers.csv
$Domain = "amer.epiqcorp.com"
$NewPath = "OU=Delete,OU=Exchange-Team,DC=amer,DC=EPIQCORP,DC=COM"

foreach ($DistinguishedName in $Import){

# Set-ADUser -identity $DistinguishedName.DistinguishedName -Description "DELETE" -Server $Domain


# Move-ADObject $DistinguishedName.DistinguishedName -Server $Domain -TargetPath $NewPath
}