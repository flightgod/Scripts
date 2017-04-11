<#  
.SYNOPSIS
   	Sets Database settings

.DESCRIPTION  
    This sets all the settings for database

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 4/10/2017 - First iteration - kbennett
      
                            
    
    Rights Required		: Database Permissions
                        : Database is in OnPrem environment
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking
                        : Combine all settings



.FUNCTIONALITY
   Script to set database settings after newely created
#>

# Connects to Exchange
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session

# Variables
$Database = Read-Host -Prompt 'Input the Database name'

Set-MailboxDatabase $Database -RecoverableItemsQuota 100GB
Set-MailboxDatabase $Database -RecoverableItemsWarningQuota 80GB
Set-MailboxDatabase $Database -RpcClientAccessServer ET016-EX10HUB1.amer.EPIQCORP.COM
Set-MailboxDatabase $Database -MaintenanceSchedule {Tue.1:00 AM-Tue.5:00 AM, Wed.1:00 AM-Wed.5:00 AM, Thu.1:00 AM-Thu.5:00 AM, Fri.1:00 AM-Fri.5:00 AM, Fri.6:00 PM-Mon.5:00 AM}
Set-MailboxDatabase $Database -DeletedItemRetention 29.00:00:00
Set-MailboxDatabase $Database -OfflineAddressBook '\Offline Address Book'
Set-MailboxDatabase $Database -RetainDeletedItemsUntilBackup $True
Set-MailboxDatabase $Database -ProhibitSendQuota unlimited -ProhibitSendReceiveQuota unlimited -IssueWarningQuota unlimited
