<#  
.SYNOPSIS
   	Add DTI Contacts

.DESCRIPTION  
    This script Reads the DTI Contact list from Paul, checks that the account doesn't already exist and adds it to Epiq DTI Contacts. If it
    Does exist it adds a User Defined Field with this month in it so we can see when it was last updated. It will also give a list of users
    that are no longer with DTI and flag for removal

.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.0 - Posted 5/1/2017 - First iteration - kbennett 
                            : 1.1 - Posted 5/2/2017 - Added better error checking - kbennett
        
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
    $UpdateUser = Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties DisplayName, extensionAttribute3, Mail | ? {$_.Mail -like $Name.UserPrincipalName}
    # Checking if Value extensionAttribute3 is already present and correct
    if ($UpdateUser.extensionAttribute3 -ne $UDF)
    { 
        # clear  and Adds extensionAttribute3
        Write-Host $Name.DisplayName "exists - Updating User Defined Field with" $UDF -foregroundcolor Green
        Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Mail | ? {$_.Mail -like $Name.UserPrincipalName} | `
        Set-ADObject -Clear "extensionAttribute3" | `
        Set-ADObject -Add @{"extensionAttribute3"=$UDF}
 }
    Else 
    { 
        Write-Host $Name.DisplayName "Exists - With correct extensionAttribute3 Value" $UDF
    }
}

# Adds new Contact if it doesnt already exist
Function AddUser 
{
    # Error Checking incase the Source file has blanks
    # sets variables to something
    $Title = "Title"
    $Office = "Office"
    $TelephoneNumber = "Phone"
    $streetAddress = "Street"
    $Mobile = "Mobile"
    $department = "Dept"
    $NewName = $Name.DisplayName
    Write-Host $NewName "Doesnt Exist !!! - Creating Contact" -foregroundcolor Yellow
    # adds proper values to variables if they are present
    If ($name.City) {$Office = $name.City}
    #If ($name.BusinessPhone) {$TelephoneNumber = $name.BusinessPhone}
    If ($name.Address) {$streetAddress = $name.Address}
    #If ($name.MobilePhone) {$Mobile = $name.MobilePhone}
    If ($name.JobTitle) {$Title = $name.JobTitle}
    If ($name.department) {$department = $name.department}
    # Adds new object
    New-ADObject -name $NewName -type contact -Path $ContactOU -Server $DomainController -Credential $UserCredential -OtherAttributes @{'extensionAttribute3'=$UDF;'physicalDeliveryOfficeName'=$Office;'company'="DTI";'streetAddress'=$streetAddress;'title'=$Title;'department'=$department} 2>> c:\temp\AddErrors.txt
    # also Mail-Enable
    Enable-MailContact -Identity $Name.DisplayName -ExternalEmailAddress $name.UserPrincipalName -DomainController $DomainController 2>> c:\temp\EnableErrors.txt
    # create me an array of users that were added
    $NewContactsList = @()
    $script:NewContactsList += $Newname
   }

# Gets list of users that were not added this time
Function ListUsersToDelete
{
    $RemoveList = Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Name, Mail, extensionAttribute3 | `
    ? {$_.extensionAttribute3 -NotLike $UDF} | `
    Select Name, Mail
    Write-Host "Number of users that were not updated this time:"$RemoveList.count
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
#ListUsersToDelete





