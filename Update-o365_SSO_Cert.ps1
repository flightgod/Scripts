<#  
.SYNOPSIS
   Apply new Cert to o365

.DESCRIPTION  
    Apply new cert to o365 

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 1/13/2017 - First iteration - kbennett                      
    
    Rights Required		: Exchange Permissions
                        : Exchange is in OnPrem environment
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 
                        : make it look better

.FUNCTIONALITY
    applies cert to o365. Need to work on this.
#>

$dom = "domain.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData


$dom = "domain.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData


$dom = "domain.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData


$dom = "domain.co.uk"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData


$dom = "domain.com.hk"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData



# ROLL BACK if Needed

$dom = "domain.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData

$dom = "domain.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData

$dom = "domain.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData

$dom = "domain.co.uk"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData

$dom = "domain.com.hk"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\domain.domain.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData
