$web = Invoke-WebRequest https://who.is/whois-ip/ip-address/bennett-technologies.com
$data = $web.AllElements | Where{$_.TagName -eq "Pre"} | Select-Object -Expand InnerText
$whois = ($data -split "`r`n`r`n" | select -index 1) -replace ":\s","=" | ConvertFrom-StringData
$whois


$webpage=Invoke-webrequest www.frf.usace.army.mil | Get-Member

Invoke-RestMethod -Uri https://support.office.com/en-us/o365ip/rss |`
? {$_.Title -like "Skype*"} | `
fT title, Description -AutoSize -Wrap

(new-object net.webclient).DownloadFile('https://gist.githubusercontent.com/AndrewSav/c4fb71ae1b379901ad90/raw/23f2d8d5fb8c9c50342ac431cc0360ce44465308/SO33205298','local.ps1')
./local.ps1 "parameter title"