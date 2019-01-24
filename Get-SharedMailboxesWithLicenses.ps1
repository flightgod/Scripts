#Establish a PowerShell session with Office 365. You'll be prompted for your Delegated Admin credentials
$Cred = Get-Credential
Connect-MsolService -Credential $Cred
$customers = "epiqsystems3.onmicrosoft.com"
Write-Host "Found $($customers.Count) customers for $((Get-MsolCompanyInformation).displayname)." -ForegroundColor DarkGreen
$CSVpath = "C:\Temp\LicensedSharedMailboxes.csv"
$LicenseReportpath = "C:\Temp\SharedMailboxLicenseReport.csv"
$licensedSharedMailboxes = @()
 
foreach ($customer in $customers) {
    $licensedUsers = Get-MsolUser -TenantId $customer.TenantId | Where-Object {$_.islicensed}
 
    $ScriptBlock = {Get-Mailbox -ResultSize Unlimited}
    $InitialDomain = Get-MsolDomain -TenantId $customer.TenantId | Where-Object {$_.IsInitial -eq $true}    
    Write-Host "Checking Shared Mailboxes for $($Customer.Name)" -ForegroundColor Green
    $DelegatedOrgURL = "https://outlook.office365.com/powershell-liveid?DelegatedOrg=" + $InitialDomain.Name
    $sharedMailboxes = Invoke-Command -ConnectionUri $DelegatedOrgURL -Credential $Cred -Authentication Basic -ConfigurationName Microsoft.Exchange -AllowRedirection -ScriptBlock $ScriptBlock -HideComputerName -ErrorAction SilentlyContinue
    $sharedMailboxes = $sharedMailboxes | Where-Object {$_.RecipientTypeDetails -contains "SharedMailbox"}
 
    foreach ($mailbox in $sharedMailboxes) {
        $licensedSharedMailboxProperties = $null
        if ($licensedUsers.ObjectId -contains $mailbox.ExternalDirectoryObjectID) {
            Write-Host "$($mailbox.displayname) is a licensed shared mailbox" -ForegroundColor Yellow  
            $licenses = ($licensedUsers | Where-Object {$_.objectid -contains $mailbox.ExternalDirectoryObjectId}).Licenses
            $licenseArray = $licenses | foreach-Object {$_.AccountSkuId}
            $licenseString = $licenseArray -join ","
            Write-Host "$($mailbox.displayname) has $licenseString" -ForegroundColor Blue
            $licensedSharedMailboxProperties = @{
                CustomerName      = $customer.Name
                DisplayName       = $mailbox.DisplayName
                EmailAddress      = $mailbox.PrimarySmtpAddress
                Licenses          = $licenseString
                TenantId          = $customer.TenantId
                UserPrincipalName = ($licensedusers | Where-Object {$_.objectid -contains $mailbox.ExternalDirectoryObjectID}).UserPrincipalName
            }
            $forcsv = New-Object psobject -Property $licensedSharedMailboxProperties
            $licensedSharedMailboxes += $forcsv
            $forcsv | Select-Object CustomerName, DisplayName, EmailAddress, Licenses | Export-CSV -Path $CSVpath -Append -NoTypeInformation
            # Create a CSV with a license report and PowerShell Cmdlets that you can use to quickly reassign licenses if you've removed them in error. 
            foreach ($license in $licenses) {
                $licenseProperties = @{
                    CustomerName = $customer.Name
                    DisplayName  = $licensedSharedMailboxProperties.DisplayName
                    EmailAddress = $licensedSharedMailboxProperties.UserPrincipalName
                    License      = $license.AccountSkuId
                    TenantId     = $customer.TenantId
                    ReAddlicense = "Set-MsolUserLicense -UserPrincipalName $($licensedSharedMailboxProperties.UserPrincipalName) -TenantId $($customer.TenantId) -AddLicenses $($license.AccountSkuId)"
                }
                $forcsv = New-Object psobject -Property $licenseProperties
                $forcsv | Export-CSV -Path $LicenseReportpath -Append -NoTypeInformation
            }
        }
        else {   
            Write-Host "$($mailbox.DisplayName) is unlicensed"
        }
    }
}
# Provide an option to remove the licenses from the shared mailboxes
 
Write-Host "`nFound $($licensedSharedMailboxes.Count) licensed shared mailboxes in your customers' tenants. A list has been exported to $csvpath
A license report has been exported to $licenseReportPath, just in case you need to restore these licenses to the shared mailboxes later." -ForegroundColor Yellow
Write-Host "r: Press 'r' to remove all licenses from all shared mailboxes."
Write-Host "a: Press 'a' to be asked for each mailbox."
Write-Host "l: Press 'q' to quit and leave all licensed."
 
do {
    $input = Read-Host "Please make a selection"
    switch ($input) {
        "r" {
            Clear-Host
            Write-Host "Removing licenses from the following sharedmailboxes: `n$($licensedSharedMailboxes.userprincipalname -join ", ")"
            foreach ($mailbox in $licensedSharedMailboxes) {
                $currentLicenses = $null
                $licenses = $mailbox.Licenses -split ","
                foreach ($license in $licenses) {
                    Write-Host "Removing $license" -ForegroundColor Yellow
                    Set-MsolUserLicense -UserPrincipalName $($mailbox.UserPrincipalName) -TenantId $($mailbox.TenantId) -removelicenses $License
                }
                $currentLicenses = (Get-MsolUser -UserPrincipalName $($mailbox.UserPrincipalName) -TenantId $($mailbox.TenantId)).Licenses
                if (!$currentLicenses) {
                    Write-Host "License successfully removed from $($Mailbox.displayname) ($($mailbox.UserPrincipalName)): $($mailbox.Licenses)" -ForegroundColor Green
                }
                else {
                    Write-Host "License was not successfully removed from $($Mailbox.displayname) ($($mailbox.UserPrincipalName)), please remove licenses via the Office 365 Portal: $($mailbox.Licenses)" -ForegroundColor Red
                }
            }
            Read-Host "Enter q to quit."
            $input = "q"
            return
        } "a" {
            Clear-Host
            foreach ($mailbox in $licensedSharedMailboxes) {
                $mailboxChoice = $null
                do {
                    $mailboxChoice = Read-Host "Would you like to remove $($mailbox.licenses) from $($Mailbox.displayname) ($($mailbox.UserPrincipalName))? [y,n]"
                    switch ($mailboxChoice) {
                        "y" {
                            $currentLicenses = $null
                            $licenses = $mailbox.Licenses -split ","
                            foreach ($license in $licenses) {
                                Write-Host "Removing $license" -ForegroundColor Yellow
                                Set-MsolUserLicense -UserPrincipalName $($mailbox.UserPrincipalName) -TenantId $($mailbox.TenantId) -removelicenses $License
                            }
                            $currentLicenses = (Get-MsolUser -UserPrincipalName $($mailbox.UserPrincipalName) -TenantId $($mailbox.TenantId)).Licenses
                            if (!$currentLicenses) {
                                Write-Host "License successfully removed from $($Mailbox.displayname) ($($mailbox.UserPrincipalName)): $($mailbox.Licenses)" -ForegroundColor Green
                            }
                            else {
                                Write-Host "License was not successfully removed from $($Mailbox.displayname) ($($mailbox.UserPrincipalName)), please remove licenses via the Office 365 Portal: $($mailbox.Licenses)" -ForegroundColor Red
                            }
                        }
                        "n" {
                            Write-Host "Leaving $($mailbox.licenses) on $($mailbox.EmailAddress)"
                        }  
                    } Pause
                }until($mailboxchoice -eq "y" -or $mailboxChoice -eq "n")  
            }
            return
        } "q" {
            return
        }
    }
    pause
}
until ($input -eq "q")