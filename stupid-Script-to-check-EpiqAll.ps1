$SingleGroup = "Epiq-All"
$array = @()
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$testbefore = Get-ADGroupMember $SingleGroup -Server $DomainController
$stopwatch = [Diagnostics.Stopwatch]::StartNew()


Get-ADGroupMember $SingleGroup -Server $DomainController | foreach {
    try {

        $script:u = $_.SamAccountName
        $s1 = get-ADUser $_.SamAccountName -Server $DomainController
        If($s1.Enabled -eq $False) {
            Write-Host $u " - Disabled, should remove here" -ForegroundColor Red
            $array += $u
        }
    } catch {
        Write-host $u "- Not found in Amer, checking Euro" -ForegroundColor Yellow
        try {
            $s2 = get-ADUser $u -Server euro.epiqcorp.com
            If($s2.Enabled -eq $false) {
                Write-Host $u " -Disabled, should remove here" -ForegroundColor Red
                $array += $u
            }
        } catch {
            write-host $u " - Not found in Euro, checking APAC" -ForegroundColor Yellow
            try {
                $s3 = get-ADUser $u -Server apac.epiqcorp.com
                If($s3.Enabled -eq $false) {
                    Write-Host $u " - Disabled, should remove here" -ForegroundColor Red
                    $array += $u
                } 
             } catch {
                write-host $u " - Not able to find"   
             }
        }
    }
}
$testAfter = Get-ADGroupMember $SingleGroup -server $DomainController
write-host "Before Count:" $testbefore.count
Write-Host "After Count:" $testAfter.count
Write-Host "Number of users removed: " $array.Count
$stopwatch.stop()
$stopwatch.Elapsed
$array > C:\temp\DisabledtoRemove_Epiq-All_US_3_7.txt

#$Script:UserCredential = Get-Credential
Function Remove {
    Foreach ($user in $array) {
    
        Write-Host "Removing: " $user
        Remove-ADGroupMember -Identity $SingleGroup -Members $user -Confirm:$False -credential $UserCredential
    }
}
