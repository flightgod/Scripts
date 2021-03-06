<#
    .Synopsis
    Automation script for pulling updated list of IP ranges for Office 365 endpoints from Microsoft's published xml file.
    
    .Description
    Explanation:
    https://support.office.com/en-us/article/Office-365-URLs-and-IP-address-ranges-8548a211-3fe7-47cb-abb1-355ea5aa88a2
    XML file:
    https://support.content.office.net/en-us/static/O365IPAddresses.xml

    Script will need to be maintained as products are added and removed by Microsoft, at which point the 'Products' parameter
    should be updated to match the current list of products in the xml file.
    
    .Parameter Products
    One or more Office 365 products by their abbreviation in the xml file: EOP, EXO, Identity, LYO, o365, OneNote, Planner, 
    ProPlus, RCA, SPO, Sway, WAC, Yammer.  Comma separate multiple entries (e.g. '-Products EOP, EXO').

    .Example
    .\Get-Office365IPRanges.ps1 -Products eop, Identity, EXO, LYO, OneNote
    
    .Example
    .\Get-Office365IPRanges.ps1

    .Example
    .\Get-Office365IPRanges.ps1 | Export-Csv Office365IPRanges.csv -NoTypeInformation

    .Reference
    "o365", Office 365 portal and shared, Office 365 authentication and identity
    "LYO", Skype for Business Online
    "ProPlus", Office 365 ProPlus
    "SPO", SharePoint Online
    "WAC", Office Online
    "EX-Fed", Exchange Federation
    "OfficeiPad", Office for iPad
    "EXO", Exchange Online
    "Yammer", Yammer
    "OfficeMobile", Office Mobile
    "RCA", Office 365 remote analyzer tools
    "EOP", Exchange Online Protection (EOP)
#>
[CmdletBinding()]
Param 
( 
    [Parameter(Mandatory = $false)] 
    [ValidateSet("WAC", "Sway", "Planner", "o365", "Identity", "LYO", "EXO", "SPO", "Yammer", "RCA", "OneNote", "ProPlus", "EOP")] 
    [string[]]$Products = @("WAC", "Sway", "Planner", "o365", "Identity", "LYO", "EXO", "SPO", "Yammer", "RCA", "OneNote", "ProPlus", "EOP") 
) 
Begin
{
    try {
        $Office365IPsXml = New-Object System.Xml.XmlDocument
        $Office365IPsXml.Load("https://support.content.office.net/en-us/static/O365IPAddresses.xml")
    }
    catch {
        Write-Warning -Message "Failed to load xml file https://support.content.office.net/en-us/static/O365IPAddresses.xml"
        break
    }
    if (-not ($Office365IPsXml.ChildNodes.NextSibling))
    {
        Write-Warning -Message "Data from xml is either missing or not in the expected format."
        break
    }
}
Process
{
    Write-Verbose "Last updated date: $($Office365IPsXml.Products.updated)"
    foreach ($Product in ($Office365IPsXml.products.product | Where-Object ({$Products -match $_.Name}) | Sort-Object Name))
    {
        $IPv4Ranges = $Product | Select-Object -ExpandProperty Addresslist | Where-Object {$_.Type -eq "URL"}
        $IPv4Ranges = $IPv4Ranges | Where-Object {$_.address -ne $null} | Select-Object -ExpandProperty address
        foreach ($Range in $IPv4Ranges)
        {
            $ProductIPv4Range = New-Object -TypeName psobject -Property @{
                'Product'=$Product.Name;
                'IPv4Range'=$Range;
                'URL'=$URL;
            }
            Write-Output $ProductIPv4Range | Select-Object Product, IPv4Range | Add-Content -path c:\temp\ALLUrl.csv
        }
    }
}
End{}
