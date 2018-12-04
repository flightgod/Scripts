<#  
.SYNOPSIS
   	Cleanup o365 License

.DESCRIPTION  
    Clean up manually assigned licenses from Disabled accounts

.INSTRUCTIONS
    Call this from your other scripots

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/1/2017 - First iteration - kbennett 
        
    Rights Required		    : Exchange Permissions to Add/Edit Contacts
				            : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	:

.FUNCTIONALITY

#>

param (
$ImportFile = "C:\Temp\P1_Dec_3.csv",
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM",
$OU = "OU=Distribution Groups,OU=Exchange,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
)

Function Connect-o365 {
    $o365Credential = Get-Credential
    Import-Module MSOnline
    Connect-MsolService -Credential $o365Credential
    $o365Session = New-PSSession `
    -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -Authentication Basic `
    -AllowRedirection `
    -Credential $o365Credential
    Import-PSSession $o365Session

}

Function Session-Disconnect {
    # Disconnects Session 
    $s = Get-PSSession
    $s
    Remove-PSSession -Session $s
}


# Function import list of users
Function ImportList {
    $test = Test-Path $ImportFile
    If ($test -eq $true) {
        $script:import = Import-csv $ImportFile
    }
    Else {
        Write-Warning "Something went Wrong: File is missing at $ImportFile"
        Break
    }
}


Function Cleanup {
    ForEach ($user in $import){
        #Get-MSolUser -UserPrincipalName $user.UserPrincipalName
        Set-MSolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicenses "epiqsystems3:EXCHANGESTANDARD"
    }
}


Get-MSolUser -ALL | Select UserPrincipalName, Licenses | Where {$_.BlockedCredentials -eq $True -and $_.IsLicenses -eq $True}