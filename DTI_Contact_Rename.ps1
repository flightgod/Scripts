<#
.SYNOPSIS
    For Changing COntact Name
.DESCRIPTION
    This script can be ran anywhere you can access the resources, but each section should be ran individually,
    not as a whole
.AUTHOR
    Kevin Bennett - 1/27/2017
.EXAMPLE
    Run grouped, not as a script
.SYNTAX
    No special Syntax
.ALIASES
    No Alias
.LINK
    NA
.PARAMETER 1
    No Additonal Parameters enabled
.PARAMETER 2
    No Additonal Parameters enabled
.NOTE

.TODO

#>

# Gets my ward Creds so I can run from anywhere (ie Laptop)
$WardCred = Get-Credential

# Run this section first to get a list of all accounts that still have DTI- in their Name

Get-ADObject -Filter {(objectClass -eq "contact") -and (Name -like "DTI-*")} `
-Properties * `
-SearchBase "OU=Contacts,OU=DTI,DC=amer,DC=epiqcorp,dc=com" `
-Server amer.epiqcorp.com | `
Select DistinguishedName, DisplayName, GivenName, SN | `
FT * -Auto -Wrap `
 > .\DTI_Contact_Test.txt

# after running I cleaned up the Excel to take out Resources without proper names, and accounts that were not complete


# Than ran this to make the changes
$import = Import-csv .\DTI_Contact.csv
foreach ($name in $import) {
 Set-ADObject -Identity $name.DistinguishedName `
 -Server amer.epiqcorp.com `
 -Replace @{DisplayName=$name.DisplayName} `
 -Credential $WardCred
 Rename-ADObject -Identity $name.DistinguishedName -NewName $name.DisplayName -Credential $WardCred
 }


   
# used to view the fields I wanted to work with
Get-ADObject -Filter {(objectClass -eq "contact") -and (Name -like "DTI-Wing.Lau*")} -Properties * | Fl *




