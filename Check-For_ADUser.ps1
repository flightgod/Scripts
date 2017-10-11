# Variables
Param (
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/",
$UDF = "AUG",
$UserOU = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM",
$file = "C:\Temp\UsernameList.csv",
$RemoveFile ="c:\Temp\RemoveList.csv",
$DomainController = "P054ADSAMDC01.amer.EPIQCORP.COM",
$NewPath = "OU=Delete,OU=Exchange-Team,DC=amer,DC=EPIQCORP,DC=COM"
)


# Checks that the file is there, then imports it
Function ImportFile {
    $test = Test-Path $file
    If ($test -eq $true) {
        $script:import = Import-csv $file
    }
    Else {
        Write-Warning "Something went Wrong:  Import File is missing at $file"
        Break
    }
}


Function CheckUserNew {
    foreach($name in $import){
        $sam = $Name.EpiqUserName
            try{
                $account = Get-ADUser $sam
            } catch {}

    if($account){
        write-host "user Exists" $account.samaccountname -ForegroundColor Green
    } else {
        write-host "User Doesnt Exist" $Name.EpiqUserName -ForegroundColor Red
        $Name.EpiqUserName | out-file "c:\temp\DTIMigration_Missing_AD_Account.txt" -append}
    Clear-Variable account
    }
}

ImportFile
CheckUserNew