# PSFindLockedOutUsers.ps1
# PowerShell script to find locked out users.
#
# ----------------------------------------------------------------------
# Copyright (c) 2011 Richard L. Mueller
# Hilltop Lab web site - http://www.rlmueller.net
# Version 1.0 - March 24, 2011
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the copyright owner above has no warranty, obligations,
# or liability for such use.

Trap {"Error: $_"; Break;}

# Retrieve domain lockout duration policy.
$D = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$Domain = [ADSI]"LDAP://$D"
$LOD = $Domain.lockoutDuration.Value
# Convert to Int64 ticks (100-nanosecond intervals).
$lngDuration = $Domain.ConvertLargeIntegerToInt64($LOD)

# Determine critical time in the past. Any accounts locked out
# after this time will still be locked out, unless the account
# has been reset (in which case the value of the lockoutTime
# attribute will be 0). Any accounts locked out before this
# time will no longer be locked out.
If (-$lngDuration -gt [DateTime]::MaxValue.Ticks)
{
    # If lockoutDuration is -1 (2^63-1) there is no domain
    #lockout duration policy. Locked out accounts remain locked
    # out until reset. Any user with lockoutTime greater than 0
    # is locked out.
    $LockoutTime = 1
}
Else
{
    $Now = Get-Date
    $NowUtc = $Now.ToFileTimeUtc()
    $LockoutTime = $NowUtc + $lngDuration
}

$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.PageSize = 200
$Searcher.SearchScope = "subtree"

$Searcher.Filter = "(&(objectCategory=person)(objectClass=user)" `
    + "(lockoutTime>=" + $LockoutTime + "))"
$Searcher.PropertiesToLoad.Add("distinguishedName") > $Null
$Searcher.SearchRoot = "LDAP://" + $Domain.distinguishedName

$Results = $Searcher.FindAll()
"Locked out users:"
ForEach ($Result In $Results)
{
    $DN = $Result.Properties.Item("distinguishedName")
    $DN
}
