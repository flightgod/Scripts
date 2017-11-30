<#  
.SYNOPSIS
   	Sends Password for users migrating to new Epiq account

.DESCRIPTION  
    Checks if user account is active, Resets password if not, Sends Password for users migrating to new Epiq account

.INSTRUCTIONS
    Run full script 

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 10/1/2017 - First iteration - kbennett 
                            : 1.1 - Posted 11/29/2017 - Updated for -ks user - kbennett
        
    Rights Required	        : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	:

.FUNCTIONALITY

#>


# Variables
Param (
$file = "C:\Temp\UsernameList_ks1.csv"
)


# Checks that the file is there, then imports it
Function ImportFile {
    $test = Test-Path $file
    If ($test -eq $true) {
        $script:import = Import-csv $file
    }
    Else {
        Write-Warning "Something went Wrong:  Import File is missing at $file"
        Break
    }
}


# Checks that User Exists
Function CheckUser {
    foreach ($Name in $import){
        $CheckUser = Get-ADUser $Name.EpiqUserName
            If ($CheckUser -eq $Null){
                Write-Host "Not there" -ForegroundColor Red
                Add-Content c:\temp\DTIMigration_Missing_AD_Account.txt $Name.EpiqUserName
            } 
            Else {
                Write-Host $name.EpiqUsername "is there, Checking Password Set Date" -ForegroundColor Green
                $script:NewEmail = $Name.EpiqEmail
                #CheckLoginStat
                GeneratePassword
                #ResetPassword
                SendEmail
                $CheckUser = $Null
            }
    }
}

Function CheckLoginStat {
$CheckingPass = Get-Aduser $name.EpiqUsername -Properties * | select Name, PasswordLastSet, WhenCreated, LogonCount, extensionAttribute12
        If ($CheckingPass.PasswordLastSet -eq $CheckingPass.WhenCreated){
                    Write-Host "Password Date is same as created" $CheckingPass.PasswordLastSet
        }
         Else {
            Write-host "Seems account is being used" $name.EpiqUsername
        }
}


Function GeneratePassword{
    Add-Type -AssemblyName System.Web
    $PasswordLength = 15
    $NonAlphCh = 2
    $script:genpwd = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,$NonAlphCh)
}

Function ResetPassword {
    $newpwd = ConvertTo-SecureString -String $genpwd -AsPlainText –Force
    Set-ADAccountPassword $Name.EpiqUsername -NewPassword $newpwd –Reset
    $Log = $Name.DisplayName + $genpwd
    Add-Content c:\temp\DTI-PasswordResetStats.txt $Log
}

Function BodyText {
    $Script:Body = "

Above you see see your new Epiq Password. As previously communicated in preparation for the Migration of your DTIGlobal Email from InterMedia to Office 365 you will be using a new account name. 

From a DTI location or via VPN please visit the following site to change your password:

https://password.epiqsystems.com

Your new password should follow the current Legacy Epiq Password policy and contain at least 15 characters to include at least 1 uppercase, 1 Number and or special character

Please complete this as soon as possible to ensure your account is setup correctly. If you have any issues accessing this site or changing your password please contact the Service Desk at ServiceDesk@epiqsystems.com / 913-621-9800

You will soon receive instructions on connecting to the New Web Access or OWA URL. This URL will be used starting Monday 12/4/17 for all email.

Thank you 
"
}

Function SendEmail{
    $script:to = $Name.UserPrincipalName
    $script:messageBody = $genpwd + $Body + "`r`n"
Send-MailMessage `
    -From "o365 Questions <o365Questions@epiqsystems.com>" `
    -To $name.UserPrincipalName `
    -BCC "o365 Answers <o365Answers@epiqsystems.com>" `
    -Subject "New Epiq Password for DTI Migration" `
    -Body $messageBody `
    -SmtpServer "P054EXGSVCS03"

}

ImportFile
BodyText
CheckUser