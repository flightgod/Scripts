#Update password

$NewPassword = ""
$Servers = @(`
    "P016ADSACDC01.apcust.local",`
    "P016ADSCCDC01.cacust.local",`
    "Q061ADSDQDC01.dqscust.local",`
    "P016ADSECDC01.eucust.local",`
    "P016ADSUCDC01.uscust.local",`
    "p016adsamdc02.amer.epiqcorp.com",`
    "amer.epiqcorp.com",`
    "apac.epiqcorp.com",`
    "euro.epiqcorp.com",`
    "epiqcorp.com")

If ($UserName -eq $null){
    $UserCredentials = Get-Credential
    }

$UserName = Read-Host "Enter UserName to change password"
$NewPassword = Read-Host "Enter the new Password"
Foreach ($DC in $Servers){
    try {
        Set-ADAccountPassword $UserName `
            -Reset `
            -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force) `
            -Server $DC `
            -Credential $UserCredentials `
            -whatif
        Write-Host "RESET password for" $UserName "on $DC"-ForegroundColor Green
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host $ErrorMessage -ForegroundColor Red
    }
}