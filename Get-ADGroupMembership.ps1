<# 
Export_UserGroupMem.ps1
Created By Josh Ancel 11/23/2015

Script is to export Multiple AD Group Memberships and export to CSV
#>
# Import-Module
Import-Module ActiveDirectory

#Load List Function definition
Function Load-List
{

$global:list = @() ; Write-host "Enter Groups:" ;do { $line = (Read-Host " ") ; if ($line -ne '') {$global:list += $line}} until ($line -eq '')

}

# Entering users
Load-List


#CSV Path Input
Write-host "Enter PATH Location where you would like the CSV export to reside.[Example: c:\temp\temp.csv]:"
$Path = (Read-Host " ")

#Take each user and export it to CSV
Foreach($Group in $List)
        {
			 Get-ADGroupMember $Group -Recursive | Export-Csv $Path -Append
		}
#EOF


Function GetGroupOfGroups {

$list =@(Get-ADGroup -Filter * |? {$_.Name -like "DL-DB0*"} | Select Name)

Foreach($Group in $List)
        {
			$Members = @(Get-ADGroupMember $Group.Name -Recursive | Select Name)
            $Group.Name = $RealName
            $Members + $RealName | Export-Csv c:\TEmp\GroupMemberExport.csv -Append

		}

}
#EOF


Foreach($Group in $list)
        {
        $FullList = @(
			$Members = @(Get-ADGroupMember $Group.Name -Recursive | Select Name)
            
            $Members + $Group | Ft -HideTableHeaders
            )
		}

