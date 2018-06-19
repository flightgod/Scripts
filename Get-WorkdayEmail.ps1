$import = "C:\temp\WorkDayExport.csv"
$data = Import-Csv $import
$objForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$DomainList = @($objForest.Domains)
$Domains = $DomainList | foreach { $_.name }

foreach ($Domain in $Domains)
{
    ForEach ($entry in $data){
        try {
            Get-ADUser $entry.'User Name' -Properties Name,EmailAddress -Server apac.epiqcorp.com | `
            select `
            @{l="WorkdayID";e={$entry.'Employee ID'}}, `
            @{l="WorkdayEmail";e={$entry.'Email - Primary Work'}}, `
            EmailAddress, `
            Name, `
            SamAccountName, `
            UserPrincipalName | Export-CSV -Path C:\temp\WorkDayResults.csv -Append
        } catch {
            # put these into another file to check and fix
        }
    }
}
