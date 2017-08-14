<#  
.SYNOPSIS
   	Update Epiq All Distribution List

.DESCRIPTION  
    This script will read list of FTE Users from Workday, verify that the user exists in AD, and see if it is 
    already a member of the Epiq All DL. If not it will add it

.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.0 - Posted 5/3/2017 - First iteration - kbennett 
                            : 1.1 - Posted 5/19/2007 - Bug Fixes - kbennett
        
    Rights Required		    : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Need to add a check for irisds.com address. And do a different check against that one

             
.FUNCTIONALITY
    Update Distibution List, Check user exists
#>

# Variables
param (
$ImportFile = "C:\Temp\FTEList.csv",
$DomainController = "P016ADSAMDC01.amer.EPIQCORP.COM",
$GroupName = "Epiq-All@Epiqsystems.com",
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
)

# Connects to Exchange
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

# Function import list of users
Function ImportList {
    $test = Test-Path $ImportFile
    If ($test -eq $true) {
        $script:import = Import-csv $ImportFile
    }
    Else {
        Write-Warning "Something went Wrong: File is missing at $ImportFile"
        Break
    }
}

# Function Check user exists
Function CheckUser {
    foreach ($Name in $import) {
        $script:UserInfo = $Name."Email Address"
        # Only checks if Email address is epiqsystems.com
        If ($UserInfo -Like "*epiqsystems.com") {
        $script:CheckUser = Get-ADuser -Filter "EmailAddress -like '$UserInfo'" -Properties Name,EmailAddress -Server $DomainController
            If ($CheckUser -eq $Null) { 
                Write-host $Name.Worker "Doesn't Exist in AMER AD - Skipping" -foregroundcolor Red
                Add-Content c:\temp\Epiq-AllUserDoesntExist.txt $Name.Worker
            } 
            Else { 
                CheckDL ($UserCredential) 
            }
        }
        Else {
            Write-host "Email address is" $UserInfo -ForeGroundColor Yellow
            Add-Content c:\temp\Epiq-AllBadUserEmailAddress.txt $UserInfo
        }
        # added a check for irisds.com address. And do a different check against that one. Removes the domain and checks against just the name
        # Limitation is still if the irisds.com username is different than the Epiq Sysetms Username
        If ($UserInfo -Like "*irisds.com") {
            $Seperator = "@"
            $IrisUsername = $UserInfo.Split($Seperator)
            $IrisUsername = $IrisUsername[0]
            $script:CheckUser = Get-ADUser -Filter "EmailAddress -like '$IrisUserName*'" -Properties Name,EmailAddress -Server $DomainController
             If ($CheckUser -eq $Null) { 
                Write-host $Name.Worker "Doesn't Exist in AMER AD - Skipping" -foregroundcolor Red
                Add-Content c:\temp\Epiq-AllUserDoesntExist.txt $Name.Worker
            } 
            Else { 
                CheckDL ($UserCredential) 
            }
        }
    }
}

# Function Check User in DL
Function CheckDL {
    $members = Get-DistributionGroupMember -Identity $GroupName -ResultSize Unlimited | Select -ExpandProperty Name
    If ($members -contains $CheckUser.Name) {
        Write-Host $CheckUser.EmailAddress "exists in the group"
    } 
    Else {
        Write-Host $CheckUser.EmailAddress "Being Added to group" $GroupName -foregroundcolor Yellow
        Add-Content c:\temp\Epiq-AllUserAdded.txt $CheckUser.EmailAddress
        AddUser
    } 
}

# Function Add new user to DL
Function AddUser {
    Add-ADGroupMember -Identity $GroupName -Members $CheckUser.SamAccountName -Credential $UserCredential
}

# Begin of Script
ExchangeConnect
ImportList ($ImportFile)
CheckUser