<#  
.SYNOPSIS
   	Add DTI Contacts

.DESCRIPTION  
    This script Reads the DTI Contact list from Paul, checks that the account doesn't already exist and adds it to Epiq DTI Contacts. If it
    Does exist it adds a User Defined Field with this month in it so we can see when it was last updated. It will also give a list of users
    that are no longer with DTI and flag for removal

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/1/2017 - First iteration - kbennett 
        
    Rights Required		    : Exchange Permissions to Add/Edit Contacts
				            : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Check and update additional Info from Export

.FUNCTIONALITY
    Add Contacts, Update User Defined Field, List old Users
#>


# Variables
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
$UDF = "MAY"
$ContactOU = "OU=Contacts,OU=DTI,DC=amer,DC=EPIQCORP,DC=COM"
$file = "C:\Temp\List.csv"
$RemoveFile ="c:\Temp\RemoveList.csv"
$DomainController = "P016ADSAMDC01.amer.EPIQCORP.COM"
$UserCredential = Get-Credential

# Connects to Exchange
Function ExchangeConnect 
{
    $Session = New-PSSession `
    -ConfigurationName Microsoft.Exchange `
    -ConnectionUri $ExchangeServer `
    -Authentication Kerberos `
    -Credential $UserCredential
    Import-PSSession $Session
}

# Checks that Contact Exists
Function CheckUser
{
    foreach ($Name in $import)
    {
        $CheckUser = Get-ADObject -LDAPFilter "objectClass=Contact" -SearchBase $ContactOU -Server $DomainController -Properties Name, Mail -Credential $UserCredential | ? {$_.Mail -like $Name.UserPrincipalName}
            If ($CheckUser -eq $Null)
            {
                AddUser ($UserCredential)
            } 
            Else 
            {
                UpdateUser ($UserCredential)
            }
    }
}

# Updates User if it already exists
Function UpdateUser
{
    Write-Host $Name.DisplayName "exists - Updating User Defined Field with" $UDF
    $UpdateUser = Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU | ? {$_.Name -like $Name.DisplayName}
    # clear extensionAttribute3
    Set-ADObject -Identity $UpdateUser -Clear "extensionAttribute3" -Server $DomainController -Credential $UserCredential
    # Set extensionAttribute3
    Set-ADObject -Identity $UpdateUser -Add @{"extensionAttribute3"=$UDF} -Server $DomainController -Credential $UserCredential
}

# ********** Test this Seperatly **************
# Adds new Contact if it doesnt already exist
Function AddUser 
{
    Write-Host $Name.DisplayName "Doesnt Exist !!! - Creating Contact" -foregroundcolor red
    New-ADObject -name $name.DisplayName -type contact -Path $ContactOU -Server $DomainController -Credential $UserCredential -OtherAttributes @{'extensionAttribute3'=$UDF;'physicalDeliveryOfficeName'=$name.Office;'TelephoneNumber'=$name.BusinessPhone;'company'="DTI";'streetAddress'=$name.Address;'mobile'=$name.MobilePhone;'title'=$name.JobTitle;'department'=$name.Department}
    # also Mail-Enable
    Enable-MailContact -Identity $Name.DisplayName -ExternalEmailAddress $name.UserPrincipalName -DomainController $DomainController
    $NewContactsList = @()
    $NewName = $import.DisplayName
    $script:NewContactsList += $Newname
   }

# Gets list of users that were not added this time
Function ListUsersToDelete
{
    $RemoveList = Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Name, Mail | `
    ? {$_.extensionAttribute3 -NotLike $UDF -or $_.name -NotLike "DTI*"} | `
    Select Name, Mail
    Write-Host "The following users were not updated and added to list to remove:"
    #$RemoveList
    $testPath = Test-Path $RemoveFile
        If ($testPath -eq $true)
        {
            Write-Warning "Ops, File is already there, I am removing $RemoveFile"
            Remove-Item $RemoveFile
        }
    $RemoveList > $RemoveFile
    Write-Host "List saved to" $RemoveFile
}

# Checks that the file is there, then imports it
Function ImportFile ()
{
$test = Test-Path $file
    If ($test -eq $true)
    {
        $script:import = Import-csv $file
    }
    Else
    {
        Write-Warning "Something went Wrong: File is missing at $file"
        Break
    }
}

# Start Script
ImportFile ($file)
ExchangeConnect ($UserCredential)
CheckUser ($UserCredential)
ListUsersToDelete





