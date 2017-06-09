<#  
.SYNOPSIS
   	Add Users which have SendOnBehalf permissions

.DESCRIPTION  
   

.INSTRUCTIONS
    

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 6/6/2017 - First iteration - kbennett 

        
    Rights Required		    : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Check and update additional Info from Export

.FUNCTIONALITY
  
#>

# Variables
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
$file = "C:\Temp\LicUsers - Copy.csv"
$Script:Name = ""
$ErrorActionPreference = "Stop"

Function ExchangeConnect 
{
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $UserCredential = Get-Credential
        $script:Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}


# Checks that the file is there, then imports it
Function ImportFile {
    $test = Test-Path $file
    If ($test -eq $true) {
        $script:import = Get-Content $file
    }
    Else {
        Write-Warning "Something went Wrong: Import File is missing at $file"
        Break
    }
}


Function CheckUser {

    foreach ($Name in $import){
    try {
        Get-Mailbox -ResultSize Unlimited | Get-ADPermission | where {($_.ExtendedRights -like “*Send-As*” -and $_.User -like "*$user")} | FT
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        write-host $ErrorMessage -foregroundColor Red
    }
  }  
}

ExchangeConnect
ImportFile
CheckUser

If ($List.Length -eq "0"){
        Write-Host "List of users with SendAs Permissions " 
    $List
}
Else {
    Write-Host "List is Null"
}

