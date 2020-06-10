Import-Module SkypeOnlineConnector
$userCredential = Get-Credential
$sfbSession = New-CsOnlineSession -Credential $userCredential
Import-PSSession $sfbSession


Import-Module SkypeOnlineConnector
$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession


Get-CsOnlineUser user@domain.com


Grant-CSDialOutPolicy -Identity "kbennett@domain.com" -PolicyName "DialoutCPCandPSTNInternational"

Get-CsOnlineUser | Where {$_.HostingProvider -like "*sipfed.online.lync.com"} | Select UserPrincipalName, HostingProvider,OnlineDialOutPolicy | Grant-CsDialoutPolicy -PolicyName "DialoutCPCandPSTNInternational" 

Get-CsOnlineUser | Grant-CsDialoutPolicy -PolicyName "DialoutCPCandPSTNInternational" 



Get-CsOnlineUser | Where {$_.HostingProvider -like "*sipfed.online.lync.com"} | Select UserPrincipalName, HostingProvider,TeamsMeetingPolicy

Get-CsOnlineUser | Where {$_.TeamsMeetingPolicy -like "*AllOff"} | Select UserPrincipalName, HostingProvider,TeamsMeetingPolicy


Grant-CsTeamsMeetingPolicy -Identity user@domain.com -PolicyName $Null


Function ImportTheData {
    $Script:import = "C:\temp\skypeforbusinessplan1.csv"
    $Script:data = Import-Csv $import
}


ForEach ($user in $data){
    $name = $user.UserPrincipalName
    Get-CsOnlineUser -Identity $name | Where {$_.HostingProvider -notlike "*sipfed.online.lync.com"} | Select UserPrincipalName, HostingProvider
}

Set-CsOnlineDialinConferencingUser -Identity user@domain.com -TollFreeServiceNumber   8008675309



Function add-Policy {

    ForEach ($user in $data){
        Grant-CsTeamsMeetingPolicy -Identity czwirn -PolicyName $Null

    }

}


get-mailbox -RecipientTypeDetails UserMailbox | Where-Object {$_.skuassigned -eq $true} | Get-MailboxStatistics | Where-Object {$_.LastLogonTime -eq $null} |Select DisplayName, LastLogonTime, WhenCreated | fl > c:\Temp\Notloggedin.csv

get-mailbox -RecipientTypeDetails UserMailbox | Where-Object {$_.skuassigned -eq $true} | Get-MailboxStatistics | Where-Object {$_.LastLogonTime -lt 05/30/2018} | Select DisplayName, LastLogonTime, WhenCreated | fl
