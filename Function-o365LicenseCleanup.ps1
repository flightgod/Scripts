Function Connect-o365 {
    $O365URI = "https://outlook.office365.com/powershell-liveid/"
    If ($Session.ComputerName -like "outlook.office365.com") {
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $script:o365Credential = Get-Credential
        Import-Module MSOnline
        Connect-MsolService -Credential $o365Credential
        $o365Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $O365URI `
        -Authentication Basic `
        -AllowRedirection `
        -Credential $o365Credential
        Import-PSSession $o365Session
    }
}

Function Import-CSV {
    $import = "C:\temp\onPrem.csv"
    $data = Import-Csv $import
}


$WithSkype = @()
ForEach ($1 in $data){
   $WithSkype += Get-MsolUser -UserPrincipalName $1.UserPrincipalName | Where {$_.MSRtcSipPrimaryUserAddress -eq $NULL} 

}

ForEach ($1 in $data){
    $Users = Get-MsolUser -UserPrincipalName $1.UserPrincipalName | Where {$_.BlockedCredential -eq "False"} 
}

ForEach ($user in $users){
    Get-Mailbox $user.DisplayName | Where {$_.ArchiveStatus -eq "Active"} | Get-MailboxStatistics | Select DisplayName, TotalItemSize
    }


$Enabledusers = @()
$failed = @()
ForEach ($user in $data){
    Try {
    $Enabledusers += Get-ADUser $user.alias -Properties UserPrincipalName, msRTCSIP-PrimaryUserAddress, SamAccountName | Where {$_.Enabled -eq $true} | Select UserPrincipalName, msRTCSIP-PrimaryUserAddress, SamAccountName
    } catch {
    $failed += $user.alias
    }
}

$EnabledUsers | export-csv c:\temp\OnPremToMigrateSIP.csv -notypeinformation


<# 

run.csv has all users with P2 that dont have skype so "could" be moved to p1 478

Get mailbox need ArchiveStatus = True
Get MailboxStatistics Need TotalItemSize above 50 GB
get msoluser with Licenses




Get-MsolAccountSku


AccountSkuId                           ActiveUnits WarningUnits ConsumedUnits
------------                           ----------- ------------ -------------
EvilCorpsystems3:VISIOCLIENT               1           0            0            
EvilCorpsystems3:STREAM                    1000000     0            4            
EvilCorpsystems3:ENTERPRISEPREMIUM         75          0            10           
EvilCorpsystems3:SPZA_IW                   10000       0            0            
EvilCorpsystems3:ENTERPRISEPACK            0           2100         1            
EvilCorpsystems3:FLOW_FREE                 10000       0            38           
EvilCorpsystems3:MICROSOFT_BUSINESS_CENTER 10000       0            3            
EvilCorpsystems3:POWERAPPS_VIRAL           10000       0            3            
EvilCorpsystems3:EXCHANGESTANDARD          3420        0            3381         
EvilCorpsystems3:DYN365_ENTERPRISE_P1_IW   10000       0            2            
EvilCorpsystems3:POWER_BI_STANDARD         1000000     0            35           
EvilCorpsystems3:EMS                       0           2100         0            
EvilCorpsystems3:MCOIMP                    3850        0            1594         
EvilCorpsystems3:AX7_USER_TRIAL            10000       0            0            
EvilCorpsystems3:SHAREPOINTSTANDARD        3850        0            188          
EvilCorpsystems3:PROJECTPROFESSIONAL       1           0            0            
EvilCorpsystems3:EXCHANGEENTERPRISE        3850        0            3662         
EvilCorpsystems3:MCOSTANDARD               50          0            9            
EvilCorpsystems3:STANDARDPACK              0           800          0 





#>
