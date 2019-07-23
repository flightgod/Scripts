<#  
.SYNOPSIS
   	Add User to AD Functions

.DESCRIPTION  
    Functions for Adding a user to AD

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

.TODO
    Figure out a way to create username with longer conjunction Names - .Trim(' ') -Replace '\s',''
#>

# Variables from Workday Import
    $NewEmployeeID = $name.'Worker ID'
    $NewDescription = $name.'Worker Type'
    $NewTelephoneNumber = $name.'Work Phone'
    $NewMobileNumber = $name.'Mobile Phone'
    $NewTitle = $name.'Job Title'
    $NewStreetAddress = $name.'Work Address Line 1'
    $NewCity = $name.'Work Address City'
    $NewState = $name.'Work Address State'
    $NewPostalCode = $name.'Work Address Postal Code'
    $NewCountry = $name.'Work Address Country Name'
    $NewManager = $name.'Manager Workday Username'
    $NewDepartment = $name.'Supervisory Organization'
    $NewCompany = $name.Company
# variables We create
    $Script:NewFirstname = $name.'first name'
    $Script:NewLastName = $name.'last name'
    $Script:ShortFirstname = $name.'first name'.Trim(' ') -Replace '\s',''
    $Script:ShortLastName = $name.'last name'.Trim(' ') -Replace '\s',''
    $Script:NewName = $NewFirstname + " " + $NewLastName
    $Script:password = "WelcomeEvilCorp!123"
    $Script:NewUsername = $ShortFirstname + "." + $ShortLastName
    $Script:upn = $NewUsername +"@EvilCorpsystems.com" #Creates UPN
    $Script:DisplayName = $name.'Last Name' +"," + $name.'First Name' #Creates Display Name
# System Variables
    $OU = "OU=LS, OU=Employees, OU=Corp IT,DC=amer,DC=EvilCorpCORP,DC=COM"
    $DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM"


# create an AD Account if not found
Function CreateADAccount {
    New-ADUser -SamAccountName $NewUsername `
        -Name $NewName `
        -DisplayName $DisplayName `
        -UserPrincipalName $upn `
        -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
        -Surname $NewLastName `
        -GivenName $NewFirstname `
        -Title $NewTitle `
        -Department $NewDepartment `
        -OfficePhone $NewCity `
        -City $NewCity `
        -State $NewState `
        -EmployeeID $NewEmployeeID `
        -Manager $NewManager `
        -Description $NewDescription  `
        -MobilePhone $NewMobileNumber `
        -StreetAddress $NewStreetAddress `
        -PostalCode $NewPostalCode `
        -Company $NewCompany `
        -Server $DomainController `
        -Path $OU

}
