param (
$Site = "http://svrgias6vms.ftjandco.local:9080/gias/security/login.xhtml"
)


# Command to Check Status
$statusCode = wget $site | % {$_.StatusCode}

If ($statusCode -eq 200) {
    Write-Host "Site is up"
    $StatusCode
} Else { 
    Write-Host "Site is down"
    $statusCode
}

# Install the PowerShell Module
#Install-Module -Name Microsoft.Online.SharePoint.PowerShell

#Import and Connect
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

Connect-SPOService -Url https://Tier3tech.sharepoint.com


# Function to Update SharePoint List
#Need to make o365 Connection
Function UpdateStatus {
    $SPWeb = Get-SPWeb https://Tier3Tech.sharepoint.com/sites/EnterpriseSystems2
    $List = $SPWeb.Lists["GIAS Environment Status"]
    $items = $List.Items
<#    foreach ($item in $items) {
        $taskStatus = $item["Status"]
        $docStatus = $item["Document Status"]
        if ($taskStatus -eq "Completed" -and $docStatus -eq "Pending") {
            $item["Document Status"] = "Approved"
            $item.Update()
            $list.Update()
        }
} #>
$SPWeb.Dispose()

}

Function RunRemote {


$url = 'https://raw.githubusercontent.com/flightgod/PowerShell/master/Check-Website_Status.ps1'
iex ((New-Object Net.WebClient).DownloadString($url))

}