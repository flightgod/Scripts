<#  
.SYNOPSIS
   	

.DESCRIPTION  


.INSTRUCTIONS
    

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 8/24/2017 - First iteration - kbennett 

        
    Rights Required		    : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	

.FUNCTIONALITY
    
#>

# variables
$SingleDomain = 'flightgod.com'
$key = '2wYW3fbpgK_6JfsTr1ndNaYFXXm9pax8G'
$secret = '6JjdQFYN9U4XFbHE6YYYc8'
$headers = @{}
$headers["Authorization"] = 'sso-key ' + $key + ':' + $secret
$file = "C:\temp\o365Domains.csv"

Function ImportList {
    $import = Import-csv $file
}

Function CheckAvail {
    ForEach ($Domain in $import) {
    Start-Sleep -s 2
    $test = $domain.Domain
        $Data = Invoke-WebRequest `
        -Headers $headers `
        -Method Get `
        -Uri "https://api.godaddy.com/v1/domains/available?domain=$test" | `
        ConvertFrom-Json
        If ($Data.available -eq "True"){
            Write-Host "Domain $Test is Available."-ForegroundColor Green 
            #Add-Content -path c:\temp\FreeDomains.csv $Test
            # put in List to clean up
        } Else {
        Write-Host "Domain $test is NOT Available."-ForegroundColor Red
        GetWhoisInfo
            # check Domain Info and see if it belongs to us
        }
    }
}

Function GetDomainInfo {

    $DomainInfo = Invoke-WebRequest `
    -Headers $headers `
    -Method Get `
    -Uri "https://api.godaddy.com/v1/domains/epiqsystems.com" | `
    ConvertFrom-Json | `
    Select Domain, ContactAdmin
    $DomainInfo.contactAdmin.organization
}

Function GetWhoisInfo {
    $DomainInfo = Invoke-WebRequest `
    -Uri "http://api.bulkwhoisapi.com/whoisAPI.php?domain=$Test&token=usemeforfree" | ConvertFrom-Json
    $DomainInfo.formatted_data.NameServer
}

Function CheckAvailSingleDomain {

        $Data = Invoke-WebRequest `
        -Headers $headers `
        -Method Get `
        -Uri "https://api.godaddy.com/v1/domains/available?domain=$SingleDomain" | `
        ConvertFrom-Json | Select Available, Domain
        $Data.Available
}

ImportList
CheckAvail