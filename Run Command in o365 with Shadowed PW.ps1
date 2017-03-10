# Checks for the Password File then loads Exchange o365 Powershell off credentials
# Other stuff here
# Variables that can be changed
$path = "C:\Scripts\0365Passwd.txt"
$myusername = "ward_kbennett@epiqsystems3.onmicrosoft.com"

# Does the file exist?, If not ask for Password and encrypt it
if(![System.IO.File]::Exists($path)){
    read-host -prompt "Enter password to be encrypted in 0365Passwd.txt " -assecurestring | convertfrom-securestring | out-file $path
}

# Start making the Auth and Connections to o365
$mypass = cat $path | convertto-securestring
$mycreds = new-object `
    -typename System.Management.Automation.PSCredential `
    -argumentlist $myusername,$mypass
Import-Module MSOnline
Connect-MsolService `
    -Credential $mycreds
$O365Session = New-PSSession `
    -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://ps.outlook.com/PowerShell-LiveID?PSVersion=4.0 `
    -Authentication Basic `
    -AllowRedirection `
    -Credential $mycreds
Import-PSSession $O365Session
# Done


Get-Mailbox -ResultSize Unlimited | Where {$_.ForwardingAddress -ne $null -or $_.ForwardingSMTPAddress -ne $null}| FT DisplayName, ForwardingAddress, ForwardingSMTPAddress -AutoSize

$List = Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Where {$_.TotalItemSize -like "*GB*"}|Sort DisplayName | Select DisplayName, TotalItemSize