<#
.SYNOPSIS
    Update Licenses
.DESCRIPTION
    This script should be ran to change o365 Licenses from E3 to Exchange and Sharepoint
.AUTHOR
    Kevin Bennett - 8/09/2017
.EXAMPLE
   
.SYNTAX
   
.ALIASES
    No Alias
.LINK
    NA
.PARAMETER 1
    
.PARAMETER 2
    
.NOTE

#>

#Variable
param (
 $URIString = "https://outlook.office365.com/powershell-liveid/",
 $ExchangeLic = "epiqsystems3:EXCHANGEENTERPRISE",
 $SharePointLic = "epiqsystems3:SHAREPOINTSTANDARD",
 $E3Lic = "epiqsystems3:ENTERPRISEPACK",
 $E3LicAssign = "",
 $E2LicAssign = ""
)

# To Connect to o365
Function Connecto365 {
    If ($Session.ComputerName -ne "outlook.office365.com"){
        Import-Module MSOnline
        $ocred = Get-Credential
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URIString -Credential $ocred -Authentication Basic -AllowRedirection
        Import-PSSession $Session
        Connect-MsolService -Credential $ocred
    } Else {
        Write-Host "Session already established to o365"
    }
}

# Get Users with Licenses Assigned
Function GetLicUsers {
    $AllUsers = Get-MsolUser -ALL | `
    where {$_.isLicensed -eq $true}
    # for each user check lic
    ForEach ($user in $AllUsers){
        CheckLicense
    }
}

# Checks Licenses
Function CheckLicense {
    $Name = $user.UserPrincipalName
     If ($user.Licenses.AccountSkuID -like $E3Lic){
        write-host "User $Name has $E3Lic" -ForegroundColor Red
        # Add & Remove lic
        AddLicense
        # RemoveLicense
        } Else {
            # dont need to do anything
            write-host "$E3Lic not assigned to user $Name" -ForegroundColor Green
        }
}

# Updates License to Individual Exchange Plan
Function RemoveLicense {
    Write-Host "Removing $E3Lic from $user" -ForegroundColor DarkGreen
    Set-MsolUserLicense `
        -UserPrincipalName $user.UserPrincipalName `
        -RemoveLicenses $E3Lic
}

Function AddLicense {
    Write-Host "Adding $ExchangeLic from $user" -ForegroundColor Green
    Set-MsolUserLicense `
        -UserPrincipalName $user.UserPrincipalName `
        -AddLicenses $ExchangeLic
}

# Can Run this if you want to do it by individual
Function GetIndividualUser {
   $IndvName = Read-Host "What user do you want to check (username@epiqsystems.com)?"
   $user = Get-MSoluser -UserPrincipalName $IndvName
   $user.Licenses
   $Name = $user.UserPrincipalName
   If ($user.Licenses.AccountSkuID -like $E3Lic){
        write-host "User $Name has $E3Lic" -ForegroundColor Red
        UpdateLicense
        # remove and add new lic
        } Else {
            write-host "$E3Lic not assigned to user $Name" -ForegroundColor Green
            # dont need to do anything
        }
}

# Script Main Body
Connecto365
GetLicUsers