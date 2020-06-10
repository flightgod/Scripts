add-PSSnapin quest.activeroles.admanagement -ErrorAction SilentlyContinue
$fulllist = "AMER.domain.COM","APAC.domain.COM","domain.LOCAL","domain.LOCAL","domain.LOCAL","domain.Local","domain.DMZ","domain.DMZ"
$Domains = $fulllist | Out-GridView -Passthru
$Search = Read-Host "Enter account name to search for"
$disabledaccounts = @()
$AdminName = (whoami).split("\.")[1]

Function Ask-YesOrNo
              {
              param([string]$title="",[string]$message="")
              $choiceYes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Answer Yes."
              $choiceNo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Answer No."
              $options = [System.Management.Automation.Host.ChoiceDescription[]]($choiceYes, $choiceNo)
              $result = $host.ui.PromptForChoice($title, $message, $options, 1)
              #$result = $host.ui.PromptForChoice($options, 1)
                             switch ($result) {
                             0
                             {Return $true}
                             1
                             {Return $false}
                             }
              }

foreach ($domain in $domains) {
#$AdminName = Read-Host "Enter your Admin AD username for $domain"
$password = Read-Host "Enter your $domain password:" -AsSecureString
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $domain\$AdminName,$password
sleep 2
Write-Host 'Connecting to Active Directory'
#Establishes connection to Active Directory and Exchange with the specified user acccount and password.
$domainmod = "$domain"+":389"
write-host $domainmod
Connect-QADService -Service $domainmod -Credential $Cred -ErrorAction Stop 
$matchingaccounts = $null
$matchingaccounts = Get-QADUser -SamAccountName *$Search*
foreach ($account in $matchingaccounts) {
$account | ft Samaccountname,CanonicalName,AccountIsDisabled -a 
if (!($account.AccountIsDisabled))
{
write-host "Account is not disabled, Do you want to disable now?"
If (Ask-YesOrNo) 
{
write-host "Re-setting Password:"
Set-ADAccountPassword -Identity $Search -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "1i7)7j6@=o(5)na%-0Spi*ax@))8nq" -Force)
write-host "Done Re-setting Password!"

write-host "Removing Group Membership:"
ForEach ($U in $Search)
    {   $UN = Get-ADUser $U -Properties MemberOf
        $Groups = ForEach ($Group in ($UN.MemberOf))
        {   (Get-ADGroup $Group).Name
        }
        $Groups = $Groups | Sort
        ForEach ($Group in $Groups)
        { 
		remove-adgroupmember -Identity $Group  -Member $U  -ErrorAction SilentlyContinue -Confirm:$false
		}
    }
write-host "Done Removing Group Membership!"


write-host "Disabling Account"
$account | Disable-QADUser
$disabledaccounts += $account.CanonicalName

}
}
}
Disconnect-QADService
}
Write-host "Accounts that were disabled, passwords changed, and Group Membership removed:"
$disabledaccounts 
