<#  
.SYNOPSIS
   	Add Contact to Distribution List

.DESCRIPTION  
    This script will Add Users to a DL

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/22/2017 - First iteration - kbennett 
         
    Rights Required		    : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking

             
.FUNCTIONALITY
    Update Distibution List, Check user exists
#>

# Variables
$ContactOU = "OU=Contacts,OU=DTI,DC=amer,DC=EPIQCORP,DC=COM"
$DomainController = "P016ADSAMDC01.amer.EPIQCORP.COM"


Function GetContact {
    $Script:Name = Read-Host "What is the Contacts Email to add? "
    If ($Name -eq ""){
        Write-Host "You forgot to enter a contacts Email address" -ForegroundColor Red
        GetContact
    }
    Else {
        AddContact $Name
    }
}

Function AddContact {
    Get-ADObject -LDAPFilter "objectClass=Contact" -Properties Name, Mail -SearchBase $ContactOU -Server $DomainController | `
    ? {$_.Mail -like "$Name"}
    try {
        Add-DistributionGroupMember -Identity everybody_irisds.com -Member $Name -BypassSecurityGroupManagerCheck
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        }
    Finally {
        
        }
}

GetContact
