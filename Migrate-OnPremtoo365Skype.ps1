$target = "sipfed.online.lync.com"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"

$import = "C:\temp\MigrateSkypeo365.csv"
$data = Import-Csv $import

$ExchangeP2 = "UG-o365-License-Exchange-P2"
$SkypeP2 = "UG-o365-License-Skype-P2"
$SkypeAC = "UG-o365-License-Skype-AudioConf"
$Teams = "UG-o365-License-Teams"
$SharePointP2 = "UG-o365-License-SharePoint-P2"


$FailList = $NULL

Function Connect-Lync {
    $LyncServer = "https://lyncws.epiqsystems.com/OcsPowershell"
    If ($LyncSession.ComputerName -like "lyncws.epiqsystems*") {
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

Function Migrate-User {
    $Script:upn = $user.SAMAccountName+"@epiqsystems.com"
    Move-CsUser `
        -Identity $upn `
        -domainController $DomainController `
        -Target $target -Confirm:$false

}

Function Check-User {
    ForEach ($user in $data) {
        $name = $user.SAMAccountName
        If ($members -contains $name) {
            Write-Host "$name in group" -ForegroundColor Green
        
            Migrate-User

            Add-ADGroupMember -Identity $SkypeP2 -Members $name -Credential $LyncCredentials
            Add-ADGroupMember -Identity $SkypeAC -Members $name -Credential $LyncCredentials
            Add-ADGroupMember -Identity $Teams -Members $name -Credential $LyncCredentials
            Add-ADGroupMember -Identity $SharePointP2 -Members $name -Credential $LyncCredentials
        } Else {
            Write-Host "$name not in group" -ForegroundColor Red
            $FailList = @($FailList + $name)

            #Remove-ADGroupMember -Identity $ExchangeP1 -Members $name -Confirm:$false
            #Add-ADGroupMember -Identity $ExchangeP2 -Members $name -Credential $LyncCredentials
            #Add-ADGroupMember -Identity $SkypeP2 -Members $name -Credential $LyncCredentials
            #Add-ADGroupMember -Identity $SkypeAC -Members $name -Credential $LyncCredentials
            #Add-ADGroupMember -Identity $Teams -Members $name -Credential $LyncCredentials
        }
    }
}

Connect-Lync
$members = Get-ADGroupMember -Identity $ExchangeP2 -Recursive | Select -ExpandProperty SAMAccountName
Check-user