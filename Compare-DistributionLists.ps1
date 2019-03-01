$EpiqAllUS = Get-ADGroupMember Epiq-All-US
$ImportFile = "c:\temp\Epiq-All-US.csv"

Function ImportList {
    $test = Test-Path $ImportFile
    If ($test -eq $true) {
        $script:import = Import-csv $ImportFile
    }
    Else {
        Write-Warning "Something went Wrong: File is missing at $ImportFile"
        Break
    }
}

$epiqAllUs | select SamAccountName,DistinguishedName,Name |Export-Csv c:\temp\Lookup.csv
$import


diff $EpiqAllUS $import -Property 'SamAccountName' -IncludeEqual