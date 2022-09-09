<#  
.SYNOPSIS
   	Runs to get Domain Whois Info From Whoisxmlapi
.DESCRIPTION  
    Provides exports of various Domain Whois Info
.USAGE
   .\Get-DomainWhoISInfo.ps1 -APIKey <APIKey> -DomainName <DomainName>

.NOTES  
    Current Version     		: 1.0
    
    History			        : 1.1 - Posted 6/27/2022 - Creating Script - kbennett 

         
    Rights Required		    	: Global Reader for Azure Tenant
                        		: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	
                            		: Check connection is done
                            		: Error Checking

             
.FUNCTIONALITY
    Get Whois Details and export CSV files
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [String]
    $APIKey, 
    [Parameter(Mandatory = $true)]
    [string[]]
    $DomainName
)

$responses = @()
$DomainName | ForEach-Object {
    $requestUri = "https://www.whoisxmlapi.com/whoisserver/WhoisService?"`
    + "apiKey=$apiKey"`
    + "&domainName=$domainName"`
    + "&outputFormat=JSON"
    $responses += Invoke-RestMethod -Method Get -Uri $requestUri
}

function Get-ValidDate ($Value, $Date) {
    $defaultDate = $Value."$($Date)Date"
    $normalizedDate = $Value.registryData."$($Date)DateNormalized"

    if (![string]::IsNullOrEmpty($defaultDate)) {
        return Get-Date $defaultDate
    }

    return [datetime]::ParseExact($normalizedDate, "yyyy-MM-dd HH:mm:ss UTC", $null)    
}

$properties = "domainName", "domainNameExt",
@{N = "createdDate"; E = { Get-ValidDate $_ "created" } },
@{N = "updatedDate"; E = { Get-ValidDate $_ "updated" } },
@{N = "expiresDate"; E = { Get-ValidDate $_ "expires" } },
"registrarName",
"contactEmail",
"estimatedDomainAge",
# @{N = "registrant"; e = { $_.registrant.rawtext } },
@{N = "contact"; e = { ($_.registrant | Select-Object -Property * -ExcludeProperty rawText ).PSObject.Properties.Value -join ", " } }

$whoIsInfo = $responses.WhoisRecord | Select-Object -Property $properties

$whoIsInfo | Export-Csv -NoTypeInformation d:\temp\domain-whois.csv

$whoIsInfo | Format-Table