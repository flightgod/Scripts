<#
.SYNOPSIS
    Part 1 For adding users to o365
.DESCRIPTION
    This script should be ran to add new AD User with a Remote Mailbox for o365
    
.AUTHOR
    Kevin Bennett - 6/01/2016
.EXAMPLE
    .\Create-UserWith365_Mailbox_Part1.ps1
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
    10/01/2016 - Added the AD Azure Sync
    10/12/2016 - Adjusted for post IRIS Migration, Removed forward to IRISDS.COM & Permissions
    05/09/2017 - Adding Licenses to Disable for new o365 Products
    08/30/2017 - Working to fully integrate for DTI import - kbennett

.TODO
    see if I can find the errors for adding mailboxes

    run through list and get location, check if not in proper OU
    run through list and check settings, are they hidden, do they have remote mailbox
    run thorugh duplicate and compare
    If account exists but mailbox is onprem then migrate
    if account exists but no mailbox enable

    run part 2
    Remove new from Office
    undo hidden at end
    Set custom attribute for Company to remove domain name from it
#>

# Variables
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$file = "c:\temp\ADUsers_UK.csv"
$password = "Welcome1234Epiq!"
$OU = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
$DomainList = "epiqcorp.com","amer.epiqcorp.com","apac.epiqcorp.com","euro.epiqcorp.com"

# connect to Exchange
Function ExchangeConnect {
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
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

# Import List
Function importUsers {
    $test = Test-Path $file
    If ($test -eq $true) {
        $script:import = Import-csv $file
    }
    Else {
        Write-Warning "Something went Wrong: Import File is missing at $file"
        Break
    }
    
}

# Gets a single user to create an o365 Mailbox
Function GetIndivUser {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.com"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    checkUser
}

# Error checking to see if user exists
Function checkUser {
 $Script:Continue = ""
     foreach ($Script:name in $import){
        $user = $name.username
        forEach ($domain in $DomainList){
            If (Get-ADUser -Server $domain -Filter {samAccountName -eq $user}) {
                write-Host "User $user Exist in $domain" -ForegroundColor Red
                $Continue = "NO"
                # Get-ADUser $Name -Server $domain
                } Else {
                    Write-Host "User $user doesnt exist in $domain" -ForegroundColor Green
                }
        }
    If ($continue -eq ""){
        CreateADAccount
    } Else {
        Write-Host "Account $user not created because there appears to be a conflict" -ForegroundColor Red
        Add-Content c:\temp\DTI_AddIssues.txt $user
        $continue = ""
    }
    }
}

# create an AD Account if not found
Function CreateADAccount {
        $Script:upn = $name.Username +"@epiqsystems.com"
        $Script:DisplayName = $name.LastName +", " + $name.FirstName
        New-ADUser -SamAccountName $name.Username `
            -Name $DisplayName `
            -DisplayName $DisplayName `
            -UserPrincipalName $upn `
            -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
            -Surname $name.Lastname `
            -GivenName $name.FirstName `
            -StreetAddress $name.Address `
            -City $name.City `
            -PostalCode $name.Zip `
            -State $name.State `
            -Department $name.Department `
            -MobilePhone $name.MobilePhone `
            -OfficePhone $name.BusinessPhone `
            -Title $name.JobTitle `
            -Server $DomainController `
            -Path $OU -Enabled $True `
            -Credential $UserCredential `
            -Company $name.EmailDomain `
            -office "new"
        CreateRemoteMailbox
       
}

Function disableRemoteMailbox {
    foreach ($Script:name in $import){
        Disable-RemoteMailbox $name.Username -Confirm:$false
    }
}


# Enables the remote Mailbox
Function CreateRemoteMailbox {
    "Mailbox will be created as :", $upn
    $Script:email = $name.Username +"@epiqsystems3.mail.onmicrosoft.com"
    # Enables the o365 Mailbox and Turns on Archive for the user
    Enable-RemoteMailbox $name.Username -RemoteRoutingAddress $email -DomainController $DomainController
    # Enable-RemoteMailbox $upn -Archive
    hideGAL
}

# Hide from AddressBook
Function hideGAL {

    Set-RemoteMailbox $name.Username -HiddenFromAddressListsEnabled $true -DomainController $DomainController

}

# runs the Sync
Function ADSync {
    # Kicks off the AD Azure Sync on the Sync server
    $session = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $UserCredential
    Invoke-Command -Session $session -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
    Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $session
    
    "Please wait while the Azure Sync is completed ......... Estimate 15 Seconds"

    Start-Sleep -s 60
}

#Script Main body
 ExchangeConnect
#GetIndivUser
 importUsers
 disableRemoteMailbox
 ADSync
