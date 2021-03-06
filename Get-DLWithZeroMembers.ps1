<#  
.SYNOPSIS
   	Get DistroLists with no members

.DESCRIPTION  
    This script will get a list of Distribution Lists with No Members assign, mark to delete and move to OU to delete

.INSTRUCTIONS
    Put instructions for running all the task, Script, CR .. etc (or where to find them)
    1. Run this script
    2. Create CR for Deleting
    3. After Approval, Delete

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/18/2017 - First iteration - kbennett 
        
    Rights Required		    : Exchange Permissions to Add/Edit Contacts
				            : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Work on identifying and not moving "New" Groups - CheckDateCreated Function

.FUNCTIONALITY
    Search DL, Change Group Info, Move AD Object
#>

# Variables
$ExchangeServer = "http://P054EXCTRNS01.amer.EvilCorpcorp.com/PowerShell/"
$Domain = "amer.EvilCorpcorp.com"
$NewPath = "OU=GroupsDelete,OU=Exchange-Team,DC=amer,DC=EvilCorpCORP,DC=COM"
$File = "c:\Temp\ZeroDLtoDelete.txt"
$Date = Get-Date
$Today = $Date | Get-date -Format MM/dd/yyyy
$LastMonth = $Date.AddMonths(-1) | Get-date -Format MM/dd/yyyy
$BlankDL = @()
$DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM"

# Connects to Exchange
Function ExchangeConnect 
{
    If ($Session.ComputerName -like "P054EXCTRNS01.amer.EvilCorpcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $script:UserCredential = Get-Credential
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
    $script:BlankDL = $dls.name |? {!(get-distributiongroupmember $_)}
    Write-Host "Searched a total of "$dls.count " Distros for Zero Members and found " $BlankDL.count " With no members" -ForegroundColor Yellow
    $BlankDL > $File 
}

# Move those to an OU to be able to delete easily
Function MoveDL {
    foreach ($IndividualDL in $BlankDL){
         Get-ADGroup $IndividualDL | `
         Move-adobject -identity {$_.objectguid} -Server $DomainController -TargetPath $NewPath -Credential $UserCredential
    }
}

# Check weather it is a new group, maybe created recently
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
# CheckDateCreated($BlankDL)
# MoveDL($BlankDL,$UserCredentials)
