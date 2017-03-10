$dom = "epiqsystems.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData


$dom = "irisds.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData


$dom = "hilsoft.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData


$dom = "epiqsystems.co.uk"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData


$dom = "epiqsystems.com.hk"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com_v2.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData



# ROLL BACK if Needed

$dom = "epiqsystems.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData

$dom = "irisds.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData

$dom = "hilsoft.com"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData

$dom = "epiqsystems.co.uk"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData

$dom = "epiqsystems.com.hk"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("c:\temp\epiqsts.epiqsystems.com.crt")
$certData = [system.convert]::tobase64string($cert.rawdata)
Set-MsolDomainAuthentication –DomainName $dom -SigningCertificate $certData
