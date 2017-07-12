Function Connect-o365 {
    $o365Credential = Get-Credential
    Import-Module MSOnline
    Connect-MsolService -Credential $o365Credential
    $o365Session = New-PSSession `
    -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://ps.outlook.com/PowerShell-LiveID?PSVersion=4.0 `
    -Authentication Basic `
    -AllowRedirection `
    -Credential $o365Credential
    Import-PSSession $o365Session

}

Function NewRule {
New-TransportRule `
    -Name "Visual Cue - External to Organization" `
    -Priority 0 `
    -FromScope "NotInOrganization" `
    -ApplyHtmlDisclaimerLocation "Prepend" `
    -ApplyHtmlDisclaimerText "<div style=""background-color:#FFEB9C; width:100%; border-style: solid; border-color:#9C6500; border-width:1pt; padding:2pt; font-size:10pt; line-height:12pt; font-family:'Calibri'; color:Black; text-align: left;""><span style=""color:#9C6500; font-weight:bold;"">CAUTION:</span> This email originated from outside of the organization.  Do not click links or open attachments unless you recognize the sender and know the content is safe.</div><br>" `
    -ExceptIfSenderDomainIS "dtiglobal.com","fiosinc.com","epiqsystems.com","epiqsystems.com.hk","epiqsystems.co.hk","irisds.com","hilsoft.com"


    #-FromScope "NotInOrganization" `
    #-ExceptIfSenderDomainIS "dtiglobal.com","fiosinc.com","epiqsystems.com","epiqsystems.com.hk","epiqsystems.co.hk","irisds.com","hilsoft.com"
}

    Function GetRule {
        Get-TransportRule -Identity "Visual Cue - External to Organization"
    }

    Function SetRule {
       Set-TransportRule -Identity "Visual Cue - External to Organization" -ExceptIfFrom "*@gmail.com"
    }