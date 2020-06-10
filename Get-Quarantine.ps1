<#
.SYNOPSIS
   	Gets any Quarantine messages from internal addresses

.DESCRIPTION  
    This will search EOP and get any Quarantine Messages that appear to be from Internal or asdf users. This will help to identify
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
$List = `
    "*@domain.co.uk",`
    "*@domain.com",`
    "*@domain.com.hk",`
    "*@domain2.com",`
    "*@domain-ks.com",`
    "*@domain3.com",`
    "*@domain4.com",`
    "*@domain5.com"

# Loads the o365 Connection Function
. .\Connect-o365.ps1

# Calls the Funtion to connect to o365
Connect-o365

# Runs through each domain in the list variable and searches for Quarantined Messages
Foreach ($domain in $List){
    Get-QuarantineMessage | ? {$_.Senderaddress -like $domain} | FL
}

# Disconnects Session 
Session-Disconnect

pause
