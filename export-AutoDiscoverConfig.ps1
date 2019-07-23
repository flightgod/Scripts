$a = Get-Credential
$target = "ATL-I-ROOTDC-01.dtiglobal.com"
$source = "P054ADSEQDC01.EvilCorpcorp.com"
Export-AutoDiscoverConfig -DomainController $source `
-TargetForestDomainController $target `
-TargetForestCredential $a `
-MultipleExchangeDeployments $true -WhatIf
