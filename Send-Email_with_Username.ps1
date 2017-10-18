# Variables
Param (
$UserOU = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM",
$file = "C:\Temp\UsernameList2.csv",
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
                Write-Host $name.EpiqUsername "is in AD, Sending Email" -ForegroundColor Green
                $script:NewEmail = $Name.EpiqEmail
                Start-Sleep -s 3
                SendEmail
            }
    }
}

# Body text Function
Function BodyText {
    $Script:Body = "

Above you see your new Epiq Username. In preparation for the Migration of your DTIGlobal Email from InterMedia to Office 365 you will be using this new account name.

Again we want to remind you that your email address will still be either @DTIGlobal.com or @DTIGlobal.eu after the migration.

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
    -Subject "New Epiq Systems Username for DTI Email Migration" `
    -Body $messageBody `
    -SmtpServer "mailrelay.amer.epiqcorp.com"

}

ImportFile
BodyText
CheckUser


