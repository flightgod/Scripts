$smtpCred = (Get-Credential)
$ToAddress = 'flightgod@gmail.com'
$FromAddress = 'Test_TLS@EvilCorpGlobal.DE'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = '587'

$mailparm = @{
    To = $ToAddress
    From = $FromAddress
    Subject = 'TLS Automated testing'
    Body = 'This is a test'
    SmtpServer = $SmtpServer
    port = $SmtpPort
    Credential = $smtpCred
}

Send-MailMessage @mailparm -UseSsl




Test_TLS@EvilCorpGlobal.DE
test_TLS@@EvilCorpGlobal.CH
