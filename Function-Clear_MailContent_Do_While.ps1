Import-Module MSOnline
$ocred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $ocred -Authentication Basic -AllowRedirection
Import-PSSession $Session

# Loops Through Process so you can repeat it several times with Different Users
Do 
{
    $user = Read-Host -Prompt 'What user do you want to delete Content?'

    # if name is not null run command
    If($user) 
    {
        Search-Mailbox -Id $user -DeleteContent -force
    } 
    # invalid name .. 
    Else 
    {
        Write-Output "No username was entered."
    }
    
    $again = Read-Host 'Do you want to do it again? (Y/N)'

} 

While ($again -eq 'Yes' -or $again -eq 'Y' -or $again -eq 'y')

Exit-PSSession $Session
