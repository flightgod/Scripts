<#  
.SYNOPSIS
   	Connect Functions

.DESCRIPTION  
    Functions for Connections

.INSTRUCTIONS
    Call this from your other scripots

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 11/29/2017 - First iteration - kbennett 
        
    Rights Required		    : Exchange Permissions to Add/Edit Contacts
				            : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	:

.FUNCTIONALITY

#>


# need to update
# create an AD Account if not found
Function CreateADAccount {
    # this should be to create an account. might need to move off to another Script
    $Script:upn = $username +"@epiqsystems.com" #Creates UPN
    $Script:DisplayName = $name.'Last Name' +"," + $name.'First Name' #Creates Display Name

    New-ADUser -SamAccountName $username `
        -Name $name.name `
        -DisplayName $name.name `
        -UserPrincipalName $upn `
        -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
        -Surname $name.'Last Name' `
        -GivenName $name.'First Name' `
        -Title $name.'Job Title' `
        -Department $name.Department `
        -Office $name.'Location City' `
        -City $name.'Location City' `
        -State $Name.'Location State' `
        -EmployeeID $Name.'Worker ID'
    #Need to add dtiglobal.com to Attribute13 
    Get-ADUser $username | `
        Set-ADObject `
        -add @{extensionAttribute13="dtiglobal.com"} -Credential $UserCredential
    # Here it should create a mailbox
    # CreateRemoteMailbox # We create a new mailbox for them

    # here i should enable skype if it is required
}
