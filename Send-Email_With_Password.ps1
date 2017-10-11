<#
1 check user exits
2 get Stats
3 if create date and password date are same then then reset password
4 Generate password
5 Reset password
6 record password
7 email user with new password and instructions to reset


#>


# Variables
Param (
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/",
$UDF = "AUG",
$UserOU = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM",
$file = "C:\Temp\UsernameList.csv",
$RemoveFile ="c:\Temp\RemoveList.csv",
$DomainController = "P054ADSAMDC01.amer.EPIQCORP.COM",
$NewPath = "OU=Delete,OU=Exchange-Team,DC=amer,DC=EPIQCORP,DC=COM"
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
                CheckLoginStat
                GeneratePassword
                ResetPassword
                #SendEmail
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

Function AddtoCSV {
    Add-Content c:\temp\DTI-ContactsAddedField.txt $Name.DisplayName
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
    Add-Content c:\temp\DTI-PasswordResetStats.txt $Name.DisplayName " " $genpwd
}

Function BodyText {
    $Script:Body = "

Above you see see your new Epiq Password. As previously communicated in preparation for the Migration of your DTIGlobal Email from InterMedia to Office 365 you will be using a new account name. 

From a DTI location or via VPN please visit the following site to change your password:

https://password.epiqsystems.com/my.policy

Your new password should follow the current Legacy Epiq Password policy and contain at least 15 characters to include at least 1 uppercase, 1 Number and or special character

Please complete this as soon as possible to ensure your account is setup correctly. If you have any issues accessing this site or changing your password please contact the Service Desk at ServiceDesk@epiqsystems.com / 913-621-9800
"
}

Function SendEmail{
    $script:to = $Name.UserPrincipalName
    $script:messageBody = $genpwd + $Body + "`r`n"
Send-MailMessage `
    -From "o365 Questions <o365Questions@epiqsystems.com>" `
    -To $name.UserPrincipalName `
    -Subject "New Epiq Password for DTI Migration" `
    -Body $messageBody `
    -SmtpServer "172.17.190.251"

}

ImportFile
BodyText
CheckUser