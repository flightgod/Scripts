$AWS_ACCESS_KEY = "AKIAI6SU3JUW3P2SPKQA"
$AWS_SECRET_KEY = "BGPaOL6LqMhiXVYS4Y+i6zE8OGhEO+1LOE1n9zOktyPB"

$SECURE_KEY = $(ConvertTo-SecureString -AsPlainText -String $AWS_SECRET_KEY -Force)
$creds = $(New-Object System.Management.Automation.PSCredential ($AWS_ACCESS_KEY, $SECURE_KEY))

$from = "ThePowerShell@epiqglobal.us"
$to = "kbennett@epiqglobal.com"
$subject = "This is a test" 
$body = "This is a test to send to SES from Internal Epiq"

Write-Host "Sending Email via AmazonSES"
Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer email-smtp.us-east-1.amazonaws.com -Credential $creds -UseSsl -Port 25
Write-Host "Sent"

