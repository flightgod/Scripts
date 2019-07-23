<#
.SYNOPSIS
   	Gets any Quarantine messages from internal addresses

.DESCRIPTION  
    This will search EOP and get any Quarantine Messages that appear to be from Internal or DTI users. This will help to identify
    SendAs or SPF record issues. 

.INSTRUCTIONS
    Run this

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/1/2017 - First iteration - kbennett 
        
    Rights Required		    : o365 Permissions
				            : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	:

.FUNCTIONALITY



#>

# Variables
$MBXServer = "ET016-EQEXMBX01","P054EXCMBXS01"


# Call the Connect Exchange Funtion
. .\Connect-Exchange.ps1

#Connect to Exchange
Connect-Exchange 

ForEach ($Server in $MBXServer){
    Get-MailboxDatabaseCopyStatus * | ? {$_.Name -like "Database*" -or $_.Name -like "Archi*"}
}

# Get-PSSession | Remove-PSSession
