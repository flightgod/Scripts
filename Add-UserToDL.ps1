<#  
.SYNOPSIS
   	Add User to Distribution List

.DESCRIPTION  
    This script will Add Users to a DL

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/22/2017 - First iteration - kbennett 
         
    Rights Required		    : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking

             
.FUNCTIONALITY
    Update Distibution List, Check user exists
#>

# Variables
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
$DL = "NameOfDL"

# Connects to Exchange
Function ExchangeConnect 
{
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $Script:UserCredential = Get-Credential
        $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

Function Validate-MailboxList
{
[CmdletBinding()]
param (
    [parameter(mandatory=$true)]
    [AllowEmptyCollection()]
    [array]$list
)
$global:newlist = @()
foreach ($user in $list)
{
if ( (Get-mailbox $user | Measure-Object).count -eq 1 )
{ 
$global:newlist += (Get-mailbox $user).alias
}
else
{
if ( (Get-mailbox $user | Measure-Object).count -eq 0 )
{
	$name = $user
	do
	{
		$pick = $null
		$subuser = read-host "$name did not match any Mailboxes. Enter new mailbox name to search for"
		$matches = get-mailbox *$subuser*
		if ( ($matches | Measure-Object).count -eq 1)
			{
			$pick = $matches.alias
			}
		else
			{
			if ( ($matches | Measure-Object).count -gt 1)
				{
				$pick = $matches | out-gridview -title "Select user" -outputmode single | %{$_.alias}
				}	
			}	
		if ($pick)
			{
			$global:newlist += $pick
			}
		else
			{
			Write-host "No objects selected. Y to search again, N to Skip" 
				if (Ask-YesOrNo)
					{
					Write-host "trying again"
					}
				else
					{
					Write-host "Skipping $user"
					$pick = "Done"
					}
			}
	} until ($pick)
}
}
}
}

Function Validate-UserList
{
[CmdletBinding()]
param (
    [parameter(mandatory=$true)]
    [AllowEmptyCollection()]
    [array]$list
)
$global:newlist = @()
foreach ($user in $list)
{
if ( (Get-mailbox $user | Measure-Object).count -eq 1 )
{ 
$global:newlist += (Get-mailbox $user).alias
}
else
{
if ( (Get-mailbox $user | Measure-Object).count -eq 0 )
{
	$name = $user
	do
	{
		$pick = $null
		$subuser = read-host "$name did not match any users. Enter new user name to search for"
		$matches = get-mailbox *$subuser*
		if ( ($matches | Measure-Object).count -eq 1)
			{
			$pick = $matches.alias
			}
		else
			{
			if ( ($matches | Measure-Object).count -gt 1)
				{
				$pick = $matches | out-gridview -title "Select user" -OutputMode single | %{$_.alias}
				}	
			}	
		if ($pick)
			{
			$global:newlist += $pick
			}
		else
			{
			Write-host "No objects selected. Y to search again, N to Skip" 
				if (Ask-YesOrNo)
					{
					Write-host "trying again"
					}
				else
					{
					Write-host "Skipping $user"
					$pick = "Done"
					}
			}
	} until ($pick)
}
}
}
}

function Load-MBs
{
$global:MBs = @()
Write-host "Enter Mailboxes:"
    do { 
        $line = (Read-Host " ")
        if ($line -ne '') {
            $global:MBs += $line
        }
    }
    until ($line -eq '')
}

# Function to Update DL with UserList
function Add-users 
{
    Foreach ($user in $newList) {
        Add-DistributionGroupMember -Identity $DL -Member $user
    }
}

Load-MBs

Validate-MailboxList $MBs
$MBs = $newlist


$list = @()
Write-host "Enter Users to add to Distribution Group:"
    do { 
    $line = (Read-Host " ")
        if ($line -ne '') {
            $list += $line
        }
    }
    until ($line -eq '')


Validate-UserList $list
$list = $newlist



Write-host "Done: press any key to close"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
