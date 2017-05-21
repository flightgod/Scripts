<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages.
#> 




Function GetChoice
{
    #Prompt message
    $Caption = "Delete Confirming."
    $Message = "Do you want to delete the unused user folder?"
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]]`
    @("&Yes","&No")
    [Int]$DefaultChoice = 0
    $ChoiceRTN = $Host.UI.PromptForChoice($Caption, $Message, $Choices, $DefaultChoice)
    Switch ($ChoiceRTN)
    {
        0 	{$True}
        1  	{break}
    }
}

Function isException($Foldername) 
{
    Switch($Foldername)
	{
		"All Users"
		{ $True} 
		"Default User" 
		{ $True }
		"Default" 
		{ $True }
		"LocalService" 
		{ $True }
		"NetworkService" 
		{ $True } 
		"Administrator" 
		{ $True }
		"Adm-Pass" 
		{ $True }
		"AppData" 
		{ $True }
		"Classic .NET AppPool" 
		{ $True}
		"Public" 
		{ $True}
		default 
		{ $False}
	}
}

#Get user folder
If(Test-Path -Path "C:\Documents and Settings\")
{
	$UserParentFolder = "C:\Documents and Settings\"
}

If(Test-Path -Path "C:\Users\")
{
	$UserParentFolder = "C:\Users\"
}
#set unused days
$PeriodDays = 365 

$Result = @()
#get all user folders
$userFolders = Get-ChildItem -Path $UserParentFolder 

Foreach($Folder in $userFolders)
{
	#get lastaccesstime
	$LastAccessTime = $Folder.LastAccessTime
	#Get date
	$CurrentDate = Get-Date 
	$Tim = New-TimeSpan $LastAccessTime $CurrentDate 
	$Days = $Tim.days
	#Compare current date and lastaccesstime 
    If((isException $Folder.Name )-eq $false -and  ($Days -gt $PeriodDays) )
	{
	$temp = New-Object  psobject -Property @{
		"FileName" = $Folder.FullName;
		"LastAccessTime" = $Folder.LastAccessTime;
		"UnusedDays" = $Days
		}
		$Result += $Temp
	}
	
}
If($Result)
{
	$Result
	If(GetChoice)
	{
		foreach($Folder in $Result)
		{
			try
			{
				#Remove user folder
				$path = $Folder.FileName 
				cmd.exe /c "RD /S /Q `"$path`""
				If((test-path $path) -eq $false)
				{
					Write-Host "Delete unused user folder $path successfully!"
				}
			
			}
			Catch
			{
				Write-Error $_
				
			}
		}
	}
	
}