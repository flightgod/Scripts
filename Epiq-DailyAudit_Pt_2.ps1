<#
This script should check the users that were created yesterday
Give me a count by License
Check if they have Employee ID
Check if they were added to Epiq-All Domain
Check if they were setup with Skype


#>


param (
$ImportFile = "\\P054EXGRELY01\Logs\NewMailUserLog.csv",
$group = "Epiq-All",
$today = (Get-Date -Format MM/dd/yyyy),
$FileDate = (Get-Date -Format MM_dd_yyyy),
$ExportFile = "c:\temp\NewAccountAudit_" + $FileDate + ".txt",
$NewUser = "",
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
)

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

#Checks if Monday, If so it goes back to get all users added Friday
Function GetMonday {
    $DayOfTheWeek = ( get-date ).DayOfWeek.value__
    
    IF ($DayOfTheWeek -eq "1") {
        "Its Monday"
        $Global:Yesterday = (get-date (get-date).addDays(-3) -Format MM/dd/yyyy)
    } Else {
        "Not Monday"
        $Global:Yesterday = (get-date (get-date).addDays(-1) -Format MM/dd/yyyy)
    }
        


}

# Checks if the user is a member of the Epiq-All Group
Function CheckGroupMember_Epiq-All {
$user = $gotUserINfo.Name
If ($members -contains $gotUserINfo.DistinguishedName) {
      "$user exists in the Epiq-All" | Out-file -FilePath $ExportFile -Append
 } Else {
       "$user not exists in the Epiq-All" | Out-file -FilePath $ExportFile -Append
}

}

# checks the users were added with thier values
Function CheckUsers {
    $GLobal:todaysCount = $import | where {$_.date -eq $yesterday}

    ForEach ($NewUser in $todaysCount) {
        $Script:gotUserINfo = Get-ADUser $NewUser.Name -Server $NewUser.DomainController -Properties * | `
            Select `
                Name, `
                msRTCSIP-UserEnabled, `
                EmployeeID, `
                UserPrincipalName, `
                CanonicalName, `
                MemberOf, `
                Department, `
                DistinguishedName
        CheckGroupMember_Epiq-All
        $gotUserInfo.Name + " has a license for " + $NewUser.ExchangeLicense | Out-file -FilePath $ExportFile -Append
        "Skype Enabled:" + $gotUserInfo.'msRTCSIP-UserEnabled' | Out-file -FilePath $ExportFile -Append
        "UPN: " + $gotUserInfo.UserPrincipalName | Out-file -FilePath $ExportFile -Append
        "Location: " + $gotUserInfo.CanonicalName | Out-file -FilePath $ExportFile -Append 
        "Created by: " + $NewUser.ward + " On: " + $NewUser.Date | Out-file -FilePath $ExportFile -Append
        "Employee ID: " + $gotUserInfo.EmployeeID | Out-file -FilePath $ExportFile -Append
        "---------------------------------------------------------------------" | Out-file -FilePath $ExportFile -Append
    }
}

# Body text Function
Function BodyText {
    $Variable1 = "Total of " + $todaysCount.Count + " Users Added (Yesterday)"
    $Variable7 = "---------------------------------------------------------------------"

$Script:Body = "
    $Variable1
    $Variable7
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
    -Subject "Mailbox Audit $today" `
    -Body $messageBody `
    -SmtpServer "mailrelay.amer.epiqcorp.com" `
    -Attachment $ExportFile

}
# Main Script Body - I should clean this up
ImportList # Gets Log of Added Mailboxes

#$Global:members = Get-ADGroupMember -Identity $group -Recursive | Select -ExpandProperty Name
$Global:members = Get-ADGroup -Identity $group -Properties Member -Server $DomainController | Select-Object -ExpandProperty Member

GetMonday #Checks if it is Monday

CheckUsers #Check the users from the Import

BodyText

SendEmail

#Display what is saved 
Get-Content $ExportFile
"Total of " + $todaysCount.Count + " Users Added (Yesterday)"

Remove-Item $ExportFile -Force