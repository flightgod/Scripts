Set-ADServerSettings -ViewEntireForest $True
$import = "C:\temp\ReBrandFix.csv"
$data = Import-Csv $import

forEach ($user in $data){
$alias = $user.alias
$newalias = $user.mail
Set-RemoteMailbox $alias -alias $newalias -EmailAddressPolicyEnabled $true
}



$Crap = "C:\temp\DLMistakes.csv"
$DLData = Import-Csv $Crap

forEach ($dl in $DlData){
    $NewAlieas = $dl.Alias -replace '.irisds.com',''
    Set-DistributionGroup $dl.Alias -Alias $NewAlieas
}

$test = Get-DistributionGroup -ResultSize Unlimited| Where {$_.alias -like "*irisds.com*"} | Select Alias

Add-Content c:\temp\DLMistakes.csv $test


$trace = Get-MessageTrace -StartDate 01/23/2018 -EndDate 01/24/2018 -Status Failed -PageSize 5000
