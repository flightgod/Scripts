######################################################################################################
#                                                                                                    #
# Name:        Get-MailboxLocations.ps1                                                              #
#                                                                                                    #
# Version:     3.0                                                                                   #
#                                                                                                    #
# Description: Determines the number of databases and regions where Exchange Online mailboxes are    #
#              distributed.                                                                          #
#                                                                                                    #
# Limitations: Table of regions is static and may need to be expanded as Microsoft brings additional #
#              regions online.                                                                       #
#                                                                                                    #
# Usage:       Additional information on the usage of this script can found at the following         #
#              blog post:  http://blogs.perficient.com/microsoft/?p=30871                            #
#                                                                                                    #
# Requires:    Remote PowerShell Connection to Exchange Online                                       #
#                                                                                                    #
# Author:      Joe Palarchio                                                                         #
#                                                                                                    #
# Disclaimer:  This script is provided AS IS without any support. Please test in a lab environment   #
#              prior to production use.                                                              #
#                                                                                                    #
######################################################################################################


$Region = @{}
$Region["NAM"]=@("North America/USA")
$Region["LAM"]=@("Latin America")
$Region["CAN"]=@("Canada")
$Region["EUR"]=@("Europe")
$Region["GBR"]=@("United Kingdom")
$Region["FRA"]=@("France")
$Region["APC"]=@("Asia/Pacific")
$Region["IND"]=@("India")
$Region["JPN"]=@("Japan")
$Region["KOR"]=@("South Korea")
$Region["AUS"]=@("Australia")


Write-Host
Write-Host "Getting Mailbox Information..."

$Mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -ne "DiscoveryMailbox"}

$DatabaseCount = ($Mailboxes | Group-Object {$_.Database}).count

$Mailboxes = $Mailboxes | Group-Object {$_.Database.SubString(0,3)} | Select @{Name="Region";Expression={$_.Name}}, Count

$Regions=@()

# Not pretty error handling but allows counts to add properly when a region could not be identified from the table
$E = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

ForEach ($Mailbox in $Mailboxes) {
  $Object = New-Object -TypeName PSObject
  $Object | Add-Member -Name 'Region' -MemberType NoteProperty -Value $Region[$Mailbox.Region][0]
  $Object | Add-Member -Name 'Mailboxes' -MemberType NoteProperty -Value $Mailbox.Count
  $Regions += $Object
}

$ErrorActionPreference = $E

$TotalMailboxes = ($Regions | Measure-Object Mailboxes -Sum).sum

Write-Host
Write-Host -NoNewline "Your "
Write-Host -NoNewline ("{0:N0}" -f $TotalMailboxes) -ForegroundColor Yellow 
Write-Host -NoNewline " mailboxes are spread across "
Write-Host -NoNewline ("{0:N0}" -f $DatabaseCount) -ForegroundColor Yellow 
Write-Host -NoNewline " databases in "
Write-Host -NoNewline ("{0:N0}" -f $Regions.Count) -ForegroundColor Yellow 
Write-Host " region(s)."
Write-Host
Write-Host "The distribution of mailboxes is shown below:"

$Regions | Select Region, Mailboxes