# Checks for the Password File then loads Exchange o365 Powershell off credentials
# Other stuff here
# Variables that can be changed
$myusername = read-host -prompt 'Enter o365 UserName'
$path = "C:\%USERPROFILE%\Documents\"+$myusername+"_o365Passwd.txt"


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
