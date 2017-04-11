<#  
.SYNOPSIS
   	Searches Quarantine

.DESCRIPTION  
    Searches for specific domains in Quarantine

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 4/10/2017 - First iteration - kbennett
      
                            
    
    Rights Required		: o365 Permissions
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking
                        : Combine all settings
                        : Allow user to list domain(s)
                        : add a for each by domain



.FUNCTIONALITY
   searches the Quarantine for domain names.
#>	

# To Connect to o365
Import-Module MSOnline
$ocred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $ocred -Authentication Basic -AllowRedirection
Import-PSSession $Session

# Search Quarnetine for domain
Get-QuarantineMessage | `
? {`
$_.Senderaddress -like “*@epiqsystems.com” -or `
$_.Senderaddress -like "*@epiqsystems.co.uk" -or `
$_.Senderaddress -like "*@epiqsystems.com.hk"`
}