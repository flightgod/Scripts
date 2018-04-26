#$smtpCred = (Get-Credential)
$ToAddress = 'kbennett@epiqglobal.com'
$FromAddress = 'svc_SMTPOut@epiqglobal.com'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = '25'

$mailparm = @{
    To = $ToAddress
    From = $FromAddress
    Subject = 'Automated testing'
    Body = 'This is a test'
    SmtpServer = $SmtpServer
    port = $SmtpPort
    Credential = $smtpCred
}

Send-MailMessage @mailparm

