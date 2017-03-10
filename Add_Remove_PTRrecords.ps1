<#
.Synopsis
	Bulk add/delete PTR records.
.Description
	Script Imports CSV file into powershell and adds/deletes PTR records based on the function called.
.Example
	CSV format
	
	Zonename	           Octet	FQDN
	100.99.55.in-addr.arpa	145	av1.test.local
	100.99.55.in-addr.arpa	224	bb111.testing.local
	25.46.100.in-addr.arpa	100	ag333.test.local
	25.46.100.in-addr.arpa	0	log11.test.local
	25.46.100.in-addr.arpa	1	ggg213e23.tessst.local
.Example
	Type a period, a space and the path to the file something like this:

	PS C:\> . \\phx\services\proddsl\GFS-DNS\Public\Bulk_add_remove_DNSPTRfromCSV.ps1

	Then you can call the command at the prompt:

	PS C:\> Add-PTRrecord -Server server01 -CSVFilepath c:\NEWPTR.csv
.Example
	Type a period, a space and the path to the file something like this:

	PS C:\> . C:\Users\Administrator\Desktop\Add_Remove_PTRrecords.ps1

	Then you can call the command at the prompt:

	PS C:\> Delete-PTRrecord -Server server01 -CSVFilepath c:\users\admin\oldptr.csv
.Notes
	Written by 99 upgrade - September 2013.
#>


function Add-PTRrecord {

[CmdletBinding()]
param(

    [parameter(Mandatory=$True,HelpMessage="Server name to add the record")]
    [string]$Server,

    [parameter(Mandatory=$True,HelpMessage="Filepath of the CSV")]
    [string]$CSVfilepath
)


$logfile = "c:\temp\ADD_PTRrecords.txt"

Import-CSV $CSVfilepath | %{

    write "###############################" | Out-File -Append $logfile
    write "" | Out-File -Append $logfile

    dnscmd $server /recordadd $_."Zonename" $_."octet" PTR $_."FQDN" | Out-File -Append $logfile
    if($LASTEXITCODE -eq 0){
                            Write-Host "$($_."FQDN") added successfully on $($_."Zonename")" -ForegroundColor Green
                            Write "$($_."FQDN") added successfully on $($_."Zonename")" | Out-File -Append $logfile
                           }
    else{
         Write-Warning "$($_."FQDN") failed to be added on $($_."Zonename") -EXITCODE:$LASTEXITCODE"
         Write "$($_."FQDN") failed to be updated for $($_."Zonename")" | Out-File -Append $logfile
        }
    write "" | Out-File -Append $logfile
    write "###############################" | Out-File -Append $logfile
                           }

write-host "A log file has been creatred in $logfile" -ForegroundColor Yellow

}


function Delete-PTRrecord {

[CmdletBinding()]
param(

    [parameter(Mandatory=$True,HelpMessage="Server name to add the record")]
    [string]$Server,

    [parameter(Mandatory=$True,HelpMessage="Filepath of the CSV")]
    [string]$CSVfilepath
)

$logfile = "c:\temp\Delete_PTRrecords.txt"

Import-CSV $CSVfilepath | %{

    write "###############################" | Out-File -Append $logfile
    write "" | Out-File -Append $logfile

    dnscmd $server /recorddelete $_."Zonename" $_."octet" PTR /f | Out-File -Append $logfile
    if($LASTEXITCODE -eq 0){
                            Write-Host "$($_."octet").$($_."Zonename") deleted successfully" -ForegroundColor Green
                            Write "$($_."octet").$($_."Zonename") deleted successfully" | Out-File -Append $logfile
                           }
    else{
         Write-Warning "$($_."octet").$($_."Zonename") failed to delete" -EXITCODE:$LASTEXITCODE
         Write "$($_."octet").$($_."Zonename") failed to delete" | Out-File -Append $logfile
        }
    write "" | Out-File -Append $logfile
    write "###############################" | Out-File -Append $logfile

                           }

write-host "A log file has been creatred in $logfile" -ForegroundColor Yellow

}
