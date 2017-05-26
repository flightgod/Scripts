<#  
.SYNOPSIS
   REmove Old User Profiles

.DESCRIPTION  
    This script will remove old User Profiles

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 5/26/2017 - First iteration - kbennett                      
    
    Rights Required		: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 

.FUNCTIONALITY
    Search Last used, Delete Folder
#>



Get-CimInstance -ClassName Win32_UserProfile | 
Where {(!$_.Special) -and ($_.LastUseTime -lt (Get-Date).AddDays(-180))} |
ForEach-Object {
$_ | Remove-CimInstance
}