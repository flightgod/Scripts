<#  
.SYNOPSIS
   	Move Databases between Servers

.DESCRIPTION  
    This script moves the databases between servers.It can be ran from anywhere not just the Exchange servers

.NOTES  
    Current Version     : 1.1
    
    History				: 1.0 - Posted 4/10/2017 - First iteration - kbennett 
                        : 1.1 - 4/26/2017 - Removed Manual Database listing and adding loop - kbennett          
    
    Rights Required		: Mailbox Permissions
                        : Mailbox is in OnPrem environment
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 

.FUNCTIONALITY
    This script moves the databases between servers.
#>

# Connects to Exchange - so you can run remotely
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session

# Move Databases to Primary/Seconday
$server = Read-Host -Prompt 'Which Server ET016-EQEXMBX01/P054EXCMBXS01?'

# Variables
$dbs = Get-MailboxDatabase | where {$_.AdminDisplayName -like "Datab*" -or $_.AdminDisplayName -like "Archi*"}
$i=0
$count = $dbs.Count

# Loops through Databases found and moves them to other server
Do
{
    $name = $dbs.item($i).Name
    Move-ActiveMailboxDatabase $name -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
    $i = $i + 1
}
until ($i -eq $count)

Exit-PSSession $Session