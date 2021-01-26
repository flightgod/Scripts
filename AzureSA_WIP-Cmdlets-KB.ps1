<#  
.SYNOPSIS
   	Runs Cmdlts for Azure security Assessment using new AzXXX commandlets and MFA
.DESCRIPTION  
    Provides exports of various Azure cmdlets and configuration information via AzXXX commandlets and MFA
.USAGE
   AzureSA_WIP_Cmdlets-KB.ps1
   You will be prompted to enter a valid path and name for the data (txt,csv) output files.
.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.1 - Posted 11/07/2020 - working off of origial WIP script - kbennett 
         
    Rights Required		    : Global Reader for Azure Tenant
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Find accounts with a password stored in Azure AD attributes
                            : List Azure NAT Gateways
                            : would like to figure out how to only have to enter creds once
             
.FUNCTIONALITY
    Get Tenant Details and export CSV or TXT files
#>



$outputdir = Read-Host prompt 'Output Path (ex:c:\temp)'
$domain = Read-Host prompt 'Azure AD Domain name (ex: 'testdomain.local')'


# Authentication
Connect-MsolService

Import-Module ActiveDirectory
$FormatEnumerationLimit=-1

# Company Information
Write-Progress -Activity "Getting Company Information" -PercentComplete (1 / 61*100)
Get-MsolCompanyInformation >> $outputdir\cmdlet_Company-Information.txt

# Azure AD Password Policy
Write-Progress -Activity "Getting Azure AD Password Policy" -PercentComplete (2 / 61*100)
Get-MsolPasswordPolicy -DomainName $domain >> $outputdir\cmdlet_Azure-password-policy.txt 2>> $outputdir\Azure-cmdlet-error.txt

# Find accounts with a password stored in Azure AD attributes
#Write-Progress -Activity "Getting accounts with a password stored in Azure AD attributes" -PercentComplete (3 / 61*100)
#$x=Get-MsolUser;foreach($u in $x){$p = @();$u|gm|%{$p+=$_.Name};ForEach($s in $p){if($u.$s -like "*password*"){Write("[*]"+$u.UserPrincipalName+"["+$s+"]"+" : "+$u.$s)}}} 
# $outputdir\cmdlet_Azure-accounts-cleartext-password-storage.txt 2>> $outputdir\Azure-cmdlet-error.txt

# getting Guest users
Write-Progress -Activity "Getting Detailed listing of Guest Users" -PercentComplete (3 / 61*100)
Get-MsolUser -all | Sort -Property SignInName | where{$_.UserPrincipalName -like "*#ext#*"} | select SignInName, UserPrincipalName, DisplayName, WhenCreated >> $outputdir\cmdlet_GuestUsersDetailedListing.txt 2>> $outputdir\Azure-cmdlet-error.txt


# Authentication (Recommended Method)
Connect-AzAccount

# List Azure Network Security Groups (applied to resources)
Write-Progress -Activity "Getting Network Security Groups" -PercentComplete (1 / 61*100)
Get-AzNetworkSecurityGroup | select name,resourcegroupname | export-csv -path $outputdir\cmdlet_AzureNetworkSecurityGroups.csv

# List Azure Resource Groups
Write-Progress -Activity "Getting Resource Groups in Azure Account" -PercentComplete (2 / 61*100)
Get-AzResourceGroup | export-csv -path $outputdir\cmdlet_AzureResources.csv

# List Azure Public IPs
Write-Progress -Activity "Getting a listing of Azure Public IPs" -PercentComplete (3 / 61*100)
get-AzpublicIPaddress | export-csv -notypeinformation $outputdir\cmdlet_AzurePublicIPs.csv
get-AzpublicIPprefix | export-csv -notypeinformation $outputdir\cmdlet_AzurePublicIPPrefixes.csv

# List Disks and check if they are encrypted
Write-Progress -Activity "Getting a listing of Encryption Status on VM Disks" -PercentComplete (4 / 61*100)
$osVolEncrypted = {(Get-AzVMDiskEncryptionStatus -ResourceGroupName $_.ResourceGroupName -VMName $_.Name).OsVolumeEncrypted}
$dataVolEncrypted= {(Get-AzVMDiskEncryptionStatus -ResourceGroupName $_.ResourceGroupName -VMName $_.Name).DataVolumesEncrypted}
Get-AzVm | Format-Table @{Label="MachineName"; Expression={$_.Name}}, @{Label="OsVolumeEncrypted"; Expression=$osVolEncrypted}, @{Label="DataVolumesEncrypted"; Expression=$dataVolEncrypted} >> $outputdir\cmdlet_VMDiskEncryption.txt

#Getting Storage accounts
Write-Progress -Activity "Getting a listing of Storage Accounts" -PercentComplete (5 / 61*100)
Get-AzStorageAccount >> $outputdir\cmdlet_AzStorageAccounts.txt

# List Azure Network Security Group Rules
Write-Progress -Activity "Getting Network Security Group Rules using provided name" -PercentComplete (6 / 61*100)
$NSGNames = Get-AzNetworkSecurityGroup | Select Name

    ForEach ($nsgName in $NSGNames){
        $nsg = Get-AzNetworkSecurityGroup -name $NSGName.Name
        $ActualName = $nsgName.Name   
        $nsgRules = $nsg.SecurityRules
            foreach ($nsgRule in $nsgRules){
                $nsgRule | Select-Object Name,Description,Priority,Protocol,Access,Direction | Export-Csv "$outputdir\$ActualName-Security_Rules.csv" -NoTypeInformation -Encoding ASCII -Append
            }
        }

    ForEach ($nsgName in $NSGNames){
        $nsg = Get-AzNetworkSecurityGroup -name $NSGName.Name
        $ActualName = $nsgName.Name   
        $nsgRules = $nsg.DefaultSecurityRules
            foreach ($nsgRule in $nsgRules){
                $nsgRule | Select-Object Name,Description,Priority,Protocol,Access,Direction | Export-Csv "$outputdir\$ActualName-Default_Rules.csv" -NoTypeInformation -Encoding ASCII -Append
            }
        }

# Get Azure VM Info
Write-Progress -Activity "Getting AzureVM info" -PercentComplete (7 / 61*100)
$report = @()
$vms = Get-AzVM
$publicIps = Get-AzPublicIpAddress 
$nics = Get-AzNetworkInterface | ?{ $_.VirtualMachine -NE $null} 
foreach ($nic in $nics) { 
    $info = "" | Select VmName, ResourceGroupName, Region, VirturalNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress 
    $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id 
    foreach($publicIp in $publicIps) { 
        if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
            $info.PublicIPAddress = $publicIp.ipaddress
            } 
        } 
        $info.OsType = $vm.StorageProfile.OsDisk.OsType 
        $info.VMName = $vm.Name 
        $info.ResourceGroupName = $vm.ResourceGroupName 
        $info.Region = $vm.Location 
        $info.VirturalNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
        $info.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1] 
        $info.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress 
        $report+=$info 
    } 
$report | ft VmName, ResourceGroupName, Region, VirturalNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress 
$report | Export-CSV -path $outputdir\azure.csv



Write-Progress -Activity "Script has completed" -PercentComplete 100



<###############################################################
###### Needs more Work - Currently unable to Test
################################################################

# List Azure NAT Gateways
Write-Progress -Activity "Getting a listing of NAT Gateways (per Resource Group)" -PercentComplete (4 / 61*100)
$RSG = Get-AZResourceGroup | Select ResourceGroupName

    ForEach ($RSGName in $RSG){
        Get-AzNatGateway -ResourceGroupName $RSGName.ResourceGroupName 
    }

# then export to where it needs to go
export-csv -path $outputdir\cmdlet_AzNatGateways-All.csv

#Run again for specific NAT Gateway info
Get-AzNatGateway -ResourceGroupName "<RGname>" -Name "<Natgateway-name>" | export-csv -path $outputdir\cmdlet_AzNatGateway-Specific.csv

#>



