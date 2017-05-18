<#  
.SYNOPSIS
   	Update Epiq All Distribution List

.DESCRIPTION  
    This script will read list of FTE Users from Workday, verify that the user exists in AD, and see if it is 
    already a member of the Epiq All DL. If not it will add it

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/3/2017 - First iteration - kbennett 
        
    Rights Required		    : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Reports for users not in AD
                            : Reports for users with IRISDS.com Email
                            : Report for users with no email
                            : Report for users with non company email
             
.FUNCTIONALITY
    Update Distibution List, Check user exists
#>

# Variables
$ImportFile = "C:\Temp\FTEList.csv"
$DomainController = "P016ADSAMDC01.amer.EPIQCORP.COM"
$GroupName = "Epiq-All@Epiqsystems.com"
$UserCredential = Get-Credential

# Function import list of users
Function ImportList 
{
    $test = Test-Path $ImportFile
    If ($test -eq $true)
    {
        $script:import = Import-csv $ImportFile
    }
    Else
    {
        Write-Warning "Something went Wrong: File is missing at $ImportFile"
        Break
    }
}

# Function Check user exists
Function CheckUser
{
    foreach ($Name in $import)
    {
        $script:UserInfo = $Name."Email Address"
        # Only checks if Email address is epiqsystems.com
        If ($UserInfo -Like "*epiqsystems.com" -or $UserInfo -like "*irisds*")
        {
        $script:CheckUser = Get-ADuser -Filter "EmailAddress -like '$UserInfo'" -Properties Name,EmailAddress -Server $DomainController
            If ($CheckUser -eq $Null)
            { 
                Write-host $Name.Worker "Doesn't Exist in AD - Skipping" -foregroundcolor Red
                Add-Content c:\temp\Epiq-AllUserDoesntExist.txt $Name.Worker
            } 
            Else 
            { 
                CheckDL ($UserCredential) 
            }
        }
        Else
        {
            Write-host "Email address is" $UserInfo
            Add-Content c:\temp\Epiq-AllBadUserEmailAddress.txt $UserInfo
        }
    }
}

# Function Check User in DL
Function CheckDL
{
    $members = Get-ADGroupMember -Identity $GroupName -Recursive | Select -ExpandProperty Name
    If ($members -contains $CheckUser.Name)
    {
        Write-Host $CheckUser.EmailAddress "exists in the group"
    } 
    Else 
    {
        Write-Host $CheckUser.EmailAddress "Being Added to group" $GroupName -foregroundcolor Yellow
        Add-Content c:\temp\Epiq-AllUserAdded.txt $CheckUser.EmailAddress
        AddUser ($UserCredential)
    } 
}

# Function Add new user to DL
Function AddUser
{
    Add-ADGroupMember -Identity $GroupName -Members $CheckUser.SamAccountName -Credential $UserCredential
}

# Begin of Script
ImportList ($ImportFile)
CheckUser ($UserCredential)