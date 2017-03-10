Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Set-AdServerSettings -ViewEntireForest $true
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
$global:MBs = @() ; Write-host "Enter Mailboxes:" ;do { $line = (Read-Host " ") ; if ($line -ne '') {$global:MBs += $line}} until ($line -eq '')
}

Load-MBs

Validate-MailboxList $MBs
$MBs = $newlist


$list = @() ; Write-host "Enter Users to grant Full Access and Send As:" ;do { $line = (Read-Host " ") ; if ($line -ne '') {$list += $line}} until ($line -eq '')


Validate-UserList $list
$list = $newlist


Foreach ($alias in $MBs)
{
#$alias = Read-host "enter mailbox alias"



While ((Get-MailboxPermission $alias | Measure-Object).count -le 2){
Write-host "Waiting for mailbox to be ready"
sleep 30
}
Foreach ($user in $list){
Add-MailboxPermission $alias -Accessrights "FullAccess" -User $user
Get-Mailbox $alias | Add-ADPermission -Extendedrights "Send As" -User $user
}
$permchecklist = $list
$sendaschecklist = $list
do
{ 
Write-host "Waiting for FullAccess permissions to apply."
Sleep 10
$fullperms = (Get-MailboxPermission $alias -ea silentlycontinue | ?{$_.AccessRights -like "FullAccess*"} | select user) -split '[\\}]'| ?{($_ -notlike "@{User*")}
Foreach ($user in $permchecklist){
if ($fullperms -contains $user){
Write-host "User $user has Full Access"
$permchecklist = $permchecklist | ?{$_ -ne $user}
}
else{
Write-host "User $user does not have Full Access; Reapplying Permissions"
Add-MailboxPermission $alias -Accessrights "FullAccess" -User $user
}
}
}until ($permchecklist -eq $null)

do
{ 
Write-host "Waiting for send-as permissions to apply."
Sleep 10
$sendasperms = (Get-Mailbox $alias | Get-ADPermission -ea silentlycontinue | where { ($_.ExtendedRights -like "*Send-As*") -and($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF")} | select user) -split '[\\}]'| ?{($_ -notlike "@{User*")}
Foreach ($user in $sendaschecklist){
if ($sendasperms -contains $user){
Write-host "User $user has Send-As"
$sendaschecklist = $sendaschecklist | ?{$_ -ne $user}
}
else{
Write-host "User $user does not have Send-As; Reapplying Permissions"
Get-Mailbox $alias | Add-ADPermission -Extendedrights "Send As" -User $user
}
}
}until ($sendaschecklist -eq $null)


}

Write-host "Done: press any key to close"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
