#$smtpCred = (Get-Credential)
$ToAddress = 'kbennett@domain.com'
$FromAddress = 'svc_SMTPOut@domain.com'
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

