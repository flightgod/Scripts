$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"


Function ExchangeConnect 
{
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
    Write-Host "Session already established to exchange" -ForegroundColor Green
}
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $UserCredential = Get-Credential
        $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}


# Main Script Commands
ExchangeConnect


Function GetList {
    # Gets DL with Allow only internal
    $Distro = @()
    $Distro = Get-DistributionGroup -ResultSize Unlimited | Where {$_.RequireSenderAuthenticationEnabled -eq $true} | Select SamAccountName, AcceptMessagesOnlyFrom
    $Distro.Count 

    ForEach ($DL in $Distro){
          Set-DistributionGroup $Dl.SamAccountName -RequireSenderAuthenticationEnabled $False -Forceupgrade -bypassSecuritygroupManagerCheck
    }


    # Gets DL with only specific members can send to it
     Get-DistributionGroup -ResultSize Unlimited | Where {$_.AcceptMessagesOnlyFromSendersOrMembers -ne $null}


}