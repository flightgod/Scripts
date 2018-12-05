#Variables
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$OU = "OU=Contacts,OU=Exchange,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
$date = Get-Date -Format “MM/dd/yyyy"



Function GetInfo {
    $Script:ContactName = Read-Host -Prompt "Enter the Contact Display Name"
    $Script:ExternalAddress = Read-Host -Prompt "Enter Contacts External Email"
    CheckContact
}


Function CreateContact {
    New-MailContact -name $ContactName `
    -ExternalEmailAddress $ExternalAddress `
    -confirm:$false `
    -OrganizationalUnit $ou `
    -DomainController $DomainController
    Logging

}

Function CheckContact {
    Write-Host "Checking for an existing Contact with that Email Address"
    $script:checkingContact = Get-Contact -ResultSize unlimited | Where {$_.WindowsEmailAddress -eq $ExternalAddress}
    If ($checkingContact -eq $Null) {
        Write-Host "No exiting Contact Found, Now creating" -ForegroundColor Green
        CreateContact
    } Else {
        Write-Host "Error: Exiting Contact found with email $ExternalAddress, Halting Script" -ForegroundColor Red 
    }
}

# function for logging who is creating Accounts, going to be used to also send emails to new users
Function Logging {
    $script:info = @()
    $script:LogPath = '\\P054EXGRELY01\Logs\NewMailContactLog.csv'

    $info += New-Object psobject `
                -Property @{`
                    Date=$date; `
                    Name=$ContactName; `
                    Address=$ExternalAddress; `
                    Admin=$env:USERNAME; `
                    Platform=$env:COMPUTERNAME}

    $info | Export-Csv $LogPath -Append -NoTypeInformation

}

#MainBody of Script
GetInfo

# Function to deploy to Jump Boxes
# This is for kbennett to easily deploy script changes, do not run because it probably wont work for you
Function Deploy-Script {
   
    $LocalPath = 'c:\Scripts\Epiq-NewMailContact.ps1'
    $UserCredential = Get-Credential

    New-PSDrive -Name "Scripts0" -PSProvider "FileSystem" -root '\\TS016-EXTOOLS\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts0:'
    Remove-PSDrive -Name "Scripts0"

    New-PSDrive -Name "Scripts1" -PSProvider "FileSystem" -root '\\P054CORUTIL01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts1:'
    Remove-PSDrive -Name "Scripts1"

    New-PSDrive -Name "Scripts2" -PSProvider "FileSystem" -root '\\P054EXGRELY01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts2:'
    Remove-PSDrive -Name "Scripts2"

    New-PSDrive -Name "Scripts3" -PSProvider "FileSystem" -root '\\P054EXGRELY02\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts3:'
    Remove-PSDrive -Name "Scripts3"

}

