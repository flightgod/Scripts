$ScriptFromGithHub = Invoke-WebRequest https://raw.githubusercontent.com/flightgod/test/master/Get-SfBClientVersion.ps1

Invoke-Expression $($ScriptFromGithHub.Content)