<#  
.SYNOPSIS
   	Sends Username for users migrating to new Epiq account

.DESCRIPTION  
    Sends Username for users migrating to new Epiq account

.INSTRUCTIONS
    Run full script 

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 10/1/2017 - First iteration - kbennett 
                            : 1.1 - Posted 11/29/2017 - Updated for -ks user - kbennett
        
    Rights Required	        : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	:

.FUNCTIONALITY

#>

# Variables
Param (
$UserOU = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM",
$file = "C:\Temp\EmailList.csv",
$DomainController = "P054ADSAMDC01.amer.EPIQCORP.COM"
)


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


# Checks that AD User Exists
Function DOIt {
    $Global:count = $import.count
    foreach ($Email in $import){
        $Count
        $Global:Address = $Email.Email
        $Address
        Start-Sleep -s 2
        #SendEmail
        $count = $count - 1
    }
}

# Body text Function
Function BodyText {
    $Script:Body = "

Hello Everyone:

On February 26, Perceptyx launched an Engagement Survey sent to active and recent termed Limited Duration Employees on behalf of Epiq.  The survey closed on March 13 and the response was excellent!  If you chose to participate, I want to personally thank you for taking the time and providing feedback.  The information and insights gained as a result of the survey will help the DRS leadership team in the United States understand areas on which to focus and what we can do to help make your experience working with Epiq the best in our industry.

Over the next several weeks, the survey results will be reviewed and analyzed to help us formulate an action plan for 2019.  I will be in touch later in April to share information gained from the survey and our DRS action plan to move things forward.

We very much appreciate your time and thoughtfulness in completing the survey and anticipate that the survey will be an excellent resource to aid in addressing your suggestions and concerns.  

Thank you!

Tom Tromiczak
Epiq | Vice President, Document Review Services
Two Ravinia Drive, Suite 850
Atlanta, GA  30346
Phone:  +1 646 356 1769
Mobile:  +1 646 823 0598
Email:  ttromiczak@epiqglobal.com

People. Partnership. Performance.
www.epiqglobal.com

This electronic mail (including any attachments) may contain information that is privileged, confidential, and/or otherwise protected from disclosure to anyone other than its intended recipient(s). If you have received this message in error, please notify the sender immediately by reply email of the inadvertent transmission and then immediately delete the original message (including any attachments) in its entirety.
"
}

# Sending Email Function
Function SendEmail{
$script:messageBody = $Body + "`r`n"
Send-MailMessage `
    -From "DRS Survey <CorporateIT@epiqglobal.com>" `
    -To $Address `
    -Subject "Perceptyx Engagement Survey" `
    -Body $messageBody `
    -SmtpServer "mailrelay.amer.epiqcorp.com"

}

ImportFile
BodyText
DoIt


