<# Testing the Search and Report


$Domains = "P054ADSAMDC01.amer.epiqcorp.com"
$Days = "195"

Search-ADAccount -Server $Domains -accountinactive -usersonly -timespan $Days | `
    Where {$_.LastLogonDate -Ne $null -and $_.SamAccountName -inotlike "svc_*" -and $_.DistinguishedName -like "*disabled*"} | `
    Sort LastLogonDate |`
    Select Name,LastLogonDate,AccountExpirationDate,SamAccountName,Enabled,DistinguishedName |`
    ConvertTo-HTML |`
    Out-File C:\Scripts\OldAccounts.htm

$info = "excludes no logon date and accounts with svc_ "
$report = (get-content c:\Scripts\OldAccounts.htm | out-String)
$body = $info += $report

Send-MailMessage `
    -From powershellfoo@epiqsystems.com `
    -Subject "Accounts Older than 180 Days" `
    -To kbennett@epiqsystems.com `
    -smtpserver Relay.amer.epiqcorp.com `
    -Body $body  -BodyAsHtml

    
#>



# This is the live one from here down

# Functions File
."c:\Scripts\Kevins_Functions.ps1"

#Variables
$Domains = "amer.epiqcorp.com"
$time = "90"
$now = Get-Date

#First Report - 180 Days
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
$info = "<h1 align=""center""> Accounts Older than 9 Days with no LoginDate</h1>
        <h3 align=""center"">Generated: $now</h3>
        <p>Excludes Accounts with svc_*</p>"
$where = {$_.LastLogonDate -eq $null -and $_.SamAccountName -inotlike "svc_*" -and $_.DistinguishedName -like "*disabled*"}
# Runs Third Report
RunReport $Path $Domains $time $where
# Email Third Report
SendReport $Subject $path $info