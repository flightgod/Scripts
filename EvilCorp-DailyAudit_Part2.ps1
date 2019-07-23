<#
This script should check the users that were created yesterday
Give me a count by License
Check if they have Employee ID
Check if they were added to EvilCorp-All Domain
Check if they were setup with Skype


#>


param (
$ImportFile = "\\P054EXGRELY01\Logs\NewMailUserLog.csv",
$SkypeImportFile = "\\P054EXGRELY01\Logs\NewSkypeUserLog.csv",
$group = "EvilCorp-All",
$today = (Get-Date -Format MM/dd/yyyy),
$FileDate = (Get-Date -Format MM_dd_yyyy),
$ExportFile = "c:\temp\NewAccountAudit_" + $FileDate + ".txt",
$NewUser = "",
$DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM"
)

# Function import list of users
Function ImportMailList {
    $test = Test-Path $ImportFile
    If ($test -eq $true) {
        $script:import = Import-csv $ImportFile
    }
    Else {
        Write-Warning "Something went Wrong: File is missing at $ImportFile"
        Break
    }
}

# Import Skype Log
# Function import list of users
Function ImportSkypeList {
    $TestExists = Test-Path $SkypeImportFile
    If ($TestExists -eq $true) {
        $script:SkypeImport = Import-csv $SkypeImportFile
    }
    Else {
        Write-Warning "Something went Wrong: File is missing at $SkypeImportFile"
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

# Checks if the user is a member of the EvilCorp-All Group
Function CheckGroupMember_EvilCorp-All {
$user = $gotUserINfo.Name
If ($members -contains $gotUserINfo.DistinguishedName) {
      "$user exists in the EvilCorp-All" | Out-file -FilePath $ExportFile -Append
 } Else {
       "$user not exists in the EvilCorp-All" | Out-file -FilePath $ExportFile -Append
}

}

# checks the users were added with thier values
Function CheckUsers {
    $Global:todaysSkypeCount = $Skypeimport | where {$_.date -eq $yesterday}
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
        CheckGroupMember_EvilCorp-All
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
    $Global:Variable1 = "Total of " + $todaysCount.Count + " Mailbox Users Added (Yesterday)"
    $Global:variable2 = "Total of " + $todaysSkypeCount.Count + " Skype Users Setup (Yesterday)"
    $Global:Variable7 = "---------------------------------------------------------------------"

$Script:Body = "
    Summary
    $Variable7
    $Variable1
    $variable2
    $Variable7
"
}

# Sending Email Function
Function SendEmail{
$script:to = $NewEmail
$script:messageBody = $Body + "`r`n"
Send-MailMessage `
    -From "PowerShell Foo <PowershellFoo@EvilCorpglobal.com>" `
    -To "kbennett@EvilCorpglobal.com" `
    -BCC "o365 Questions <o365Questions@EvilCorpglobal.com>" `
    -Subject "Mailbox Audit $today" `
    -Body $messageBody `
    -SmtpServer "mailrelay.amer.EvilCorpcorp.com" `
    -Attachment $ExportFile

}
# Main Script Body - I should clean this up
ImportMailList # Gets Log of Added Mailboxes
ImportSkypeList # gets log of All Skype adds

#$Global:members = Get-ADGroupMember -Identity $group -Recursive | Select -ExpandProperty Name
$Global:members = Get-ADGroup -Identity $group -Properties Member -Server $DomainController | Select-Object -ExpandProperty Member

GetMonday #Checks if it is Monday

New-Item -Path $ExportFile -ItemType file

CheckUsers #Check the users from the Import

BodyText

SendEmail

#Display what is saved 
Get-Content $ExportFile
$Variable7
""
"Summary"
$Variable1
$Variable2

Remove-Item $ExportFile -Force
