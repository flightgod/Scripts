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
$file = "C:\Temp\GCGUsers.csv",
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
        $CheckUser = Get-ADUser $Name.SamAccountName -Server $DomainController
            If ($CheckUser -eq $Null){
                Write-Host "Not there" -ForegroundColor Red
                Add-Content c:\temp\GCGMigration_Missing_AD_Account.txt $Name.SamAccountName
            } 
            Else {
                Write-Host $name.SamAccountName "is in AD, Seneding Email" -ForegroundColor Green
                $script:NewEmail = $Name.GCGEmail
                $NewEmail
                $Script:NewPW = $Name.Password
                $Script:EpiqUN = $name.UserPrincipalName
                Start-Sleep -s 1
                #SendEmail
                $CheckUser = $Null
            }
    }
}

# Body text Function
Function BodyText {
    $Script:Body = "

Above you see your new Epiq Username and Password. In preparation for the Migration of your GCG Email to Office 365 you will be using this new account name.

To manage your password, Reset, or request if forgotten please go to https://epiqmanage.epiqglobal.com and click on the User Registration link on the right. Follow the instructions on registering to identify yourself if you forgot your password. After registration you will be able to reset your password, or request a new one if you have forgotten the password. You can also find instructions for these steps at: https://epiqsystems3.sharepoint.com/help

These credentials are used for all Epiq o365 applications (Email, Skype, SharePoint, OneDrive .. etc)

Again we want to remind you that your email address will still be either @choosegcg.com after the migration.

If you have any questions at all please feel free to direct them to O365Questions@epiqsystems.com. 

Any issues you run into during this migration should be directed toward the GCG Service Desk as a Ticket at http://gcghelpdesk.gcdomain.local"
}

# Sending Email Function
Function SendEmail{
$script:to = $NewEmail
$script:messageBody = "Username: " + $EpiqUN + "`r`n" +  "Password: " + $NewPW + $Body + "`r`n"
Send-MailMessage `
    -From "Epiq Corporate IT <corporateit@epiqglobal.com>" `
    -To $NewEmail `
    -BCC "o365 Answers <o365Answers@epiqsystems.com>" `
    -Subject "Epiq o365 New Credentials" `
    -Body $messageBody `
    -SmtpServer "mailrelay.amer.epiqcorp.com"

}

ImportFile
BodyText
CheckUser


