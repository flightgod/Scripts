<#  
.SYNOPSIS
   Search and Report Old Accounts

.DESCRIPTION  
    This script will search AD for Old Accounts depending on criteria set and report that back in a nice HTML Report via Email

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 1/12/2017 - First iteration - kbennett                      
    
    Rights Required		: Access to the Kevins_Funtions Powershell Script
                        : AD Search Permissions
                        : Permissions to send via the SMTP Relay
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 
                        : make it look better

.FUNCTIONALITY
    Functions, Reports and SMTP EMail
#>

# Functions File
."c:\Scripts\Kevins_Functions.ps1"

#Variables
$Domains = "amer.epiqcorp.com"
$time = "90"
$now = Get-Date

#First Report - 90 Days
$path = "c:\Scripts\LastLogon.htm"
$Subject = "AMER - Accounts Older than 90 Days"
$info = "<h1 align=""center"">Accounts Older than 90 Days</h1>
        <h3 align=""center"">Generated: $now</h3>
        <p>Excludes no logon date and accounts with svc_* and AccountExpired</p>"
$where = {$_.LastLogonDate -ne $null -and $_.SamAccountName -inotlike "svc_*"  -and $_.AccountExpirationDate -eq $Null -and $_.DistinguishedName -like "*disabled*"}
# Runs First Report
RunReport $Path $Domains $time $where
# Email First Report
SendReport $Subject $path $info


#Second Report - Expired
$path = "c:\Scripts\LastLogon-Expired.htm"
$Subject = "AMER - Accounts Older than 90 Days that are set as Expired"
$info = "<h1 align=""center"">Accounts Older than 90 Days that have Expired</h1>
        <h3 align=""center"">Generated: $now</h3>
        <p>Excludes no logon date and accounts with svc_*</p>"
$where = {$_.LastLogonDate -Ne $null -and $_.SamAccountName -inotlike "svc_*" -and $_.AccountExpirationDate -ne $Null -and $_.DistinguishedName -like "*disabled*"}
# Runs Second Report
RunReport $Path $Domains $time $where
# Email Second Report
SendReport $Subject $path $info


#Third Report - No Login
$path = "c:\Scripts\LastLogon-NO Login Date.htm"
$Subject = "AMER - Accounts Older than 90 Days with no LoginDate"
$info = "<h1 align=""center"">Accounts Older than 9 Days with no LoginDate</h1>
        <h3 align=""center"">Generated: $now</h3>
        <p>Excludes Accounts with svc_*</p>"
$where = {$_.LastLogonDate -eq $null -and $_.SamAccountName -inotlike "svc_*" -and $_.DistinguishedName -like "*disabled*"}
# Runs Third Report
RunReport $Path $Domains $time $where
# Email Third Report
SendReport $Subject $path $info