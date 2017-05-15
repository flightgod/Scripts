$CheckingUN = whoami
IF ($CheckingUN -like "*Ward_*"){
    Write-Host "User is using Elevated Account" -ForegroundColor Green
} Else {
    Write-Host "User is not using Elevated Account, Please login" -ForegroundColor Red
}

If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
    Write-Host "Session already established" -ForegroundColor Green
}
Else {
    Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
}