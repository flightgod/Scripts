# Function to send Emails
Function SendReport ($Subject, $path, $Info)
{
$MailServer = "relay.amer.epiqcorp.com" #New Relay in LV "10.35.16.15"
$mailServer2 = "MailRelay.amer.epiqcorp.com"
$style = "<style>
		BODY{font-family: Arial; font-size: 8pt;}
		H1{font-size: 22px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
		H2{font-size: 18px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
		H3{font-size: 16px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
		TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
		TH{border: 1px solid #969595; background: #dddddd; padding: 5px; color: #000000;}
		TD{border: 1px solid #969595; padding: 5px; }
		td.pass{background: #B7EB83;}
		td.warn{background: #FFF275;}
		td.fail{background: #FF2626; color: #ffffff;}
		td.info{background: #85D4FF;}
    </style>"
$report = (get-content $path | out-String)
$body = $info += $style += $report
Send-MailMessage -From powershellfoo@epiqsystems.com -Subject $Subject -To kbennett@epiqsystems.com -smtpserver $MailServer2 -Body $body -BodyAsHtml -Attachments $path -ErrorAction STOP
}

#Function to Run Search on AD Account Status
Function RunReport ($path, $Domains, $time, $where)
{
Search-ADAccount -Server $Domains -accountinactive -usersonly -timespan $time | `
    Where $where | `
    Sort LastLogonDate |`
    Select Name,LastLogonDate,AccountExpirationDate,SamAccountName,Enabled,DistinguishedName |`
    ConvertTo-HTML |`
    Out-File $path
    }
