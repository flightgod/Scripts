<#
.SYNOPSIS
    for creating AD Accounts and Enable-RemoteMailbox
.DESCRIPTION
    using this script to create all the new MS users that currently do not have emails address but use
    Personal Email for communicating with work
    
.AUTHOR
    Kevin Bennett - 12/11/2016
.EXAMPLE
    .
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
    11/21/2017 - working to implement for Workday
    12/11/2017 - Finishing up and ready for testing

.TODO
    Figure out a way to create username with longer conjunction Names - .Trim(' ') -Replace '\s',''
#>

# Variables
$DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM"
$file = "c:\temp\LSList.csv" # First File of all users
$file2 = "c:\temp\LSUsersCreated.csv" # Second file for all that were Created
$password = "Welcome1234EvilCorp!"
$OU = "OU=MS,OU=Employees,OU=Corp IT,DC=amer,DC=EvilCorpCORP,DC=COM"
$DomainList = "EvilCorpcorp.com","amer.EvilCorpcorp.com","apac.EvilCorpcorp.com","euro.EvilCorpcorp.com"
$ExchangeOnlineSkuE2 = "EvilCorpsystems3:EXCHANGEENTERPRISE" # E2 License - outlook/owa
$ExchangeOnlineSkuE1 = "EvilCorpsystems3:EXCHANGESTANDARD" # E1 License - OWA Only


# Calls my connect function with all the current connection strings in it
.".\Function-Connect.ps1"

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


# Error checking to see if user exists
Function checkUser {
 $Script:Continue = ""
     foreach ($Script:name in $import){
        $CleanFirst = $name.'First Name'.Trim(' ') -Replace '\s',''
        $CleanLast = $name.'Last Name'.Trim(' ') -Replace '\s',''
        $username = $CleanFirst + "." + $CleanLast
        forEach ($domain in $DomainList){
            If (Get-ADUser -Server $domain -Filter {samAccountName -eq $username}) {
                write-Host "User $username Exist in $domain" -ForegroundColor Red
                $Continue = "NO"
                } Else {
                    Write-Host "User $username doesn't exist in $domain" -ForegroundColor Green
                }
        }
        If ($continue -eq ""){
            CreateADAccount
        } Else {
            $errorUser = $username + "," + $name.'Work Email'
            Write-Host "Account $username not created because there appears to be a conflict" -ForegroundColor Red
            Add-Content c:\temp\MSUser_AddIssues.csv $errorUser #creates file in same location as script being ran
            $continue = ""
            $errorUser = ""
        }
    }
}

# create an AD Account if not found
Function CreateADAccount {
        $Script:upn = $username +"@EvilCorpsystems.com" #Creates UPN
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
            -EmployeeID $Name.'Employee ID'
        #Need to add dtiglobal.com to Attribute13 
        Get-ADUser $username | `
            Set-ADObject `
            -add @{extensionAttribute13="dtiglobal.com"} -Credential $UserCredential
        CreateRemoteMailbox
}

# Enables the remote Mailbox
Function CreateRemoteMailbox {
    "Mailbox will be created as :", $upn
    $Script:email = $username +"@EvilCorpsystems3.mail.onmicrosoft.com"
    # Enables the o365 Mailbox
    Enable-RemoteMailbox $username -RemoteRoutingAddress $email -DomainController $DomainController
    ### Here I put a log to add the user created and Info so I can use it below to enable License
    $Log = $upn + "," + $username + "@dtiglobal.com"
    Add-Content c:\temp\LSUsersCreated.csv $Log
}


# runs the Sync
Function ADSync {
    # Kicks off the AD Azure Sync on the Sync server
    $session = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $UserCredential
    Invoke-Command -Session $session -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
    Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $session
    
    "Please wait while the Azure Sync is completed ......... Estimate 60 Seconds"

    Start-Sleep -s 60
}

# Import List
Function importUserso365 {
    $o365 = Test-Path $file2
    If ($o365 -eq $true) {
        $script:o365Users = Import-csv $file2
    }
    Else {
        Write-Warning "Something went Wrong: Import File is missing at $file2"
        Break
    }
}

# Assigns the License
Function AssignLic {
    foreach ($Script:User in $o365Users) {
        $script:upn = $User.username
        Write-Host "Setting Location and License to E1" + $upn
        # Setting User Location to US
        Set-MsolUser -UserPrincipalName $upn -UsageLocation US
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $ExchangeOnlineSkuE1    
        Get-MsolUser -UserPrincipalName $upn | select UserPrincipalName, UsageLocation, isLicensed, Licenses
        SetDefaults
    }
}

# Sets all the defaults
Function setDefaults {
        Write-host "Setting Defaults: " + $upn
        # Sets IssueWarningQuota to 45GB and set RetainDeletedItemsFor 30 days
        Set-Mailbox $upn -IssueWarningQuota 45GB -RetainDeletedItemsFor 30.00:00:00
        Write-host "Turning off Clutter" + $upn
        # Turn off Clutter
        Get-Mailbox ?identity $upn | Set-Clutter -enable $false
    
}

########################################################################################################

#Script Main body
 Connect-Exchange # calls from the .function-connect.ps1
 importUsers $file #Imports first file
 checkUser #checks to see if user account already exists
 ADSync #once done it does an AD Sync to get it all to o365
 Session-Disconnect # Cleans up our PSSessions from Function-connect

 Write-Host "Now we need to run the second part to assign license to the above users and set defaults" -ForegroundColor Green
 
 Connect-o365 # calls from the .function-connect.ps1
 importUserso365 #Imports second file of added users
 AssignLic #Assigns licenses and then Defaults for each user
 Session-Disconnect # Cleans up our PSSessions from Function-connect

 ########################################################################################################

 Function GeneratePassword{
    Add-Type -AssemblyName System.Web
    $PasswordLength = 15
    $NonAlphCh = 2
    $script:genpwd = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,$NonAlphCh)
}

Function ResetPassword {
    $newpwd = ConvertTo-SecureString -String $genpwd -AsPlainText ?Force
    Set-ADAccountPassword $Name.EvilCorpUsername -NewPassword $newpwd ?Reset
    $Log = $Name.DisplayName + $genpwd
    Add-Content c:\temp\DTI-PasswordResetStats.txt $Log
}


Function BodyText {
    $Script:Body = "

Above you see see your new EvilCorp Password. As previously communicated in preparation for the Migration of your DTIGlobal Email from InterMedia to Office 365 you will be using a new account name. 

From a DTI location or via VPN please visit the following site to change your password:

https://password.EvilCorpsystems.com

Your new password should follow the current Legacy EvilCorp Password policy and contain at least 15 characters to include at least 1 uppercase, 1 Number and or special character

Please complete this as soon as possible to ensure your account is setup correctly. If you have any issues accessing this site or changing your password please contact the Service Desk at ServiceDesk@EvilCorpsystems.com / 913-621-9800

You will soon receive instructions on connecting to the New Web Access or OWA URL. This URL will be used starting Monday 12/4/17 for all email.

Thank you 
"
}

Function SendEmail{
    $script:to = $Name.UserPrincipalName
    $script:messageBody = $genpwd + $Body + "`r`n"
Send-MailMessage `
    -From "o365 Questions <o365Questions@EvilCorpsystems.com>" `
    -To $name.UserPrincipalName `
    -BCC "o365 Answers <o365Answers@EvilCorpsystems.com>" `
    -Subject "New EvilCorp Password for DTI Migration" `
    -Body $messageBody `
    -SmtpServer "P054EXGSVCS03"

}
