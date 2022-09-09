# Loop through all Subscriptions that you have access to and export the information
$AllPublicIPs = $null

Get-AzSubscription | ForEach-Object { 
 
    Write-Verbose -Message "Changing to Subscription $($_.Name)" -Verbose 
 
    $s = Select-AzSubscription -TenantId $_.TenantId -Subscription $_.Id -Force 
    $Name     = $_.Name 
    $TenantId = $_.TenantId
    $PublicIPs = $null
    $PublicIPs = Get-AzPublicIpAddress | Select -Property @{name='subscription';e={$name}}, *name,ipaddress,PublicIpAllocationMethod,location,@{name='sku';e={$_.sku.name}},@{name='dns';e={$_.dnssettings.domainnamelabel}},@{name='fqdn';e={$_.dnssettings.fqdn}}
    $AllPublicIPs += $PublicIPs
 
    #Get-AzPublicIpAddress | Select -Property @{name='subscription';e={$name}}, *name,ipaddress,PublicIpAllocationMethod,location,@{name='sku';e={$_.sku.name}},@{name='dns';e={$_.dnssettings.domainnamelabel}},@{name='fqdn';e={$_.dnssettings.fqdn}} -OutVariable ra
 
 
}
$AllPublicIPs | Export-CSV -Path .\PublicIPsAzure.csv -NoTypeInformation
# | Export-Csv -Path .\PublicIPAzure.csv -NoTypeInformation