<#  
.SYNOPSIS
   	Script to get values of a distro List

.DESCRIPTION  
    This script gets the "RequreSenderAuthenticationEnabled" Value and the AcceptMessages Only from Senders or Members. If any are present
    it will reset. This should be setup to run weekly/Daily to keep SD from creating restrictive DL's that DTI cant access.

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/19/2017 - First iteration - kbennett 

        
    Rights Required		    : Exchange Permissions 
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Error Checking
                            : Notification or some Sort i guess

.FUNCTIONALITY
    Read / Write Values in a DL Object
#>

# Variables
# Calls my connect function with all the current connection strings in it
.".\Function-Connect.ps1"



# Gets DL with Allow only internal
Function GetListLimited {
    Write-Host "Checking for Groups that are set to only accept email from internal users"
    $Script:Distro = @()
    $Distro = Get-DistributionGroup -ResultSize Unlimited | Where {$_.RequireSenderAuthenticationEnabled -eq $true} | Select SamAccountName, AcceptMessagesOnlyFrom
    If ($Distro -eq $NULL){
        Write-Host "No Groups Found"
    } 
    Else {
        Write-host "Found:"
        $Distro
        SetListLimitedOff
    }
}

# Sets DL with Allow Only Internal On to Off
Function SetListLimitedOff {
    ForEach ($DL in $Distro){
        Write-host "Setting Value to False on the above DL's - " $DL
        Set-DistributionGroup $Dl.SamAccountName -RequireSenderAuthenticationEnabled $False -Forceupgrade -bypassSecuritygroupManagerCheck
    }
}

# Gets DL with only specific members can send to it
Function GetListMembers {
    write-host "Checking for Groups that only allow specific members to send to it"
    $PermittedToSend = Get-DistributionGroup -ResultSize Unlimited | Where {$_.AcceptMessagesOnlyFromSendersOrMembers -ne $null}
    $PermittedToSend.count
    $PermittedToSend
}

# Main Script Commands
Connect-Exchange # calls from the .function-connect.ps1
GetListLimited
SetListLimitedOff
GetListMembers

#Create function that hides all the Eagle All Groups and Epip-all (2) and DTIEpiqAllEmployees
#Create Function that sets these above to Auth users only

Function UpdateDlLimitedUser {
$groups = Get-DistributionGroup DTIEpiqAllEmployees| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
$kcgroups = $groups + "HRAnnouncement"
Get-DistributionGroup Epiq-All-Contractors| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
Get-DistributionGroup Epiq-All| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
Get-DistributionGroup EagleAllGroup| %{$_.AcceptMessagesOnlyFromSendersOrMembers}


Set-DistributionGroup Epiq-All-Contractors -AcceptMessagesOnlyFromSendersOrMembers $kcgroups
Set-DistributionGroup Epiq-All -AcceptMessagesOnlyFromSendersOrMembers $kcgroups
Set-DistributionGroup EagleAllGroup -AcceptMessagesOnlyFromSendersOrMembers $Groups
}

