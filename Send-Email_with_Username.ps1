<#  
.SYNOPSIS
   	Sends Username for users migrating to new Epiq account

.DESCRIPTION  
    Sends Username for users migrating to new Epiq account

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
$UserOU = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM",
$file = "C:\Temp\UsernameList_ks1.csv",
$DomainController = "P054ADSAMDC01.amer.EPIQCORP.COM"
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


# Checks that AD User Exists
Function CheckUser {
    foreach ($Name in $import){
        $CheckUser = Get-ADUser $Name.EpiqUserName -Server $DomainController
            If ($CheckUser -eq $Null){
                Write-Host "Not there" -ForegroundColor Red
                Add-Content c:\temp\DTIMigration_Missing_AD_Account.txt $Name.EpiqUserName
            } 
            Else {
                Write-Host $name.EpiqUsername "is in AD, Seneding Email" -ForegroundColor Green
                $script:NewEmail = $Name.EpiqEmail
                Start-Sleep -s 3
                SendEmail
                $CheckUser = $Null
            }
    }
}

# Body text Function
Function BodyText {
    $Script:Body = "

Above you see your new Epiq Username. In preparation for the Migration of your DTIGlobal Email from InterMedia to Office 365 you will be using this new account name.

Again we want to remind you that your email address will still be either @DTIGlobal-ks.com or @DTIGlobal-ks.eu after the migration.

You will soon receive an additional notice with your default Epiq password and a link so you can change it. Please complete the password change as soon as you can to ensure the account is setup and working properly.

If you have any questions at all please feel free to direct them to O365Questions@epiqsystems.com. Any issues you run into during this migration should be directed toward the Service Desk at ServiceDesk@epiqsystems.com / 913-621-9800
"
}

# Sending Email Function
Function SendEmail{
$script:to = $Name.UserPrincipalName
$script:messageBody = $NewEmail + $Body + "`r`n"
Send-MailMessage `
    -From "o365 Questions <o365Questions@epiqsystems.com>" `
    -To $name.UserPrincipalName `
    -BCC "o365 Answers <o365Answers@epiqsystems.com>" `
    -Subject "New Epiq Systems Username for DTI Email Migration" `
    -Body $messageBody `
    -SmtpServer "mailrelay.amer.epiqcorp.com"

}

ImportFile
BodyText
CheckUser


