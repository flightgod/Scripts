# *****************WORK IN PROGRESS ******************


<#  
.SYNOPSIS
   	Add or remove USer from Azure Sync

.DESCRIPTION  
    This script will add a user or remove that user from Azure Sync

.INSTRUCTIONS
    Run to fix issues with Azure Sync or remove a warden/service account from Azure Sync

.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.0 - Posted 6/20/2017 - First iteration - kbennett 
        
    Rights Required         : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: xxxxxx

.FUNCTIONALITY
    Get User Info, Update user info
#>



# Variables
$Server = "epiqcorp.com:3268" #So it will search the entire forest
$Global:input =""
$Global:list = @() 


Function GetCreds {
    If ($UserCredentials.UserName -eq $null){
        $script:UserCredentials = Get-Credential
    }
}

Function Menu {
    param (
        [string]$Title = 'Select Menu'
    )
    cls
    Write-Host "================ $Title ================"
     
     Write-Host "1: Press '1' To Add Azure Sync Exception."
     Write-Host "2: Press '2' To Remove Azure Sync Exception."
     Write-Host "Q: Press 'Q' to quit."
}

# Gets List of Users to make changes to
Function GetUsers {
    $input
    Write-host "Enter Users to Adjust Azure Sync Value:" 
        do {
            $line = (Read-Host " ")
                if ($line -ne '') {
                    $list += $line
                }
        } until ($line -eq '')
        CheckUsers
}

# Checks that Contact Exists
Function CheckUsers {
    foreach ($Name in $list){
     
            Get-ADUser -Filter * -server $Server | ? {$_.SamAccountName -eq $Name} | Select Name, extensionAttribute10 }
            # if success then move on
            If ($input -eq '1') {
                AddAzureException
            }
            If ($input -eq '2') {
                RemoveAzureException 
            }
            Else {
            # Else someting went wrong with menu function
            }
        } catch {
            # if not success ask again or skip
            Write-Host "Something went Wrong" -ForegroundColor Red
        }
                
        
    }
}

Function AddAzureException {
    #Set ADObject for user, extensionAttribute10 to noMSAzureSync
    Set-AdObject -Identity $name -Add @{extensionAttribute10=noMSAzureSync} -Credential $UserCredentials
    Write-Host "Attribute SET to Disable Azure Sync for " $Name -ForeGroundColor Green
}

Function RemoveAzureException {
   # Set ADObject for user, Remove noMSAzureSync from extensionAttribute10
   Set-AdObject -Identity $name -Clear @{extensionAttribute10=noMSAzureSync} -Credential $UserCredentials
   Write-Host "Attribute REMOVED to Enable Azure Sync for " $Name -ForeGroundColor Green
}


# Script Main Body
#GetCreds
     Menu
     $input = Read-Host "Please make a selection"
     If ($input -eq '1'){
        GetUsers ($input)
    }

