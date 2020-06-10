 <#

 Look and see if they already have a value in Attribute13
 If they do is it correct
 If it is correct skip
 If they do have a value but it is not correct then blank out and set correct
 If they dont have a value then add it

 Do this for the second OU

 #>

 
 #Variables
 $OU = "OU=Users,OU=domain,OU=domain,DC=amer,DC=domain,DC=COM"
 $DomainController = "server.amer.domain.COM"

 # Do a forloop here to get OU in array
 
 $user = Get-ADUser -SearchBase $ou -filter * -Properties CanonicalName -server $DomainController 

  ForEach ($one in $user) {
    #write-host $one.DistinguishedName
    # do an ADObject Get here to get Attribute13
    # do a IF here on Attribute 13 to only procced if there is no attribute
    Set-ADObject -Identity $one.DistinguishedName -add @{extensionAttribute13="domain.com"} -Credential $UserCredential -server $DomainController
    Update-Recipient $one.SamAccountName -DomainController $DomainController
    #Set-Mailbox $one.SamAccountName -EmailAddressPolicyEnabled $False -DomainController $DomainController
    #Set-Mailbox $one.SamAccountName -EmailAddressPolicyEnabled $True -DomainController $DomainController
    #Else here to exit if Attribute is already present
 }


 

 
