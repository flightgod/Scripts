<#  
.SYNOPSIS
   Get users with Public Folder SendAs permissions

.DESCRIPTION  
   

.INSTRUCTIONS
    

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 6/8/2017 - First iteration - kbennett 

        
    Rights Required		    : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Check and update additional Info from Export

.FUNCTIONALITY
  
#>

# Variables
$ExchangeServer = "http://MBX01.amer.domain.com/PowerShell/"

Function ExchangeConnect 
{
    If ($Session.ComputerName -like "mbx01.amer.domain.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $UserCredential = Get-Credential
        $script:Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}


Function PFSendAs {

$Script:AllObjectsUsers = Get-ADObject `
    -Server "server.amer.domain.COM" `
    -Filter {(ObjectClass -eq "user")}
   $AllObjectsUsers.count

    ForEach ($User in $AllObjectsUsers) {
        $script:SendAsPermissions = Get-ADPermission $User.DistinguishedName |`
        Where { 
            $_.ExtendedRights -like '*Send-As*' `
            -and $_.User.ToString() -ne 'NT AUTHORITY\SELF' `
            -and $_.User.ToString() -ne 'AMER\ICADMIN' `
            -and $_.User.ToString() -ne 'AMER\svc_*' `
            -and $_.User.Tostring() -ne 'AMER\svc_unitymsgstoresvc' `
            -and $_.user.ToString() -ne 'AMER\qmigrate' `
            -and $_.user.ToString() -ne 'AMER\bspeich' `
            -and $_.user.ToString() -like 'amer\*'
        } | 
        Select Identity,User | FT -AutoSize | Export-Csv .\User_sendAsPermission_newl.csv -NoTypeInformation
        $SendAsPermissions
        $AllObjectsUser.item
    } 
    
    #$SendAsPermissions | Export-Csv .\User_sendAsPermission_newl.csv -NoTypeInformation -Append
}
ExchangeConnect
PFSendAs                 
