<#  
.SYNOPSIS
   	Creates PST file of Mailboxes

.DESCRIPTION  
    Creates PST file of Mailboxes

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 4/10/2017 - First iteration - kbennett
      
                            
    
    Rights Required		: Mailbox Permissions
                        : Permissions on UNC Location for writing to
                        : Mailbox is in OnPrem environment
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 
                        : Date Range of 365 days instead of set dates
                        : Check oldest email
                        : Check username 
                        : Run for o365 or onPrem
                        : Save by Year instead of just number

.FUNCTIONALITY
   This script Creates PST files by year for a users mailbox or archive mailbox.
#>

# Connects to Exchange
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<FQDN to Exchange Server/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session


#Variables for Export to PST
$i = 0
$Today = get-date -Format %M/%d/%y
$UsersName = Read-Host -Prompt 'Input the user name'
$Location = Read-Host -Prompt 'Input the Location UNC Path'
$First = $Location + $UsersName
$FileName = $First + $i + ".pst"
$Archive = Read-Host -Prompt 'Is it an Archive Mailbox? (Y/N)'

# Is it archive?
If ($Archive -eq 'Y') 
	{
		ArchiveMBX

	}
Else
{
		Mailbox
}

Remove-PSSession $Session

# Export Mailbox to PST
Function Mailbox {
New-MailboxExportRequest -ContentFilter {(Received -lt $Today) -and (Received -gt '04/01/2016')} -Mailbox $UsersName -FilePath $FileName
$FileName = $First + $i + ".pst"
New-MailboxExportRequest -ContentFilter {(Received -lt '04/1/2016') -and (Received -gt '04/01/2015')} -Mailbox $UsersName -FilePath $FileName
$FileName = $First + $i + ".pst"
New-MailboxExportRequest -ContentFilter {(Received -lt '04/1/2015') -and (Received -gt '04/01/2014')} -Mailbox $UsersName -FilePath $FileName
$FileName = $First + $i + ".pst"
New-MailboxExportRequest -ContentFilter {(Received -lt '04/1/2014') -and (Received -gt '04/01/2013')} -Mailbox $UsersName -FilePath $FileName
$FileName = $First + $i + ".pst"
New-MailboxExportRequest -ContentFilter {(Received -lt '04/1/2013') -and (Received -gt '04/01/2012')} -Mailbox $UsersName -FilePath $FileName
}

Function ArchiveMBX {
# Export Arcvhive Folder to PST
New-MailboxExportRequest -ContentFilter {(Received -lt $Today) -and (Received -gt '04/01/2016')} -Mailbox $UsersName -FilePath $FileName -IsArchive
$FileName = $First + $i + ".pst"
New-MailboxExportRequest -ContentFilter {(Received -lt '04/1/2016') -and (Received -gt '04/01/2015')} -Mailbox $UsersName -FilePath $FileName -IsArchive
$FileName = $First + $i + ".pst"
New-MailboxExportRequest -ContentFilter {(Received -lt '04/1/2015') -and (Received -gt '04/01/2014')} -Mailbox $UsersName -FilePath $FileName -IsArchive
$FileName = $First + $i + ".pst"
New-MailboxExportRequest -ContentFilter {(Received -lt '04/1/2014') -and (Received -gt '04/01/2013')} -Mailbox $UsersName -FilePath $FileName -IsArchive
$FileName = $First + $i + ".pst"
New-MailboxExportRequest -ContentFilter {(Received -lt '04/1/2013') -and (Received -gt '04/01/2012')} -Mailbox $UsersName -FilePath $FileName -IsArchive
}

