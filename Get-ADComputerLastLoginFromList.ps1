$import = Import-csv c:\temp\OfficeVersions.csv

foreach ($System in $Import){

Try {
    get-adcomputer $System.'Workstation Name' -Server $System.Domain -Properties * | `
    select `
        Name, `
        LastLogonDate, `
        OperatingSystem, `
        @{Label="Office Version";  Expression={$System.'Office Version Found'}}, `
        @{Label="User";  Expression={$System.'Last Logged on User'}} | `
    Export-Csv -Path C:\Temp\Testing.csv -NoTypeInformation -Append
} Catch {
 Write-Host "Unable to find" $System.'Workstation Name'
 }

}