
<#  
.SYNOPSIS
   	Daily run of tasks

.DESCRIPTION  
    Daily run of tasks to check that others are doing their jobs

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 3/07/2019 - First iteration - kbennett 
        
    Rights Required		    : Permissions to Add/Edit Objects in AD
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Reporting
                            : More Automation


             
.FUNCTIONALITY
    This is going to turn into my daily Audit Script
    1. Check if there are disabled users in the Epiq-All, and Epiq-All-US DL
    2. Check How many users are in each DL to report
    3. Check how many users are in the Standard OU but disabled
    4. Check the total number of disabled users in AMER
    5. Check which DL's have no members
    6. Check if mailbox Exists
    7. Removes users from the Epiq-All and Epiq-All-US Groups
    8. Manually Check how many Mailboxes and Skype created from Logs \\P054EXGRELY01\Logs

#>

# Variables
param (
$SingleGroup = "Epiq-All",
$USGroup = "Epiq-All-US",
$GroupArray = @("Epiq-All-US","EpiqAll"),
$OU = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=epiqcorp,DC=com",
$OUFull = "DC=amer,DC=epiqcorp,DC=com",
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM",
$ExchangeServer = "http://P054EXCTRNS01.amer.epiqcorp.com/PowerShell/",
$File = "c:\Temp\ZeroDLtoDelete.txt",
$BlankDL = @(),
$count = ""
)

Function ExchangeConnect {
    If ($Session.ComputerName -like "P054EXCTRNS01.amer.epiqcorp.com"){
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

# Gets users that are disabled that are members of the Group listed and addes them to the $array
Function GetInfo {
$NewGroup = Get-ADGroup "Epiq-All" -Properties Member -Server $DomainController | 
Select-Object -ExpandProperty Member
$NewGroup.Count

foreach($user in $NewGroup) {
    try {
        $s1 = get-ADUser $user -Server $DomainController
        If($s1.Enabled -eq $False) {
            $Global:array += $s1.SamAccountName
            Write-Host $s1.SamAccountName " - Disabled, should remove from" $SingleGroup -ForegroundColor Red 
            #Remove-ADGroupMember -Identity $SingleGroup -Members $S1.SamAccountName -Server $DomainController -Confirm:$False
            write-host $array.count
        }
    } catch {
        Write-host $user "- Not found in Amer, checking Euro" -ForegroundColor Yellow
        try {
            $s2 = get-ADUser $user -Server euro.epiqcorp.com
            If($s2.Enabled -eq $false) {
                Write-Host $user.SamAccountName " -Disabled, should remove from" $SingleGroup -ForegroundColor Red
                $Global:array += $s2.SamAccountName
                #Remove-ADGroupMember -Identity $SingleGroup -Members $S1.SamAccountName -Server euro.epiqcorp.com -Confirm:$False
                write-host $array.count
            }
        } catch {
            write-host $user " - Not found in Euro, checking APAC" -ForegroundColor DarkYellow
            try {
                $s3 = get-ADUser $user -Server apac.epiqcorp.com
                If($s3.Enabled -eq $false) {
                    Write-Host $user.SamAccountName " - Disabled, should remove from" $SingleGroup -ForegroundColor Red
                    $Global:array += $s3.SamAccountName
                    #Remove-ADGroupMember -Identity $SingleGroup -Members $S1.SamAccountName -Server apac.epiqcorp.com -Confirm:$False
                    write-host $array.count
                } 
             } catch {
                write-host $user " - Not able to find"   
             }
        }
    }
}

}

# Gets users that are disabled that are members of Epiq-ALL-US
Function GetUSInfo {
    Get-ADGroupMember $USGroup -Server $DomainController | foreach {
        $a = $_.SamAccountName
        $b1 = get-ADUser $_.SamAccountName -Server $DomainController
        If($b1.Enabled -eq $False) {
            $Global:USarray += $a
            Write-Host $a " - Disabled, should remove from" $USGroup "-" $USarray.count -ForegroundColor Red 
        }
    }
}

# ###### Need to fix this one and Re-Run with Report ##############
# This will check if the mailbox Exists
Function CheckMBExists {
    Set-AdServerSettings -ViewEntireForest $true
    $GroupMembers = Get-ADGroupMember $SingleGroup -Server $DomainController
    Write-host "Got" $GroupMembers.Count "Members in group" $SingleGroup
    foreach ($user in $GroupMembers){
        try {
            $exist = Get-RemoteMailbox $user.name -ResultSize Unlimited -ReadFromDomainController
            if ($exist.IsValid -eq "true") {
                Write-host “Mailbox Exists -" $user.SamAccountName "and is valid" $exist.IsValid -foregroundcolor Green
            } Else {
                Write-host "Something is not right for" $user.SamAccountName $exist.IsValid -ForegroundColor Red
            }
        } catch {
            Write-Host "Cant find" $user.name
        }

    }
}

# Will remove users from the group that are in the $array value
Function RemoveFromEpiqAll {

If ($array.count -gt 0){
    Write-Host "Going to delete" $array.count "users from Group" $SingleGroup
        $count = $array.count
        foreach ($BadUser in $array){
            $count
            Write-Host "Removing user " $BadUser "from" $SingleGroup -ForeGroundColor Green
            Remove-ADGroupMember -Identity $SingleGroup -Members $BadUser -Server $DomainController -credential $UserCredential -Confirm:$False
            $count=$count-1
        } 
    } Else {
        Write-Host "No users to delete - wooho"
    }
}

# Will remove users from the group that are in the $array value
Function RemoveFromUS {

If ($USarray.count -gt 0){
    Write-Host "Going to delete" $USarray.count "users from Group Epiq-All-US"
        $UScount = $USarray.count
        foreach ($USBadUser in $USarray){
            $UScount
            Write-Host "Removing user " $USBadUser "from Epiq-ALL-US" -ForeGroundColor Green
            Remove-ADGroupMember -Identity "Epiq-All-US"p -Members $USBadUser -Server $DomainController -credential $UserCredential -Confirm:$False
            $UScount=$UScount-1
        } 
    } Else {
        Write-Host "No users to delete - wooho"
    }
}

# Checks for Disabled Accounts in a specific OU
Function CheckforDisabledAccounts {
    $GetList = Get-ADUser -Filter * -SearchBase $OU -Properties EmployeeID | `
    Where-Object {$_.Enabled -eq $false} | `
    Select-Object SAMAccountName, EmployeeID
    Write-Host "Users disabled in Standard OU:" $GetList.Count

}

# Checks for Disabled Accounts in AMER and returns total
Function CheckforALLDisabledAccounts {
    $FullList = Get-ADUser -Filter * -SearchBase $OUFull -Properties EmployeeID | `
    Where-Object {$_.Enabled -eq $false} | `
    Select-Object SAMAccountName, EmployeeID
    Write-Host "Users disabled in AMER:" $FullList.Count

}

# Function to Save files to temp
Function SaveFiles {
    $array > C:\temp\DisabledtoRemove_Epiq-All_US_3_7.txt
}

# Function to get list of DL's with no members
Function GetDLWZeroMem {
    Write-Host "Getting List of DL's with no members, This could take awhile" -ForeGroundColor Green
    $Global:dls = get-distributiongroup -resultsize unlimited
    $Global:BlankDL = $dls.name |? {!(get-distributiongroupmember $_)}
    Write-Host "Searched a total of "$dls.count " Distros for Zero Members and found " $BlankDL.count " With no members" -ForegroundColor Yellow
    $BlankDL > $File 
}

# All good programmers close thier connections when done
Function Session-Disconnect {
    # Disconnects Session 
    $s = Get-PSSession
    $s
    Remove-PSSession -Session $s
}

#Main Script
ExchangeConnect
$stopwatch = [Diagnostics.Stopwatch]::StartNew()
$array = @()
$USArray = @()
GetInfo #Function to get the Info

Write-Host "Script has taken" $stopwatch.Elapsed.Hours "hour(s)," $stopwatch.Elapsed.Minutes "Minutes and"$stopwatch.Elapsed.Seconds "Seconds to Run so far"
Write-host "Checking Epiq-All-US....."

GetUSInfo # Function to get info for Epiq-All-US

Write-Host "Script has taken" $stopwatch.Elapsed.Hours "hour(s)," $stopwatch.Elapsed.Minutes "Minutes and"$stopwatch.Elapsed.Seconds "Seconds to Run so far"

$USCount = Get-ADGroupMember "Epiq-All-US" -Server $DomainController

write-host "Users in Epiq-All:" $AllCount.count
Write-Host "Number of users to remove from" $SingleGroup ": " $array.Count
$array

Write-host "Users in Epiq-All-US Currently:" $USCount.count
write-Host "Number of Users to remove from " $USArray.count
$USArray

RemoveFromEpiqAll # Will remove users from Epiq-All
RemoveFromUS # Will remove users from Epiq-ALL-US

CheckforDisabledAccounts
CheckforALLDisabledAccounts
Write-Host "Script has taken" $stopwatch.Elapsed.Hours "hour(s)," $stopwatch.Elapsed.Minutes "Minutes and"$stopwatch.Elapsed.Seconds "Seconds to Run so far"
Write-Host "Getting list of DL's with Zero Members ....."

GetDLWZeroMem # Will check if there are Distribution Lists that have no Members

<# We should enable this and test to make sure that users in the Groups actually have mailboxes
# Connect-o365
# CheckMBExists
#>


# Stops the stopwatch on Time it took the script to run
$stopwatch.stop()
Write-Host "Script took" $stopwatch.Elapsed.Hours "hour(s)," $stopwatch.Elapsed.Minutes "Minutes and"$stopwatch.Elapsed.Seconds "Seconds to Run"

Session-Disconnect


