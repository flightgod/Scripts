<#
Epiq-ALL update Script

1. Get list of users from Worday  - Done
2. Does the Employee ID exist in AD? - Done
    a. Yes go on - Done
    b. No Log
3. Exists in AD then is the account enabled? - Done
    a. Yes go on - Done
    b. No Log
4. does the Account have a mailbox / License?
    a. Yes go on
    b. No Log
5. Add to Epiq-ALL DL



File is c:\temp\Active_Employees_-_Non_LDE.csv


#>

$filePath = "c:\temp\Active_Employees_-_Non_LDE.csv"
$DomainServer = "P054ADSAMDC01.amer.EPIQCORP.COM"

Import-Module ActiveDirectory

# Imports CSV File of Users - (1)
Function importCSV {
    $Script:Import = Import-Csv $FilePath
}

# Checking if User exists in AD by EmployeeID Given - (2)
Function CheckExist {
    ForEach ($Script:user in $Import) {
        $Script:UserSearch = $Null
        $Script:EID = $user."Employee ID"

        Write-Host "Searching for Employee ID: "$EID 
        $UserSearch = Get-ADUser -Filter * -ErrorAction Stop -Properties EmployeeID | ? {$_.EmployeeID -eq $EID}
        If ($UserSearch -eq $Null) {
            Write-Host "Not Found Logging" -ForegroundColor Red
            #Logging
        } Else {
            Write-host "Found, moving along" -ForegroundColor Green
            CheckEnabled
        }
    }

}

# This is checking if the account is enabled - (3)
Function CheckEnabled {
    $Script:UserEnabled = $UserSearch.Enabled
    $Script:UPN = $UserSearch.UserPrincipalName
    $Script:SAM = $UserSearch.SamAccountName

    If ($UserEnabled -eq $True) {
        Write-Host "User is enabled" -ForegroundColor Green
    } Else {
        Write-Host "User is Disabled - Log this" -ForegroundColor Red
        LoggingDisabled
    }
}

# This needs to check if the user has a mailbox or has a license
Function CheckLicense {
    

}

# function for logging who is creating Accounts, going to be used to also send emails to new users
Function LoggingDisabled {
    $script:info = @()
    $script:NewLogPath = 'c:\temp\AD_Disabled_Errors.csv'

    $info += New-Object psobject `
                -Property @{`
                    EmployeeID=$EID; `
                    UPN=$upn; `
                    SAM=$SAM}

    $info | Export-Csv $NewLogPath -Append -NoTypeInformation
}

Function Logging {
    $script:info2 = @()
    $script:NewLogPath2 = 'c:\temp\AD_Not_Found_Errors.csv'

    $info2 += New-Object psobject `
                -Property @{`
                    EmployeeID=$EID}

    $info2 | Export-Csv $NewLogPath2 -Append -NoTypeInformation
}

CheckExist