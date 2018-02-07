<#
.SYNOPSIS
    Updates Data from Source of Truth
.DESCRIPTION
    This will read a file from Workday to update AD with source of truth info. And should also create new users if they dont exist
.AUTHOR
    Kevin Bennett - 12/22/2017
.EXAMPLE
    .
.SYNTAX
    No special Syntax
.ALIASES
    No Alias
.LINK
    I should put a link to our wiki here
.PARAMETER 1
    No Additonal Parameters enabled
.PARAMETER 2
    No Additonal Parameters enabled
.NOTE
    12/22/2017 - working to implement for Workday
.TODO
    Figure out a way to create username with longer conjunction Names - .Trim(' ') -Replace '\s',''
    # Need to put in an error Check if Workday Account Username is NULL - If it detects it should make a new user
    # Should Just blank out Manager if NULL
    # Remove after testing Tags
    # Change File Variable
.FLOW
    Loads Reads Variables
    Loads Function
    Imports User File
    CheckUsers - Checks if user exists
        If it doesnt goto create
        If it does - move on
    Update Info
        If it is first run then do all
        if it is not then do some Compare
    Update workday file so they get EMail address
    Delete file
    - That is all -
#>

# Date Variables
 $todayDate = get-date -Format yyyyMMdd
 $todayYear = get-Date -Format yyyy
 $todayMonth = get-Date -Format MM
 $todayDay = get-Date -Format dd
 $todayFileDate = $todayYear + "-" + $todayMonth + "-" + $todayDay
# Location Variables
 $DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
 $Path = "\\ks-isnl-prod.sn2.amer.epiqcorp.com\eca\prod\mft\Internal-Use-Only\web-users-home\svc_WorkdayGOA"
 $TempPath = "c:\Temp" #Remove When go Live
 $file = "\INT0016_AD_Employee_" + $todayFileDate + "_2.csv"
 $FullPath = $TempPath + $file #Change $TempPath with $Path when go live
# Arrays I Created
 $DomainList = "epiqcorp.com","amer.epiqcorp.com","apac.epiqcorp.com","euro.epiqcorp.com"
 $ADProperties = "EmployeeID","SamAccountName","Name","Givenname","SurName","Descriptions","telephoneNumber","MobileNumber","Title","StreetAddress","City","State","PostalCode","Country","Manager","Department","Company","Mail"


# Calling other files and Function
 .".\Function-Connect.ps1"                   # Calls my connect function with all the current connection strings in it
# .".\Function-CreateADUser.ps1"              # Calls Function with the Add User AD 
# .".\Function-CreateMailbox.ps1"             # Calls Function to create Remote Mailbox
# .".\Function-ADSync.ps1"                    # Calls funtion to sync AD to o365
# .".\Function-EnableLync.ps1"
# .".\Function-EnableSkype.ps1"


# Import List of users from Workday
Function importUsers {
    $test = Test-Path $FullPath
    If ($test -eq $true) {
        $script:import = Import-csv $FullPath
    }
    Else {
        Write-Warning "Something went Wrong: Import File is missing at $FullPath"
        Break
    }
}


# Error checking to see if user exists
Function checkUser {
    foreach ($Script:name in $import){
       $Script:Continue = ""
       $script:username = $name.'Workday Account Username'
       if (!$username) { # is !NULL Loop here
        write-Host "Username is null" $name.'Worker ID'
        Add-Content -path "c:\temp\Workday_NO_Username.csv" $name.'Worker ID'
        # Then probably kick of the add new user Function
       } Else {
       forEach ($domain in $DomainList){
           If (Get-ADUser -Server $domain -Filter {samAccountName -eq $username}) {
               write-Host "User $username Exist in $domain" -ForegroundColor Red
               $Continue = "Yes"
           } Else {
                Write-Host "User $username doesn't exist in $domain" -ForegroundColor Green
           }
       }
           If ($continue -eq "Yes"){
               # Need to run the Update Function here to update thier Info
               UpdateInfo
               UpdateWorkday
               $Continue = ""
           } Else {
                #If Termination Date is NULL then this account should be created
                If ($name.'Term Date' -eq ""){
                    write-host "Account Doesnt Exist - Here we should Create that account then send info to workday" -ForegroundColor Yellow
                    $MissingUser = $username + "," + $name.'Worker ID'
                    Add-Content -path ".\Workday_NO_AD_Account.csv" $MissingUser
                    #CreateADAccount
                    #CreateMailbox
                    #Updateworkday
                    $Continue = ""
                } Else {
                    # Term Date is not NULL so skiping as the AD is correct that this user is not needed
                    write-host $Username ": Account has a term date" $name.'Term Date' "So dont create account" -ForegroundColor Red
                    $MissingUser = $username + "," + $name.'Worker ID'
                    Add-Content -path ".\Workday_NO_AD_Account_Term.csv" $MissingUser
                    $Continue = ""
                }
           }
           }
    }
}

# for successful verification of user existing to update workday on thier true Email Address
Function UpdateWorkday {
    Write-host "Account Exists already, Sending Email Address to Workday" -ForegroundColor Green
    $Userinfo = Get-ADUser $username -Properties * -Server $DomainController | Select EmployeeID, SamAccountName, Mail
    $FileName = "c:\temp\AD_to_Workday_export_" + $todayDate + ".csv"
    $userInfo | Export-Csv -path $FileName -NoTypeInformation -Append
}

# Updates User info in AD
Function UpdateInfo {
    Write-host "Account Exists, Updating Info in AD Object" -ForegroundColor Green
    CheckingForNulls
    
    Set-ADUser -Identity $username `
        -EmployeeID $NewEmployeeID `
        -Credential $UserCredential `
        -Server $DomainController `
        -Description $NewDescription  `
        -OfficePhone $NewTelephoneNumber `
        -Title $NewTitle `
        -StreetAddress $NewStreetAddress `
        -City $NewCity `
        -State $NewState `
        -PostalCode $NewPostalCode `
        -Manager $NewManager `
        -Department $NewDepartment `
        -Company $NewCompany `
        -Country $NewCountry `
        -MobilePhone $NewMobileNumber
        
}

# Renames file
Function RenameFile {
    $Script:RenameFile = $TempPath + "\processed_" + $todayFileDate + ".csv"
    Rename-Item $FullPath $RenameFile
}

# Deletes file when Finished
Function DeleteFile {
    # This is where we will delete the file after reading and updating
    Remove-Item $RenameFile -Recurse
}

<# -------------------------------- SCRIPT MAIN BODY ------------------------------------------ #>
 
 # Connect-Exchange              # Calls from the .function-connect.ps1
  importUsers $file             # Imports first file
  checkUser                     # Checks to see if user account already exists
 # RenameFile                    # Renames File #Remove When go Live
 # DeleteFile                    # Deletes File #Remove When go Live





 <# ------------------------------------- TESTING ---------------------------------------------- #>
 Function CheckingForNulls {
    # Workday Account username is NULL on some
    $Script:NewEmployeeID = $name.'Worker ID'
    $Script:NewDescription = $name.'Worker Type' + "-" + $name.'Worker Sub-type'
    $Script:NewTitle = $name.'Job Title'
    $Script:NewStreetAddress = $name.'Work Address Line 1'
        if (!$name.'Work Address Line 2') { } Else { $Script:NewStreetAddress = $name.'Work Address Line 1' + " " + $name.'Work Address Line 2' }
    $Script:NewCity = $name.'Work Address City' 

    if (!$name.'Mobile Phone') { $Script:NewMobileNumber = "NA" } Else { $Script:NewMobileNumber = $name.'Mobile Phone' }
    if (!$name.'Work Phone') { $Script:NewTelephoneNumber = "NA" } Else { $Script:NewTelephoneNumber = $name.'Work Phone' }
    if (!$name.'Work Address State') { $Script:NewState = "NA" } Else { $Script:NewState = $name.'Work Address State' }
    if (!$name.'Work Address Postal Code') { $Script:NewPostalCode = "000000" } Else { $Script:NewPostalCode = $name.'Work Address Postal Code' }
    if (!$name.'Supervisory Organization') { $Script:NewDepartment = "NA" } Else { $Script:NewDepartment = $name.'Supervisory Organization' }
    if (!$name.Company) { $Script:NewCompany = "NA" } Else { $Script:NewCompany = $name.Company }

    # Should Just blank out Manager if NULL
    if (!$name.'Manager Workday Username') { $Script:NewManager = "o365Questions" } Else { $Script:NewManager = $name.'Manager Workday Username' } 
    
    if (!$name.'Work Address Country') { $Script:NewCountry = "AQ" } Else { $Script:NewCountry = $name.'Work Address Country' }
    

 }
