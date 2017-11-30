<#  
.SYNOPSIS
   	Sets a forward on mailbox

.DESCRIPTION  
    This will set the forwardSMTPAddress on a mailbox to an different mailbox. Specifically from an Intermedia
    mailbox to o365 mailbox. Import CSV should have 2 columns, DTIEmail and EpiqEmail

.INSTRUCTIONS
    Run full script 

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 11/29/2017 - First iteration - kbennett 
        
    Rights Required	        : AD Permissions to Add/Edit mail objects Objects
                            : Run from Exchange Powershell
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	:

.FUNCTIONALITY
    Import File to Array, Check Existing User, Sets ForwardingsmtpAddress
#>

# Variables
Param (
$file = "C:\Temp\All_DTI_Users.csv"
)


# Checks that the file is there, then imports it
Function ImportFile {
    $test = Test-Path $file
    If ($test -eq $true) {
        $script:import = Import-csv $file
    }
    Else {
        Write-Warning "Something went Wrong:  Import File is missing at $file"
        Break
    }
}

# This function checks to make sure the user has a mailbox. we dont want to be trying to set forward if we dont need to
Function CheckForUser {
    foreach ($Name in $import){
        $CheckUser = Get-mailbox $Name.DTIEmail
            If ($CheckUser -eq $Null){
                Write-Host "Not there" -ForegroundColor Red
                Add-Content c:\temp\Account_Missing.txt $Name.DTIEmail
            } 
            Else {
                Write-Host $name.DTIMail "is in Exchange, We will now set the forward" -ForegroundColor Green
                $script:DTIAddress = $Name.DTIEmail
                $Script:EpiqAddress = $Name.EpiqEmail
                Start-Sleep -s 2
                SetForward
                $CheckUser = $Null
            }
    }
}

# This sets our forward and turns off delivering to local box also. 
Function SetForward {
    Set-Mailbox $DTIAddress -ForwardingsmtpAddress $EpiqAddress -DeliveryToMailboxAndForward $False
    
}

# Script Main Body
ImportFile
CheckForUser