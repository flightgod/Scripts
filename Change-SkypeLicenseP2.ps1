$ExchangeP1 = "UG-o365-License-Exchange-P1"
$ExchangeP2 = "UG-o365-License-Exchange-P2"
$SkypeP2 = "UG-o365-License-Skype-P2"
$SkypeP1 = "UG-o365-License-Skype-P1"
$SkypeAC = "UG-o365-License-Skype-AudioConf"
$Teams = "UG-o365-License-Teams"
$SharePointP2 = "UG-o365-License-SharePoint-P2"
$SharePointP1 = "UG-o365-License-SharePoint-P1"
$target = "sipfed.online.lync.com"
$DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM"
$UKDomainController = "P016ADSEUDC01.EURO.EvilCorpCORP.COM"
$HKDomainController = "ET016-EQAPDC03.apac.EvilCorpcorp.com"
$FailList = $NULL


Function Connect-Lync {
    $LyncServer = "https://lyncws.EvilCorpsystems.com/OcsPowershell"
    If ($LyncSession.ComputerName -like "lyncws.EvilCorpsystems*") {
        Write-Host "Session already established to Lync" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to Lync, creating session now" -ForegroundColor Red
        $script:LyncCredentials = Get-Credential
        $script:LyncSession = New-PSSession `
        -ConnectionUri $LyncServer `
        -Credential $LyncCredentials 
        Import-PSSession -Session $LyncSession -AllowClobber
    }

}

Function ImportTheData {
    $Script:import = "C:\temp\FinalMigration2.csv"
    $Script:data = Import-Csv $import
}

Function Check-Members {
    $script:members = Get-ADGroupMember -Identity $ExchangeP2 -Recursive | Select -ExpandProperty SAMAccountName
}

Function Check-And-Change-License {
    ForEach ($user in $data) {
        $name = $user.SAMAccountName
        If ($members -contains $name) {
            Write-Host "$name in group" -ForegroundColor Green
        
            #Add-ADGroupMember -Identity $SkypeP2 -Members $name -Credential $Ward
            #Add-ADGroupMember -Identity $SkypeAC -Members $name -Credential $Ward
            #Add-ADGroupMember -Identity $Teams -Members $name -Credential $Ward
            #Add-ADGroupMember -Identity $SharePointP2 -Members $name -Credential $Ward
        } Else {
            Write-Host "$name not in group" -ForegroundColor Red
            $FailList = @($FailList + $name)
            # Remove-ADGroupMember -Identity $ExchangeP1 -Members $name -Confirm:$false
            #Add-ADGroupMember -Identity $ExchangeP2 -Members $name -Credential $Ward
            #Add-ADGroupMember -Identity $SkypeP2 -Members $name -Credential $Ward
            #Add-ADGroupMember -Identity $SkypeAC -Members $name -Credential $Ward
            #Add-ADGroupMember -Identity $Teams -Members $name -Credential $Ward
        }
    }
}

Function Check-Enabled {
    ForEach ($user in $data){
        Get-Aduser $user.UserName -Server apac.EvilCorpcorp.com | Select SamAccountName,Enabled | Export-csv c:\temp\run.csv -NoTypeInformation -Append -Force
    }
}

Function MigrateUser {
    ForEach ($user in $data) {
        $Script:dn = Get-ADUser $User.SamAccountName -Server $UKDomainController #Change DC to Domain if UK/HK
        $account = $dn.SamAccountName + "@EvilCorpsystems.com" #Change address to the .co.uk or .hk
        Move-CSuser -Identity $account -DomainController $HKDomainController -Target $target -Confirm:$false #Change DC to Domain if UK/HK
        Remove-ADGroupMember -Identity $ExchangeP1 -Members $user.SamAccountName -Confirm:$false
        Remove-ADGroupMember -Identity $SkypeP1 -Members $user.SamAccountName -Confirm:$false
        Remove-ADGroupMember -Identity $SharePointP1 -Members $user.SamAccountName -Confirm:$false
        Add-ADGroupMember -Identity $ExchangeP2 -Members $dn -Credential $LyncCredentials -Server $DomainController
        Add-ADGroupMember -Identity $Teams -Members $dn -Credential $LyncCredentials -Server $DomainController
        Add-ADGroupMember -Identity $SkypeP2 -Members $dn -Credential $LyncCredentials -Server $DomainController
        Add-ADGroupMember -Identity $SkypeAC -Members $dn -Credential $LyncCredentials -Server $DomainController
        Add-ADGroupMember -Identity $SharePointP2 -Members $dn -Credential $LyncCredentials -Server $DomainController
        $dn.UserPrincipalName
        #$Script:DoneList = @($DoneList + $dn)
    }
}

Connect-Lync
ImportTheData
#MigrateUser

Function Verify {

    ForEach ($user in $Data){
        $Verified = Get-AdUser $user.SamAccountName -Server $DomainController -Properties SamAccountname, msRTCSIP-DeploymentLocator
        $FullList = @($FullList + $Verified)
    }

}

# also need to migrate the Teams users to skype o365, and assign Skype License (teams license already assigned) So just remove the Add ADGroup for the other licneses

# to verify: Read the list of all users, Filter out Enabled. Then Check if in Conf Group, If so Check Lync Location, if not Record
