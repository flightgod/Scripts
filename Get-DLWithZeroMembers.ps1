<#  
.SYNOPSIS
   	Get DistroLists with no members

.DESCRIPTION  
    This script will get a list of Distribution Lists with No Members assign, mark to delete and move to OU to delete

.INSTRUCTIONS
    Put instructions for running all the task, Script, CR .. etc (or where to find them)

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/18/2017 - First iteration - kbennett 
        
    Rights Required		    : Exchange Permissions to Add/Edit Contacts
				            : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Check and update additional Info from Export

.FUNCTIONALITY
    Search DL, Change Group Info, Move AD Object
#>

# Variables
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
$Domain = "amer.epiqcorp.com"
$NewPath = "OU=Delete,OU=Exchange-Team,DC=amer,DC=EPIQCORP,DC=COM"
$File = "c:\Temp\ZeroDLtoDelete.txt"
$Date = Get-Date
$Today = $Date | Get-date -Format MM/dd/yyyy
$LastMonth = $Date.AddMonths(-1) | Get-date -Format MM/dd/yyyy
$BlankDL = @()

# Connects to Exchange
Function ExchangeConnect 
{
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $UserCredential = Get-Credential
        $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

# Gets DL's with No Members
Function GetDL {
    $dls = get-distributiongroup -resultsize unlimited
    $BlankDL = $dls.name |? {!(get-distributiongroupmember $_)}
    Write-Host "Searched a total of "$dls.count " Distros for Zero Members and found " $BlankDL.count " With no members" -ForegroundColor Yellow
    $BlankDL > $File 
}

# Move those to an OU to be able to delete easily
Function MoveDL {
    foreach ($IndividualDL in $BlankDL){
         Move-ADObject $IndividualDL -Server $Domain -TargetPath $NewPath
    }
}


Function CheckDateCreated {
    ForEach ($DL in $BlankDL){
        $OldDL = Get-DistributionGroup -Identity $DL -ResultSize Unlimited | ? {$_.WhenCreated -gt $LastMonth}
        }
        ForEach ($NewDL in $OldDL){
            Write-Host "The following groups are not very old, verify they should be deleted" $OldDL.Name "Was created on:" $OldDL.WhenCreated -ForegroundColor DarkRed -BackgroundColor Yellow
            $BlankDL.Count
            $BlankDL.Remove($NewDL)
            $BlankDL.Count
        }
}

# Main Script Body
ExchangeConnect
GetDL
# MoveDL