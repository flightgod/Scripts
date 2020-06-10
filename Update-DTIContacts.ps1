<#  
.SYNOPSIS
   	Add DTI Contacts

.DESCRIPTION  
    This script Reads the company Contact list from admin, checks that the account doesn't already exist and adds it to Contacts. If it
    Does exist it adds a User Defined Field with this month in it so we can see when it was last updated. It will also give a list of users
    that are no longer with company and flag for removal

.INSTRUCTIONS
    Run this after getting the list from Paul, no need to do anything special to the Export except ensure it is named $file variable

.NOTES  
    Current Version     	: 1.4
    
    History			        : 1.0 - Posted 5/1/2017 - First iteration - kbennett 
                            : 1.1 - Posted 5/2/2017 - Added better error checking - kbennett
                            : 1.2 - Posted 5/19/2017 - Added the RemoveUser Functionality - kbennett
                            : 1.3 - Posted 6/19/2017 - Added the Telephone Number lookup and updating - kbennett
                            : 1.4 - Posted 8/8/2017 - Updated some of the script sturcture, & fine tune - kbennett
        
    Rights Required		    : Exchange Permissions to Add/Edit Contacts
				            : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Check and update additional Info from Export

.FUNCTIONALITY
    Add Contacts, Update User Defined Field, List old Users
#>

# Variables
Param (
$ExchangeServer = "http://server.domain.com/PowerShell/",
$UDF = "AUG",
$UserOU = "OU=domain,DC=domain,DC=domain,DC=COM",
$ContactOU = "OU=Contacts,OU=domain,DC=domain,DC=domain,DC=COM",
$file = "C:\Temp\List.csv",
$RemoveFile ="c:\Temp\RemoveList.csv",
$DomainController = "server.amer.domain.COM",
$NewPath = "OU=Delete,OU=Exchange-Team,DC=amer,DC=domain,DC=COM"
)

# Connects to Exchange
Function ExchangeConnect {
    If ($Session.ComputerName -like "server.amer.domain.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $Script:UserCredential = Get-Credential
        $Script:Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

# Checks that Contact Exists
Function CheckUser {
    foreach ($Name in $import){
        $CheckUser = Get-ADObject -LDAPFilter "objectClass=Contact" -SearchBase $ContactOU -Server $DomainController -Properties Name, Mail -Credential $UserCredential | ? {$_.Mail -like $Name.UserPrincipalName}
            If ($CheckUser -eq $Null){
                AddUser ($UserCredential)
            } 
            Else {
                UpdateUser ($UserCredential)
            }
    }
}

# Updates User if it already exists
Function UpdateUser {
    $UpdateUser = Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties DisplayName, extensionAttribute3, Mail, telephoneNumber, Mobile | ? {$_.Mail -like $Name.UserPrincipalName}
    # Checking if Value extensionAttribute3 is already present and correct
    if ($UpdateUser.extensionAttribute3 -ne $UDF){ 
        # clear and Adds extensionAttribute3
        Write-Host $Name.DisplayName "exists - Updating User Defined Field with" $UDF -foregroundcolor Yellow
        Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Mail | ? {$_.Mail -like $Name.UserPrincipalName} | `
            Set-ADObject -replace @{extensionAttribute3=$UDF} -Credential $UserCredential
        Add-Content c:\temp\DTI-ContactsAddedField.txt $Name.DisplayName
    }
    Else{ 
        Write-Host $Name.DisplayName "Exists - With correct extensionAttribute3 Value" $UDF -foregroundcolor Green
    }
    # Checking if Phone Number is blank in AD
    If ($updateUser.telephoneNumber -eq $NULL){
        Write-Host "Telephone number is blank, Updating for -" $Name.DisplayName -foregroundcolor Yellow
        # Error Checking incase the Source file has blanks
        # sets variables to something
        $TelephoneNumber = "NoPhoneNumber"
        # adds proper values to variables if they are present
        If ($name.BusinessPhone) {$TelephoneNumber = $name.BusinessPhone}
        Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Mail | ? {$_.Mail -like $Name.UserPrincipalName} |`
        set-ADObject -add @{telephoneNumber=$TelephoneNumber} -Credential $UserCredential
    }
    #Checking if Mobile Number is Blank in AD
    If ($updateUser.mobile -eq $NULL){
        Write-Host "Mobile number is blank, Updating for -" $Name.DisplayName -foregroundcolor Yellow
        # Error Checking incase the Source file has blanks
        # sets variables to something
        $Mobile = "NoMobileNumber"
        # adds proper values to variables if they are present
        If ($name.MobilePhone) {$Mobile = $name.MobilePhone}
        Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Mail | ? {$_.Mail -like $Name.UserPrincipalName} |`
        set-ADObject -add @{mobile=$Mobile} -Credential $UserCredential
        }
}

# Adds new Contact if it doesnt already exist
Function AddUser {
    # Error Checking incase the Source file has blanks
    # sets variables to something
    $Title = "NoTitle"
    $Office = "NoOffice"
    $TelephoneNumber = "NOPhoneNumber"
    $streetAddress = "NoStreet"
    $Mobile = "NoMobileNumber"
    $department = "NoDept"
    $firstName = "First"
    $lastName = "Last"
    $NewName = $Name.DisplayName
    $string = $NewName
    $firstName = $string.split(" ")[0]
    $lastName = $string.split(" ")[1]
    $NewDisplayName = "$lastname, $firstname"
    
    Write-Host $NewName "Doesnt Exist !!! - Creating Contact" -foregroundcolor Yellow
    # adds proper values to variables if they are present
    If ($name.City) {$Office = $name.City}
    If ($name.BusinessPhone) {$TelephoneNumber = $name.BusinessPhone}
    If ($name.Address) {$streetAddress = $name.Address}
    If ($name.MobilePhone) {$Mobile = $name.MobilePhone}
    If ($name.JobTitle) {$Title = $name.JobTitle}
    If ($name.department) {$department = $name.department}
    # Adds new object
    New-ADObject `
        -name $NewName `
        -displayName $NewDisplayName `
        -type contact `
        -Path $ContactOU `
        -Server $DomainController `
        -Credential $UserCredential `
        -OtherAttributes @{
            'extensionAttribute3'=$UDF;`
            'physicalDeliveryOfficeName'=$Office;`
            'company'="DTI";`
            'streetAddress'=$streetAddress;`
            'title'=$Title;`
            'department'=$department;`
            'givenName' = $firstname;`
            'sn' = $lastName;`
            'TelephoneNumber' = $TelephoneNumber;`
            'Mobile' = $Mobile} 2>> c:\temp\AddErrors.txt
    # also Mail-Enable
    Enable-MailContact -Identity $Name.DisplayName -ExternalEmailAddress $name.UserPrincipalName -DomainController $DomainController 2>> c:\temp\EnableErrors.txt
   }

# Gets list of users that were not added this time
Function ListUsersToDelete {
    $RemoveList = Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Name, Mail, extensionAttribute3 | `
        ? {$_.extensionAttribute3 -NotLike $UDF} | `
        Select Name, Mail
    Write-Host "Number of users that were not updated this time:"$RemoveList.count -ForegroundColor Red
    $testPath = Test-Path $RemoveFile
    If ($testPath -eq $true) {
        Write-Warning "Ops, File is already there, I am removing $RemoveFile"
        Remove-Item $RemoveFile
    }
    #$RemoveList > $RemoveFile
    Write-Host "List saved to" $RemoveFile
    Add-Content $RemoveFile $RemoveList

    # Move users to Delete Folder
    Write-Host "Moving users in that dont have $UDF in thier value to $NewPath" -ForegroundColor Magenta
    Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Name, Mail, extensionAttribute3 | `
        ? {$_.extensionAttribute3 -NotLike $UDF} |`
        Move-ADObject -Server $DomainController -TargetPath $NewPath -Credential $UserCredential
    
}

# Checks that the file is there, then imports it
Function ImportFile {
    $test = Test-Path $file
    If ($test -eq $true) {
        $script:import = Import-csv $file
    }
    Else {
        Write-Warning "Something went Wrong: DTI Import File is missing at $file"
        Break
    }
}

# Get the DisplayName of the user and split to first and last
Function GetDisplayName {
                $string = $Item.DisplayName
                $firstName = $string.split(" ")[0]
                $lastName = $string.split(" ")[1]
                $NewDisplayName = "$lastname, $firstname"

}

# Needs more work
Function RemovePhoneText {
$UpdateUser = Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties DisplayName, extensionAttribute3, Mail, telephoneNumber, Mobile
    
    # Checking if Phone Number is blank in AD
    If ($updateUser.telephoneNumber -eq "NoPhoneNumber"){
        Write-Host "Telephone number is blank, Updating for -" $Name.DisplayName -foregroundcolor Yellow
        Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Mail | `
        ? {$_.Mail -like $Name.UserPrincipalName} |`
        set-ADObject -Clear telephoneNumber -Credential $UserCredential
    }
    #Checking if Mobile Number is Blank in AD
    If ($updateUser.mobile -eq "NoMobileNumber"){
        Write-Host "Mobile number is blank, Updating for -" $Name.DisplayName -foregroundcolor Yellow
        Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Mail | `
        ? {$_.Mail -like $Name.UserPrincipalName} |`
        set-ADObject -Clear mobile -Credential $UserCredential
        }
    }

# need to add to script
Function UpdateContactsNotListed {
 # These users need to have thier Month Checked and then updated if new
 # Users:
    Write-Host "Now updating the users that were not on the list"
    $updateArray = "user@domain-ks.com","user1@domain-ks.com","user2@domain-ks.com"
    foreach ($test in $updateArray){
        $SkippedUser = Get-ADObject `
            -LDAPFilter "objectClass=Contact" `
            -SearchBase $ContactOU `
            -Server $DomainController `
            -Properties Name, Mail,extensionAttribute4 `
            -Credential $UserCredential | `
            ? {$_.Mail -like $test}
    
            if ($SkippedUser.extensionAttribute4 -ne $UDF){ 
                # clear and Adds extensionAttribute3
                Write-Host $SkippedUser.Name "exists - Updating User Defined Field with" $UDF -foregroundcolor Yellow
                Get-ADObject -LDAPFilter "objectClass=Contact" -Server $DomainController -SearchBase $ContactOU -Properties Mail | `
                ? {$_.Mail -eq $test} | `
                Set-ADObject -replace @{extensionAttribute4=$UDF} -Credential $UserCredential -Server $DomainController
            } Else { 
                Write-Host $SkippedUser.Name "Exists - With correct extensionAttribute3 Value" $UDF -foregroundcolor Green
            }
    }  
 }
 

# Start Main Script
ImportFile ($file)
ExchangeConnect ($UserCredential)
CheckUser ($UserCredential)
UpdateContactsNotListed
ListUsersToDelete
