
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
    8. Manually Check how many Mailboxes and Skype created from Logs \\P054EXGRELY01\Logs (This is currently part of the Seperate Part2 Script)

#>

# Variables
param (
$Global:SingleGroup = "Epiq-All",
$Global:USGroup = "Epiq-All-US",
$OU = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=epiqcorp,DC=com",
$OUFull = "DC=amer,DC=epiqcorp,DC=com",
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM",
$ExchangeServer = "http://P054EXCTRNS01.amer.epiqcorp.com/PowerShell/",
$today = (Get-Date -Format MM/dd/yyyy),
$FileDate = (Get-Date -Format MM_dd_yyyy),
$ExportFile = "c:\temp\NewAccountAudit_" + $FileDate + ".txt",
$File = "c:\Temp\ZeroDLtoDelete_" + $FileDate + ".txt",
$count = "",
$Global:NoMailbox = @(),
$Global:USArray = @()
)

Function ExchangeConnect {
    If ($Session.ComputerName -like "P054EXCTRNS01.amer.epiqcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
      #  $script:UserCredential = Get-Credential
        $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos
        Import-PSSession $Session
    }
}

# Gets users that are disabled that are members of the Group listed and addes them to the $array
Function GetInfo {
$Global:NewGroup = Get-ADGroup "Epiq-All" -Properties Member -Server $DomainController | 
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

# This will check if the mailbox Exists
# YOU SHOULD PROBABLY RUN THIS MANUALLY AND TWEAK
Function CheckMBExists {
    Set-AdServerSettings -ViewEntireForest $true
    $Global:GroupMembers = Get-ADGroup "Epiq-All" -Properties Member -Server $DomainController | Select-Object -ExpandProperty Member
    Write-host "Got" $GroupMembers.Count "Members in group" $SingleGroup
    foreach ($user in $GroupMembers){
        try {
            $exist = Get-RemoteMailbox $user -ResultSize Unlimited -ReadFromDomainController
            if ($exist.IsValid -eq "true") {
                #Write-host “Mailbox Exists -" $user "and is valid" $exist.IsValid -foregroundcolor Green
            } Else {
                Write-host "Something is not right for" $user $exist.IsValid -ForegroundColor Red
                $Global:NoMailbox = $NoMailbox + $user
            }
        } catch {
            Write-Host "Cant find" $user
        }

    }
    $Global:NoMBResults = "Number of Users that didnt have Mailboxes: " + $NoMailbox.count
    
}

# Will remove users from the group that are in the $array value
Function RemoveFromEpiqAll {

If ($array.count -gt 0){
    Write-Host "Going to delete" $array.count "users from Group" $SingleGroup
        $Global:count = $array.count
        foreach ($BadUser in $array){
            $count
            Write-Host "Removing user " $BadUser "from" $SingleGroup -ForeGroundColor Green
            Remove-ADGroupMember -Identity $SingleGroup -Members $BadUser -Server $DomainController -Confirm:$False
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
        $Global:UScount = $USarray.count
        foreach ($USBadUser in $USarray){
            $UScount
            Write-Host "Removing user " $USBadUser "from Epiq-ALL-US" -ForeGroundColor Green
            Remove-ADGroupMember -Identity "Epiq-All-US" -Members $USBadUser -Server $DomainController -Confirm:$False
            $UScount=$UScount-1
        } 
    } Else {
        Write-Host "No users to delete - wooho"
    }
}

# Checks for Disabled Accounts in a specific OU
Function CheckforDisabledAccounts {
    $Global:GetList = Get-ADUser -Filter * -SearchBase $OU -Properties EmployeeID -Server amer.epiqcorp.com | `
    Where-Object {$_.Enabled -eq $false} | `
    Select-Object SAMAccountName, EmployeeID
    Write-Host "Users disabled in Standard OU:" $GetList.Count

}

# Checks for Disabled Accounts in AMER and returns total
Function CheckforALLDisabledAccounts {
    $Global:FullList = Get-ADUser -Filter * -SearchBase $OUFull -Properties EmployeeID -Server amer.epiqcorp.com | `
    Where-Object {$_.Enabled -eq $false} | `
    Select-Object SAMAccountName, EmployeeID
    Write-Host "Users disabled in AMER:" $FullList.Count

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

# Body text Function
Function BodyText {
    $USUsers = "Users in Epiq-All:" + $NewGroup.count
    $Variable1 = "Number of users to remove from" + $SingleGroup + ": " + $array.Count
    $Variable2 = "Users in Epiq-All-US Currently:" + $USCount.count
    $Variable3 = "Number of Users to remove from " + $USArray.count
    $Variable4 = "Users disabled in Standard OU:" + $GetList.Count
    $Variable5 = "Users disabled in AMER:" + $FullList.Count
    $Variable6 = "Searched a total of " + $dls.count + " Distros for Zero Members and found " + $BlankDL.count + " With no members"

$Global:Body = "
    $USUsers
    $array
    $Variable1
    $Variable2
    $Variable3
    $USArray
    $Variable4
    $Variable5
    $Variable6
    $NoMBResults
    $NoMailbox
"
}

# Sending Email Function
Function SendEmail{
$script:to = $NewEmail
$script:messageBody = $Body + "`r`n"
Send-MailMessage `
    -From "PowerShell Foo <PowershellFoo@epiqglobal.com>" `
    -To "kbennett@epiqglobal.com" `
    -BCC "o365 Questions <o365Questions@epiqglobal.com>" `
    -Subject "Audit Script - $today" `
    -Body $messageBody `
    -Attachment $File `
    -SmtpServer "mailrelay.amer.epiqcorp.com"

}

#Main Script
ExchangeConnect
$stopwatch = [Diagnostics.Stopwatch]::StartNew()
GetInfo #Function to get the Info

Write-Host "Script has taken" $stopwatch.Elapsed.Hours "hour(s)," $stopwatch.Elapsed.Minutes "Minutes and"$stopwatch.Elapsed.Seconds "Seconds to Run so far"
Write-host "Checking Epiq-All-US....."

GetUSInfo # Function to get info for Epiq-All-US

Write-Host "Script has taken" $stopwatch.Elapsed.Hours "hour(s)," $stopwatch.Elapsed.Minutes "Minutes and"$stopwatch.Elapsed.Seconds "Seconds to Run so far"
  
$USCount = Get-ADGroupMember "Epiq-All-US" -Server $DomainController

write-host "Users in Epiq-All:" $NewGroup.count
Write-Host "Number of users to remove from" $SingleGroup ": " $array.Count
$array

Write-host "Users in Epiq-All-US Currently:" $USCount.count
write-Host "Number of Users to remove from Epiq-All-US: " $USArray.count
$USArray

RemoveFromEpiqAll # Will remove users from Epiq-All
RemoveFromUS # Will remove users from Epiq-ALL-US

CheckforDisabledAccounts
CheckforALLDisabledAccounts
Write-Host "Script has taken" $stopwatch.Elapsed.Hours "hour(s)," $stopwatch.Elapsed.Minutes "Minutes and"$stopwatch.Elapsed.Seconds "Seconds to Run so far"
Write-Host "Getting list of DL's with Zero Members ....."

GetDLWZeroMem # Will check if there are Distribution Lists that have no Members
CheckMBExists # Checks that we can find mailboxes for all users in Epiq-All
$NoMBResults
BodyText
SendEmail


# Stops the stopwatch on Time it took the script to run
$stopwatch.stop()
Write-Host "Script took" $stopwatch.Elapsed.Hours "hour(s)," $stopwatch.Elapsed.Minutes "Minutes and"$stopwatch.Elapsed.Seconds "Seconds to Run"

Session-Disconnect

Remove-Item $File -Force