<#  
.SYNOPSIS
   	Add DTI Contacts

.DESCRIPTION  
    This script Reads the DTI Contact list from Paul, checks that the account doesnt already exist and adds it to Epiq DTI Contacts. If it
    Does exist it adds a User Defined Field with this month in it so we can see when it was last updated. It will also give a list of users
    that are no longer with DTI and flag for removal

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 5/1/2017 - First iteration - kbennett 
        
    Rights Required		: Mailbox Permissions
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 

.FUNCTIONALITY
    Add Contacts, Update User Defined Field, List old Users
#>

# Connects to Exchange
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session

# Variables
$import = Import-csv C:\Temp\List.csv
$UDF = "MAY"
$ContactOU = "OU=Contacts,OU=DTI,DC=amer,DC=EPIQCORP,DC=COM"

# Checks that Contact Exists
Function CheckUser()
{
    foreach ($Name in $import)
    {
        $CheckUser = Get-ADObject -LDAPFilter "objectClass=Contact" -SearchBase $ContactOU | Where {$_.Name -like $Name.DisplayName}
            If ($CheckUser -eq $Null)
            {
                AddUser
            } 
            Else 
            {
                UpdateUser
            }
    }
}

# Updates User if it already exists
Function UpdateUser()
{
    Write-Host $Name.DisplayName "exists - Updating User Defined Field with" $UDF
}

# Adds new Contact if it doesnt already exist
Function AddUser ()
{
    Write-Host $Name.DisplayName "Doesnt Exist !!! - Creating Contact" -foregroundcolor red
    $name
}

# Start Script
CheckUser




# Exits Powershell Session with Exchange
Exit-PSSession $Session