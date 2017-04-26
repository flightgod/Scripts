<#  
.SYNOPSIS
   	Move Databases between Servers

.DESCRIPTION  
    This script moves the databases between servers.

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 4/10/2017 - First iteration - kbennett
      
                            
    
    Rights Required		: Mailbox Permissions
                        : Mailbox is in OnPrem environment
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 
                        : make it look better
                        : some For loops


.FUNCTIONALITY
    This script moves the databases between servers.
#>

# Connects to Exchange
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session

# Move Databases to Primary/Seconday
$server = Read-Host -Prompt 'Which Server ET016-EQEXMBX01/P054EXCMBXS01?'

Move-ActiveMailboxDatabase Database1 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database2 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database3 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database4 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database5 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database6 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database7 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database8 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database9 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database10 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database11 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database12 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database13 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database14 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database15 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database16 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database17 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database18 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database19 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database20 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database21 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database22 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database23 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database24 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database25 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database26 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database27 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
#Move-ActiveMailboxDatabase Database28 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database29 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database30 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database31 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database32 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database33 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database34 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database35 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database36 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database37 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database38 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database39 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database40 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database41 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database42 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database43 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database44 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database45 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Database46 -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Archive1_DB -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Archive2_DB -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false
Move-ActiveMailboxDatabase Archive3_DB -ActivateOnServer $Server -SkipClientExperienceChecks -confirm:$false

Exit-PSSession $Session