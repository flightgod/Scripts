<# 

Get MX Record
Get SPF record



$Domain = "ChooseGCG.Com"

#Resolve-DnsName -Name $Domain -Type MX | select name, NameExchange
$Queury = Resolve-DnsName -Name $Domain -Type txt | select name, Strings | `
export-csv "c:\temp\DomainAudit.txt"

#>

$domains = @(Get-Content c:\temp\o365domains.txt)
# $domains | resolve-dnsname -Type MX | where {$_.QueryType -eq "MX"} | Select Name,NameExchange | Sort Name | export-csv "c:\temp\DomainAudit.csv" -NoTypeInformation

ForEach ($entry in $domains){

    $Results = resolve-dnsname -Name $entry -Type TX | Select Name,Strings | Sort Name

    If ($Results -eq $Null) {
        Add-content c:\temp\errorLog.txt $entry
    } Else {
        $Entry | resolve-dnsname -Type MX -Server 8.8.8.8 | where {$_.QueryType -eq "MX"} | Select Name,NameExchange | Sort Name |  Add-content c:\temp\DomainAudit.txt
        #$Entry | resolve-dnsname -Type TX | Select Name,Strings | Sort Name 

    }

     }
    

     resolve-dnsname -Name aacer.com -Type MX| where {$_.QueryType -eq "MX"} | Select Name,NameExchange | Sort Name
