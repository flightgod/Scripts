# Variables 
$FirstName = @()
$LastName = @()
$Contact = @()
$string = @()
$ContactOU = "OU=Contacts,OU=DTI,DC=amer,DC=EvilCorpCORP,DC=COM"

$NewList = @()

If ($wardCreds.UserName -like "AMER\ward_*"){
    Write-Host "Already have Creds" -foregroundColor Green
    } Else {
    $wardCreds = Get-Credential
}


Function GetContactInfo { 
# Getting the contact info
    # $Script:Contact = Get-ADObject -SearchBase $ContactOU -Properties * -Filter {DisplayName -like "Bradley Lanius"} | Select DisplayName, givenName, sn, ObjectGUID
    # $Script:Contact = Get-ADObject -SearchBase $ContactOU -Properties * -Filter {DisplayName -like "S A R*"} | Select DisplayName, givenName, sn, ObjectGUID
     $Script:Contact = Get-ADObject -SearchBase $ContactOU -Properties * -Filter * | Select cn, DisplayName, givenName, sn, ObjectGUID, telephoneNumber, Mobile
}
 
 Function FindNullNames {
 # Finding First or Last Name with Null value
    ForEach ($item in $Contact){
        If ($Item.sn -eq $NULL){
            IF ($Item.givenName -eq $Null) {
                $string = $Item.DisplayName
                $firstName = $string.split(" ")[0]
                $lastName = $string.split(" ")[1]
                $NewDisplayName = "$lastname, $firstname"
                Write-Host "User" $string "Doesnt have value in SN or GN" -ForegroundColor Red
                $Script:NewList += $item.DisplayName
                #Here is where I write to SN and GN and Change DisplayName to $NewDisplayName
                Set-ADObject -Identity $Item.ObjectGUID -Add @{sn=$LastName} -Credential $WardCreds
                Set-ADObject -Identity $Item.ObjectGUID -Add @{givenName=$FirstName} -Credential $WardCreds
                Set-ADObject -Identity $Item.ObjectGUID -Replace @{DisplayName=$NewDisplayName} -Credential $WardCreds
                Write-Host "Setting FirstName to:" $firstName "and LastName to:" $lastName "And DisplayName to:" $NewDisplayName -ForegroundColor Cyan
            } Else {
                Write-Host "Skipping since there is a value in one of the SN or GN"
            }
        } Else {
            Write-Host "User had value in Both SN and giveName" $Item.DisplayName "It is being skipped for now"-ForegroundColor Green
        }
    }
}

Function FindNullPhoneNumbers {
$MissingList = 0
    ForEach ($item in $Contact){
        If ($Item.telephoneNumber -eq $NULL){
            Write-Host "TelephoneNumber is Blank for " $Item.cn
            $MissingNumbers += $item.cn
        } 
        
    }
 
}
    
GetContactInfo
# FindNullNames ($wardCreds)
FindNullPhoneNumbers
