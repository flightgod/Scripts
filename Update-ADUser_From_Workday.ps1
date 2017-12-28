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

# Variables

$todayDate = get-date -Format yyyyMMdd
$todayYear = get-Date -Format yyyy
$todayMonth = get-Date -Format MM
$todayDay = get-Date -Format dd
$todayFileDate = $todayYear + "-" + $todayMonth + "-" + $todayDay + "_14"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$Path = "\\ks-isnl-prod.sn2.amer.epiqcorp.com\eca\prod\mft\Internal-Use-Only\web-users-home\svc_WorkdayGOA"
$TempPath = "c:\Temp"
$file = "\INT0016_TEST_AD_Employee_" + $todayFileDate + ".csv"
$DomainList = "epiqcorp.com","amer.epiqcorp.com","apac.epiqcorp.com","euro.epiqcorp.com"
$ADProperties = "EmployeeID","SamAccountName","Name","Givenname","SurName","Descriptions","telephoneNumber","MobileNumber","Title","StreetAddress","City","State","PostalCode","Country","Manager","Department","Company","Mail"
$FullPath = $TempPath + $file

# Calling other files and Function
.".\Function-Connect.ps1" # Calls my connect function with all the current connection strings in it
# .".\Function-CreateADUser.ps1"
# .".\Function-CreateMailbox.ps1"
# .".\Function-EnableLync.ps1"
# .".\Function-EnableSkype.ps1"



# Import List
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
 $Script:Continue = ""
     foreach ($Script:name in $import){
        $script:username = $name.'Workday Account Username'
        forEach ($domain in $DomainList){
            If (Get-ADUser -Server $domain -Filter {samAccountName -eq $username}) {
                write-Host "User $username Exist in $domain" -ForegroundColor Red
                $Continue = "NO"
                } Else {
                    Write-Host "User $username doesn't exist in $domain" -ForegroundColor Green
                }
        }
        If ($continue -eq ""){
            write-host "Account Doesnt Exist - Here we should probably break out and Create that account then send info to workday" -ForegroundColor Red
            #CreateADAccount
        } Else {
            # Need to run the Update Function here to update thier Info
            UpdateInfo
            Write-host "Account Exists already, Sending Email Address to Workday" -ForegroundColor Green
            UpdateWorkday
        }
    }
}

# for successful verification of user existing to update workday on thier true Email Address
Function UpdateWorkday {
    $Userinfo = Get-ADUser sbowerman -Properties * -Server $DomainController | Select $ADProperties
    $FileName = "c:\temp\AD_to_Workday_export_" + $todayDate + ".csv"
    $userInfo | Export-Csv -path $FileName -NoTypeInformation -Append
}

# need to update
# create an AD Account if not found
Function CreateADAccount {
    # this should be to create an account. might need to move off to another Script
    $Script:upn = $username +"@epiqsystems.com" #Creates UPN
    $Script:DisplayName = $name.'Last Name' +"," + $name.'First Name' #Creates Display Name
<#  
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
        -EmployeeID $Name.'Worker ID'
#>
    #Need to add dtiglobal.com to Attribute13 
    Get-ADUser $username | `
        Set-ADObject `
        -add @{extensionAttribute13="dtiglobal.com"} -Credential $UserCredential
    # Here it should create a mailbox
    # CreateRemoteMailbox # We create a new mailbox for them

    # here i should enable skype if it is required
}


Function UpdateInfo {
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

    Set-ADUser `
        -Identity $username `
        -EmployeeID $NewEmployeeID `
        -Description $NewDescription `
        -MobilePhone $NewMobileNumber `
        -OfficePhone $NewTelephoneNumber `
        -Title $NewTitle `
        -StreetAddress $NewStreetAddress `
        -City $NewCity `
        -State $NewState `
        -PostalCode $NewPostalCode `
        -Country $NewCountry `
        -Manager $NewManager `
        -Department $NewDepartment `
        -Company $NewCompany
        
    # commented out for testing. Remove 
    #Set-ADUser -Identity $username -Replace @{EmployeeID = $NewEmployeeID;Description = $NewDescription }
}

Function DeleteFile {
    # This is where we will delete the file after reading and updating


}




#Script Main body
 # Connect-Exchange # calls from the .function-connect.ps1
 # importUsers $file #Imports first file
 # checkUser #checks to see if user account already exists
 # DeleteFile

 #Session-Disconnect # Cleans up our PSSessions from Function-connect



 Function TestingGetUser {
 
 $Userinfo = Get-ADUser sbowerman -Properties * -Server $DomainController | Select $ADProperties
 $FileName = "c:\temp\AD_to_Workday_export_" + $todayDate + ".csv"
 $userInfo | Export-Csv -path $FileName -NoTypeInformation -Append

 }


 Function TryCatch {

    try {$a = Get-Mailbox asdf}
    Catch { } # if fail it exitsnothing it doesnt go through 


 }