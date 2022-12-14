<#  
.SYNOPSIS
   Update Password

.DESCRIPTION  
    This script will change a users password on Epiqcorp and xxCust Environments

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 5/26/2017 - First iteration - kbennett                      
    
    Rights Required		: Domain Permissions in each domain
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 
                        : Add More Domains
                        : Maybe make it a wildcard search so you can pick .. or not?

.FUNCTIONALITY
    Change Password
#>

# Variables
$AccountName = Read-Host "Enter UserName to change password"
$NewPassword = Read-Host "Enter the new Password"
$Servers = @(`
    "server.domain.local",`
    "server.domain.local",`
    "server.domain.local",`
    "server.domain.local",`
    "server.domain.local",`
    "server.domain.com",`
    "domain.com",`
    "apac.domain.com",`
    "euro.domain.com",`
    "amer.domain.com")

Function GetCreds {
    If ($UserCredentials.UserName -eq $null){
        $script:UserCredentials = Get-Credential
    }
}

Function ChangePassword {
    Foreach ($DC in $Servers){
        try {
            Set-ADAccountPassword $AccountName `
                -Reset `
                -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force) `
                -Server $DC `
                -Credential $UserCredentials
            Write-Host "RESET password for" $AccountName "on $DC"-ForegroundColor Green
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }
}

# Main Script
GetCreds
ChangePassword

