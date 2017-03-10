
<# 

.DESCRIPTION 
    Workshop demo files. 
 Mike O'Neill, Microsoft Senior Premier Field Engineer
    Main blog page: http://blogs.technet.microsoft.com/mconeill

LEGAL DISCLAIMER:

This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a
nonexclusive, royalty-free right to use and modify the Sample Code and to
reproduce and distribute the object code form of the Sample Code, provided
that You agree: (i) to not use Our name, logo, or trademarks to market Your
software product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is embedded;
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and
against any claims or lawsuits, including attorneys’ fees, that arise or result
from the use or distribution of the Sample Code.
#> 

#region Exchange/O365
Get-Service 
function verb-noun {

}

#region O365 demo information

# Log onto O365
$Cred = Get-Credential 
$Session = New-PSSession –ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $Cred -Authentication Basic -AllowRedirection 
Import-PSSession $Session 
Connect-Msolservice

#Start-stop transcript
start-transcript c:\temp\PowerShell_transcript.txt
stop-transcript
notepad.exe c:\temp\PowerShell_transcript.txt

#PS history cmdlets
Get-History
Invoke-History –id id#
$MaximumHistoryCount
get-history –count $MaximumHistoryCount

#Filter options
Get-Mailbox 
 
Get-Mailbox -filter {Department -eq "marketing"}

Get-User -filter {Department -like "*marketing*"}

Get-User -filter {Department -like "*marketing*"} |Fl 

Get-User -filter {Department -like "*marketing*"} |Fl name, department, office

Get-User -filter {Department -like "*marketing*"} | Set-User -Office "Chicago"

Get-User -filter {(Department -like "*marketing*") -AND (RecipientType -eq "UserMailbox")} |ft name, Department, RecipientType

Get-User -filter {(Department -like "*marketing*") -AND (RecipientType -eq "UserMailbox")} | set-mailbox -IssueWarningQuota 209715200

Get-Mailbox sally | ft name, IssueWarningQuota

Get-User -filter {(Department -like "*marketing*") -AND (RecipientType -eq "UserMailbox")} |Get-Mailbox | ft name, IssueWarningQuota

Get-User| Where-object {$_.Department -eq "Sales & Marketing"}

#Distribution Groups
New-DistributionGroup -Name "HR and security“  -Alias HR_Security -Type "Distribution"
 
# users:
 
$MRK_USR = Get-User -filter {Department -like "*marketing*"} 
 
$MRK_USR| foreach {Add-DistributionGroupMember -Identity "HR_Security" -Member $_.name}
 
(Get-Date)
(Get-Date).AddMonths(-3)


#Check if it worked:
 
Get-DistributionGroupMember HR_Security

Get-DistributionGroupMember HR_Security | Set-User -Office “Chicago”

#Dynamic Distribution Groups
New-DynamicDistributionGroup -Name "Legal Team" -Alias Legal -IncludedRecipients "MailboxUsers,MailContacts"  -ConditionalDepartment “Legal”

$ddg = Get-DynamicDistributionGroup "legal"

Get-Recipient -RecipientPreviewFilter $ddg.RecipientFilter | FT Alias

#Send Test messages
#This command is to drop email using SMTP server

$msolcred = Get-Credential #save the credential of from address

Send-MailMessage –From user@domain.com –To user@hotmail.com –Subject “Test Email” –Body “Test SMTP Relay Service” -SmtpServer smtp.office365.com -Credential $msolcred -UseSsl -Port 587
Send-MailMessage –From user@domain.onmicrosoft.com –To user@hotmail.com –Subject “Test Email” –Body “Test SMTP Relay Service” -SmtpServer smtp.office365.com -Credential $msolcred -UseSsl -Port 587

#This command is to send email using MX records

Send-MailMessage –From user@domain.com –To user@hotmail.com –Subject “Test Email” –Body “Test SMTP Relay Service” -SmtpServer domain.mail.protection.outlook.com 

#In-Place eDiscovery
New-MailboxSearch "Discovery-CaseId012" -StartDate "1/1/2009" -EndDate "12/31/2011" -SourceMailboxes "DG-Finance" -TargetMailbox "Discovery Search Mailbox" -SearchQuery '"Contoso" AND "Project A"' -MessageTypes Email -IncludeUnsearchableItems -LogLevel Full 

#Reports
Get-MailTrafficReport

Get-MailboxActivityReport -ReportType Monthly -StartDate 01/01/2015 -EndDate 02/28/2015 |Out-File c:\temp\mailstats.txt

Get-MailboxUsageDetailReport -StartDate (Get-Date).AddMonths(-1) -EndDate (Get-Date) |Out-File c:\temp\mailstats2.txt

Get-MailboxUsageDetailReport -StartDate 01/01/2015 -EndDate 02/28/2015 |Export-Csv -path c:\temp\mailstats.csv 

Get-MailboxUsageDetailReport -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date) |Export-Csv -path c:\temp\mailstats2.csv –notypeinformation

Get-MailDetailDlpPolicyReport -StartDate 01/01/2015 -EndDate 02/28/2015 -SenderAddress  katiej@<tenant>.onmicrosoft.com |Out-File c:\temp\mailstats.txt

#In-Place Hold
New-MailboxSearch "Hold-Case" -SourceMailboxes "joe@contoso.com" -InPlaceHoldEnabled $true 

Set-MailboxSearch "Hold-Case" -InPlaceHoldEnabled $false 

Remove-MailboxSearch "Hold-Case"

#Audit Logging
Get-Mailbox | ft name,auditenabled
Set-Mailbox -AuditEnabled $true

Get-Mailbox | Set-Mailbox –AuditEnabled $false

#Find expiring certificates
Cd cert:
Get-ChildItem cert:LocalMachine –recurse | where-object {$_.NotAfter –le (Get-Date).AddDays(30) –And $_.NotAfter –gt (Get-Date)} | Select thumbprint, subject, issuer

#disk speed test
Winsat disk -drive c -ran -write -count 10
#endregion 

#region Networking troubleshooting information

# Peering points connections
Start-Process http://www.peeringdb.com/view.php?asn=8075

# Test for Peering point from current workstation
tracert outlook.office365.com

#Test Connectivity site
Start-Process http://testconnectivity.microsoft.com/

#Hybrid Envrionment Free/busy site
Start-Process http://support.microsoft.com/kb/2555008

#DNS check for autodiscover (NSLookup PS command is listed below)
Resolve-DnsName Autodiscover.mcdeo.onmicrosoft.com
#endregion

#region filtering vs. where-object issue with O365 and throttling process


<#Get-Mailbox cannot handle the -filter. 
The first lines takes hours against O365, is throttled, and eventually is cancelled from O365.
Filter option is preferred in PowerShell but not always available. 
#>

Get-Mailbox | Where-Object {$_.WhenMailboxCreated -le "5/1/2016"}
Get-Mailbox | Where-Object {$_.WhenMailboxCreated -le (get-date).AddDays(-30)}

Get-Mailbox -filter {whenmailboxcreated -gt "2/2/2016"}  #works with no errors and is the correct information
Get-Mailbox -filter {whenmailboxcreated -gt (get-date).AddDays(-2)} #errors out

#endregion 

#region Look for Event ID 64: user deleted meeting request and did not act upon it

Get-EventLog Application

Get-EventLog Application | Where-Object {$_.EventID -eq 64}

Get-EventLog Application | Where-Object {$_.Source -eq "Outlook"}

Get-EventLog Application | Where-Object {($_.Source -eq "Outlook") -and ($_.EventID -eq 64)}
#endregion

#region Messaging
#Get Quarantine Messages
Get-QuarantineMessage -StartReceivedDate 02/13/2013 -EndReceivedDate 02/14/2013

#To release a quarantined message
Get-QuarantineMessage -MessageID <5c695d7e-6642-4681-a4b0-9e7a86613cb7@contoso.com> | Release-QuarantineMessage 

#Search for content to delete from within a mailbox
Search-Mailbox –identity JohnSmith -SearchQuery "abc123"  -TargetFolder DeletedFromJohnSmith -TargetMailbox DumpYardMailbox –DeleteContent
#endregion

#region Users in O365 and on premises

#remove user
Remove-MsolUser -UserPrincipalName bandit@mcdeo.onmicrosoft.com

# Retrieve a list of all deleted users:
Get-MsolUser –ReturnDeletedUsers

# To restore all deleted users:
Get-MsolUser –ReturnDeletedUsers | Restore-MsolUser

# To restore a single deleted user:
Restore-MsolUser –UserPrincipalName  john@contoso.com

#Steps to look for and return deleted user
Get-Mailbox bandit

Get-MsolUser -ReturnDeletedUsers

Restore-MsolUser -UserPrincipalName User@contoso.com

Get-Mailbox User

#endregion

#region Merge one mailbox into another mailbox to recover from a deleted user.

# List the Soft Deleted Mailboxs and pick the one that needs to be imported 
$DeletedMailbox = Get-Mailbox -SoftDeletedMailbox | Select DisplayName,ExchangeGuid,PrimarySmtpAddress,ArchiveStatus,DistinguishedName | Out-GridView -Title "Select Mailbox and GUID" -PassThru

# Get Target Mailbox 
$MergeMailboxTo = Get-Mailbox | Select Name,PrimarySmtpAddress,DistinguishedName | Out-GridView -Title "Select the mailbox to merge the deleted mailbox to" -PassThru

# Run the Merge Command 
New-MailboxRestoreRequest -SourceMailbox $DeletedMailbox.DistinguishedName -TargetMailbox $MergeMailboxTo.PrimarySmtpAddress -AllowLegacyDNMismatch

# View the progress 
#Grab the restore ID for the one you want progress on. 
$RestoreProgress = Get-MailboxRestoreRequest | Select Name,TargetMailbox,Status,RequestGuid | Out-GridView -Title "Restore Request List" -PassThru

# Get the progress in Percent complete 
Get-MailboxRestoreRequestStatistics -Identity $RestoreProgress.RequestGuid | Select Name,StatusDetail,TargetAlias,PercentComplete

#Pass thru option in Out-Gridview demo
Get-Service | Out-GridView -PassThru

Get-Service | Out-GridView -PassThru > c:\temp\services.txt
notepad.exe C:\Temp\services.txt
#endregion

#region on-premises Exchange server logon functions

#Specific server in function. Engineers can change the function and computer name per server in their org.
Function Connect-CON-EX2016N1 {
    $UserCredential = Get-Credential 
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://con-ex2016n1/PowerShell/ -Credential $UserCredential 
    Import-PSSession $Session
}

#Parameter requiring specific server
Function Connect-ExServer {   
    param ($Computer)
        $UserCredential = Get-Credential 
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$Computer/PowerShell/ -Credential $UserCredential 
        Import-PSSession $Session
}
#endregion
#endregion

#logon
Import-Module MsOnline
Connect-MsolService

#Create User:#
New-MsolUser -userprincipalname user4@plentyotime.onmicrosoft.com -displayname user4 -firstname user -lastname 4 -licenseassignment plentyotime:ENTERPRISEPACK -usagelocation US

#License information from tenant
Get License Info:

Get-msolaccountsku

#Get Service Plans:
Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq 'ENTERPRISEPACK'} |ForEach-Object {$_.ServiceStatus}

#Create User with all service plans:
New-MsolUser -userprincipalname user5@tenantdomain.onmicrosoft.com -displayname user5 -firstname user -lastname 5 -licenseassignment plentyotime:ENTERPRISEPACK -licenseoptions $options -usagelocation US

#Create User with specific service plans:
$options = New-MsolLicenseOptions -AccountSkuId plentyotime:ENTERPRISEPACK -DisabledPlans MCOSTANDARD,SHAREPOINTWAC,SHAREPOINTENTERPRISE

#Update user with specifc service plans:
Set-MsolUserLicense -UserPrincipalName user4@plentyotime.onmicrosoft.com -LicenseOptions $options

#Remove license for a user:
Set-MsolUserLicense -UserPrincipalName user5@plentyotime.onmicrosoft.com -RemoveLicenses "plentyotime:ENTERPRISEPACK"

#License reports:
Get-MsolUser | Where-Object { $_.isLicensed -eq "TRUE" }

Get-MsolUser | Where-Object { $_.isLicensed -eq "TRUE" } | Export-Csv LicensedUsers.csv

Get-MsolUser -UnlicensedUsersOnly

#Find and restore deleted users:
get-msoluser -returndeletedusers

Restore-MsolUser -userprincipalname deluser@plentyotime.onmicrosoft.com

#Work with UPNs:
get-aduser -filter {UserPrincipalName -like "*ksthilaire*"}

get-aduser -filter {UserPrincipalName -like "*@plentyotime.lab"} | foreach {set-ADUser -identity $_.SAMAccountName -UserPrincipalName ($_.SAMAccountName + “@sandym.msftonlinerepro.com”)}

get-aduser -filter {UserPrincipalName -like "*@sandym.msftonlinerepro.com"} | foreach {set-ADUser -identity $_.SAMAccountName -UserPrincipalName ($_.SAMAccountName + “@plentyotime.lab”)}

