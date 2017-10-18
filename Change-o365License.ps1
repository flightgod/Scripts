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
 $file = "C:\Temp\LicenseList2.csv",
 $URIString = "https://outlook.office365.com/powershell-liveid/",
 $skypLic = "epiqsystems3:MCOIMP",
 $SharePointLic = "epiqsystems3:SHAREPOINTSTANDARD",
 $E3Lic = "epiqsystems3:ENTERPRISEPACK",
 $E2LicAssign = "epiqsystems3:EXCHANGEENTERPRISE",
 $E1LicAssign = "epiqsystems3:EXCHANGESTANDARD"
)

# To Connect to o365
Function Connecto365 {
    If ($Session.ComputerName -ne "outlook.office365.com"){
        Write-Host "Enter your o365 username and password" -forgroundColor Green
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

# Checks that the file is there, then imports it
Function ImportFile {
    $test = Test-Path $file
    If ($test -eq $true) {
        $script:import = Import-csv $file
    }
    Else {
        Write-Warning "Something went Wrong:  Import File is missing at $file"
        Break
    }
}

# Checks Licenses
Function CheckLicense {
    $Name = $user.UserPrincipalName
     If ($user.Licenses.AccountSkuID -like $E3Lic){
        write-host "User $Name has $E3Lic" -ForegroundColor Red
        # Add & Remove lic
        # AddLicense
        RemoveLicense
        } Else {
            # dont need to do anything
            write-host "$E3Lic not assigned to user $Name" -ForegroundColor Green
        }
}



# Removes License
Function RemoveLicense {
    foreach ($script:Name in $import){
        $script:username = $Name.EpiqEmail
        Write-Host "Removing $E2LicAssign from $username" -ForegroundColor DarkGreen
        Set-MsolUserLicense `
            -UserPrincipalName $username `
            -RemoveLicenses $E2LicAssign
        AddLicense
    }
}

# adds License
Function AddLicense {
    Write-Host "Adding $E1LicAssign from $username" -ForegroundColor Green
    Set-MsolUserLicense `
        -UserPrincipalName $username `
        -AddLicenses $E1LicAssign
}

# Can Run this if you want to do it by individual
Function GetIndividualUser {
   $IndvName = Read-Host "What user do you want to check (username@epiqsystems.com)?"
   $user = Get-MSoluser -UserPrincipalName $IndvName
   $user.Licenses
   $Name = $user.UserPrincipalName
   If ($user.Licenses.AccountSkuID -like $E3Lic){
        write-host "User $Name has $E3Lic" -ForegroundColor Red
        # remove and add new lic       
        # AddLicense
        RemoveLicense

        } Else {
            write-host "$E3Lic not assigned to user $Name" -ForegroundColor Green
            # dont need to do anything
        }
}

# Script Main Body
Connecto365
ImportFile
RemoveLicense
# GetLicUsers #Used to change all uses license, if they had them already