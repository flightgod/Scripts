#========================================================================
# Created on:	12/14/2013 12:27 PM
# Created by:	Greg Armstong (Greg.Armstrong@hrizns.com)
# Organization:	Horizons Consulting, Inc
# Filename:		StartExchangeShell.ps1
#========================================================================
param (
[Parameter(Mandatory=$true,Position=1)]
   [string]$CredentialProfile,
[Parameter(Mandatory=$false,Position=2)]
   [string]$URL = "https://ps.outlook.com/powershell",
[Parameter(Mandatory=$false,Position=3)]
   [bool]$MSOLSession = $false,
[Parameter(Mandatory=$false,Position=4)]
   [bool]$LyncSession = $false,
[Parameter(Mandatory=$false,Position=4)]
   [string]$LyncOverideAdminDomain = $null
)

$Version = "0.1" 
$Version = "1.0" # URl Quit working change to URL [string]$URL = "https://outlook.office365.com/powerShell-liveID?serializationLevel=Full" (in some of the newer documentation"
$Version = "1.1" # Change back to https://ps.outlook.com/powershell from temporary URL.  New URL would not work with Okta.   
$version = "1.2 (2015/11/30)" #Added LyncOverideAdminDomain parameter
$version = "1.3 (2015/12/1)" #Added -Verbose on the New-CsOnlineSession and Import-PSSession / Addedd $Error info in the catch of the error, set error message to 'red'.
$version = "1.4 (2015/12/2)" #force the credential file to always be retrived and stored in the same directory as the script.

#https://ps.outlook.com/powershell 
#=================================
#  Export-PSCredential
#=================================
function Export-PSCredential {
	param ( $Credential = (Get-Credential), $Path = "credentials.enc.xml" )

	switch ( $Credential.GetType().Name ) {
		PSCredential		{ continue }
		String				{ $Credential = Get-Credential -credential $Credential }
		default				{ Throw "You must specify a credential object to export to disk." }
	}

	$export = "" | Select-Object Username, EncryptedPassword
	$export.Username = $Credential.Username
	$export.EncryptedPassword = $Credential.Password | ConvertFrom-SecureString 
	$export | Export-Clixml $Path 
	Get-Item $Path
}
#=================================
#  Import-PSCredential
#=================================
function Import-PSCredential {
	param ( $Path = "credentials.enc.xml" )
	$import = Import-Clixml $Path -ErrorAction SilentlyContinue
	if ($import -eq $null) {return}
	if ( !$import.UserName -or !$import.EncryptedPassword ) {Return	}
	$Username = $import.Username
	$SecurePass = $import.EncryptedPassword | ConvertTo-SecureString
	$Credential = New-Object System.Management.Automation.PSCredential $Username, $SecurePass
	Write-Output $Credential
}



#=================================
#  GetScriptDirectory
#=================================
function GetScriptDirectory {
    Write-Output (Split-Path $script:MyInvocation.MyCommand.Path)
}
#=================================
#  Startup / Credential Setup
#=================================
Write-Host "====================="
Write-Host "Version: $version"
Write-Host "====================="
$CredentialFile = "$(GetScriptDirectory)\$($CredentialProfile)_EncryptedBy_$(([Security.Principal.WindowsIdentity]::GetCurrent().Name).Replace('\','_')).xml"
if ($CredentialFile.Substring($CredentialFile.LastIndexOf(".")+1) -ne "xml") {
	$CredentialFile += ".xml"
}
Write-Host $CredentialFile
Try {
	$global:Cred = Import-PSCredential $CredentialFile
}
Catch {
	Write-Host -ForegroundColor Red -Object "Credential file $CredentialFile not found for current user"
	$global:Cred = Get-Credential  
}
if ($global:Cred -eq $Null) {
	Write-Host -ForegroundColor Red -Object "Credentials not entered, exiting"
	Break
}
Export-PSCredential -Credential $global:Cred -Path $CredentialFile
#=================================
#  Main logic
#=================================
try {
    $global:Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL  -Credential $global:Cred -Authentication Basic -AllowRedirection -ErrorAction Stop
    Import-PSSession $Session
    Write-Host -ForegroundColor 'Green' -Object "Connected to Exchange Online with userID $($global:Cred.UserName)" 
}
catch {
    Write-Host -ForegroundColor 'Red' -Object "Unable to connected to Exchange Online with userID $($global:Cred.UserName). Error:$($Error[0].Exception)" 
}

if ($MSOLSession) {
    Try {
	    Connect-MsolService -Credential $global:Cred -ErrorAction Stop
	    Write-Host -ForegroundColor Green -Object "Connected to MSOL with userID $($global:Cred.UserName)"
    }
    catch {
        Write-Host -ForegroundColor Red -Object "Unable to connected to MSOL with userID $($global:Cred.UserName). Error:$($Error[0].Exception)"
        
    } 
}

if ($LyncSession) {
    Try {
	    $Global:LyncSession = New-CsOnlineSession -Credential $cred -ErrorAction Stop -OverrideAdminDomain $LyncOverideAdminDomain -Verbose
	    Import-PSSession $Global:LyncSession 
	    Write-Host -ForegroundColor 'Green' -Object "Connected to Lync Online with userID $($global:Cred.UserName)" 
    }
    Catch {
        Write-Host -ForegroundColor red -Object "Unable to connect to Lync Online with userID $($global:Cred.UserName) . Error:$($Error[0].Exception)" 
    }
}

