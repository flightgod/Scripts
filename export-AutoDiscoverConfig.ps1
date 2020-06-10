$a = Get-Credential
$target = "servername"
$source = "P054ADSEQDC01.EvilCorpcorp.com"
Export-AutoDiscoverConfig -DomainController $source `
-TargetForestDomainController $target `
-TargetForestCredential $a `
-MultipleExchangeDeployments $true -WhatIf
