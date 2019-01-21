$userCredential=Get-Credential
$Session=New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $userCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

New-ComplianceSearchAction -SearchName "kbennett 1_3-2" -Purge -PurgeType SoftDelete

Get-ComplianceSearchAction
