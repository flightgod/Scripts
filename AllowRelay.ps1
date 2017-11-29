$null = Add-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.Admin -ErrorAction SilentlyContinue
$2007snapin = Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.Admin -ErrorAction SilentlyContinue
$DateStamp = get-date -uformat "%Y-%m-%d@%H-%M-%S"
$ipstoadd1 = @()
$ipstoadd2 = @()
$excludedips = @("0.0.0.0","255.255.255.255","127.0.0.1")
$list = @()
$hub1 = "hub1.csv"
$hub2 = "hub2.csv"

Function Ask-YesOrNo
	{
	param([string]$title="",[string]$message="")
	$choiceYes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Answer Yes."
	$choiceNo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Answer No."
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($choiceYes, $choiceNo)
	$result = $host.ui.PromptForChoice($title, $message, $options, 1)
	#$result = $host.ui.PromptForChoice($options, 1)
		switch ($result) {
		0
		{Return $true}
		1
		{Return $false}
		}
	}

Write-host "Enter IPs to check for or to add to relay(blank line when done):" 
do {
 $line = (Read-Host " ") 
 if ($line -ne '') {$list += $line}
 }
 until ($line -eq '')
$RecvConn = Get-ReceiveConnector "ET016-EX10HUB1\Relay - Hub1"
$RecvConn2 = Get-ReceiveConnector "ET016-EX10HUB2\Relay - Hub2"

$RecvConn.RemoteIPRanges | Select LowerBound,UpperBound,Netmask,CIDRLength,RangeFormat,Size | export-csv c:\scripts\exchange\logs\relay\$DateStamp$hub1 -notypeinformation
$RecvConn2.RemoteIPRanges | Select LowerBound,UpperBound,Netmask,CIDRLength,RangeFormat,Size | export-csv c:\scripts\exchange\logs\relay\$DateStamp$hub2 -notypeinformation

Foreach ($ipAddress in $list) {
	$octetcount = @()
	$octetcount = $ipaddress.split('.')
		if (($ipAddress -as [ipaddress]) -and ($octetcount.length -eq 4) -and -not ($excludedips -match $ipAddress)) {
			#Write-host $ipAddress is valid
			 if ($RecvConn.RemoteIPRanges -contains $ipAddress) {
				Write-host -foregroundcolor green "$ipAddress already exists in ET016-EX10HUB1\Relay - Hub1 and will not be added"
				} else {
					Write-host -foregroundcolor yellow "$ipAddress is not allowed to relay on ET016-EX10HUB1\Relay - Hub11"
					$ipstoadd1 +=$ipAddress
					}
			if ($RecvConn2.RemoteIPRanges -contains $ipAddress) {
				Write-host -foregroundcolor green "$ipAddress already exists in ET016-EX10HUB2\Relay - Hub2 and will not be added"
				} else {
					Write-host -foregroundcolor yellow "$ipAddress is not allowed to relay on ET016-EX10HUB2\Relay - Hub2"
					$ipstoadd2 +=$ipAddress
					}
		} else {
			Write-host -foregroundcolor red "$ipAddress is not a valid IP address."
	}
}
Write-host "------------------------------------------------------------------------"
If ($ipstoadd1) {
	Write-host The following IPs can be added to ET016-EX10HUB1\Relay - Hub1
	Write-host $ipstoadd1 | ft -a
}
If ($ipstoadd2) {
	Write-host The following IPs can be added to ET016-EX10HUB2\Relay - Hub2
	Write-host $ipstoadd2 | ft -a
}
If (($ipstoadd1) -or ($ipstoadd2)) { 

Write-host "Do you want to add these IP's to mail relay?"
If (Ask-YesOrNo) 
{
$ipstoadd1  | foreach {$RecvConn.RemoteIPRanges += "$_"}
$ipstoadd2  | foreach {$RecvConn2.RemoteIPRanges += "$_"}
write-host Adding IPs to ET016-EX10HUB1\Relay - Hub1
Set-ReceiveConnector "ET016-EX10HUB1\Relay - Hub1" -RemoteIPRanges $RecvConn.RemoteIPRanges
#$RecvConn.RemoteIPRanges | select LowerBound |sort-object Lowerbound
write-host Adding IPs to ET016-EX10HUB2\Relay - Hub2
Set-ReceiveConnector "ET016-EX10HUB2\Relay - Hub2" -RemoteIPRanges $RecvConn2.RemoteIPRanges
#$RecvConn2.RemoteIPRanges | select LowerBound |sort-object Lowerbound

$RecvConnModified = Get-ReceiveConnector "ET016-EX10HUB1\Relay - Hub1"
$RecvConn2Modified = Get-ReceiveConnector "ET016-EX10HUB2\Relay - Hub2"

$RecvConnModified.RemoteIPRanges | Select LowerBound,UpperBound,Netmask,CIDRLength,RangeFormat,Size | export-csv c:\scripts\exchange\logs\relay\$DateStamp"Modified"$hub1 -notypeinformation
$RecvConn2Modified.RemoteIPRanges | Select LowerBound,UpperBound,Netmask,CIDRLength,RangeFormat,Size | export-csv c:\scripts\exchange\logs\relay\$DateStamp"Modified"$hub2 -notypeinformation


}
Else
{
Write-host "No changes have been made."
}
}
Else
{
Write-host "No Ips to add"
}


Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#$ipstoadd1  | foreach {$RecvConn.RemoteIPRanges += "$_"}
#$ipstoadd2  | foreach {$RecvConn2.RemoteIPRanges += "$_"}
#Set-ReceiveConnector "ET016-EQEXCHUB1\Internal Relay - Hub1" -RemoteIPRanges $RecvConn.RemoteIPRanges
#Set-ReceiveConnector "ET016-EQEXCHUB2\Internal Relay - Hub2" -RemoteIPRanges $RecvConn2.RemoteIPRanges



#$RecvConn.RemoteIPRanges | select LowerBound |sort-object Lowerbound
#$RecvConn.RemoteIPRanges | select LowerBound |sort-object Lowerbound
#$RecvConn2.RemoteIPRanges | select LowerBound |sort-object Lowerbound
#$RecvConn2.RemoteIPRanges | select LowerBound |sort-object Lowerbound