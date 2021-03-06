<#
.NOTES
    File Name : Add-CsContactPhoto.ps1
    Author : xilxyu
    Technet Page : social.technet.microsoft.com/profile/xilxyu
    Prerequisites : Lync Module, Lync administrator authority that can run *-CsUserData command.    
.SYNOPSIS
    Use this scirpt to bulk import contacts into specified Lync users' contact list,
    & use it for self responsibility.
    USERS TO BE UPDATED SHOULD HAVE SIGNED INTO LYNC AT LEAST ONCE BEFORE EXCUTING THIS SCRIPT
.DESCRIPTION
    Add-CsContactPhoto can be used to import predefined contacts & groups into a Lync 2013
    user's contact lists. By specifying a template user or a template file that contains
    contacts information, and providing a list that contains users to be updated, this script
    will automatically import contacts, and won't override users' exisiting contacts. 

    Though, there're some LIMITATIONS:
    See the script download page.
.PARAMETER userCsv    
    File path of a csv file that stores users to be update. The csv file should
    be in this format:
        userSip,poolFqdn
        user1@sip.com,pool1.sip.com
        user2@sip.com,pool2.sip.com
    where userSip is the sip address of user, and poolFqdn is where user resides.
.PARAMETER tplPath
    Path of the template file, or a template user's sip address. When a file path
    is specified, it should be in this format:
        groupName,userSip
        Group A,user1@sip.com
        Group B,user2@sip.com
        ~,user3@sip.com
    where groupName is the contact group that contact will be added to. If contact
    has no group, specify "~" instead.
.PARAMETER poolFqdn
    The pool where the template user resides. Specify this parameter when tplPath
    is user's sip address.    
.PARAMETER folder
    A folder used to hold temporary files.
.PARAMETER reserveXml
    Use this option to leave updated user datas after executing this script. 
    By default, all temporary files will be removed after executing.
.PARAMETER noConfiem
    Use this option to skip confirmation before updating user data.
    By default, you have to confirm each user's updating process.
.PARAMETER noBackup
    Use this option if you don't want to back up original user data.
    I recommend a backup in case of undiscovered issues.
.EXAMPLE
    .\Add-CsContact.ps1 -userCsv C:\tmp\users.csv -tplPath C:\tmp\tpl.csv -folder C:\tmp
.EXAMPLE
    .\Add-CsContact.ps1 -userCsv C:\tmp\users.csv -tplPath tplUser@sip.com -poolFqdn tplPool.sip.com -folder c:\tmp
.EXAMPLE
    .\Add-CsContact.ps1 -userCsv C:\tmp\users.csv -tplPath C:\tmp\tpl.csv -folder C:\tmp -reverseXml
.EXAMPLE
    .\Add-CsContact.ps1 -userCsv C:\tmp\users.csv -tplPath C:\tmp\tpl.csv -folder C:\tmp -noConfirm -noBackup
#>

Param(
[Parameter(Mandatory=$true)][string]$userCsv,
[Parameter(Mandatory=$true)][string]$tplPath,
[Parameter(Mandatory=$false)][string]$poolFqdn,
[Parameter(Mandatory=$true)][string]$folder,
[Parameter(Mandatory=$false)][switch]$reserveXml,
[Parameter(Mandatory=$false)][switch]$noConfirm,
[Parameter(Mandatory=$false)][switch]$noBackup
)

#parameter check
if(($tplPath.Length -lt 1) -and ($poolFqdn.Length -lt 1)){
    $Host.UI.WriteErrorLine("please specify at least one of the following:`n`t-tplPath template file path`n`tOR -tplPath userTemplate@sip.com -poolFqdn poolfqdn.sip.com");
    exit;
}

#import lync module
    if(-not (Get-Module -Name "Lync")){
        if(Get-Module -Name "Lync" -ListAvailable){
            Import-Module -Name "Lync";
            Write-Host "Loading Lync Module";
        }
        else{
            Write-Host "Lync Module does not exist, plz check your environment.";       
            exit;     
        }        
    }

# function definitaion starts//////////////////////////////
function finish([string]$msg){
    $Host.UI.WriteErrorLine($msg);
    exit;
}

function NewTplItem($gpName,$uSip){
    $prop = @{"gpName"=$gpName;"userSip"=$uSip};
    $item = New-Object -TypeName PSObject -Property $prop;
    return $item;
}

function NewUserItem($uSip,$fqdn){
    $prop = @{"userSip"=$uSip;"poolFqdn"=$fqdn};
    $item = New-Object -TypeName PSObject -Property $prop;   
    return $item;
}

function NewContactItem($uSip,$uGroup,$state){
    [string[]]$gArr = $uGroup -split " ";
    $prop = @{"sip"=$uSip;"group"=$gArr;"state"=$state};
    $item = New-Object -TypeName PSObject -Property $prop;   
    return $item;
}

function GetUserXml($uItem){
    $uSip = $uItem.userSip;
    $pool = $uItem.poolFqdn;

    $xmlPath = $folder + "\" + $uSip + ".xml";
    $xmlBakPath = $folder + "\" + $uSip + ".bak.xml";
    
    if (Test-Path $xmlPath){Remove-Item $xmlPath;}    
    Export-CsUserData -PoolFqdn $pool -FileName $xmlPath -UserFilter $uSip -LegacyFormat -ErrorVariable +lyncerr -ErrorAction SilentlyContinue;
    #sip or fqdn is wrong
    if ($lyncerr.Count -gt 0){
        $lyncerr.Clear();
        return "";
    }

    if($noBackup -eq $false){
        if (Test-Path $xmlBakPath){Remove-Item $xmlBakPath;}  
        Copy-Item $xmlPath $xmlBakPath;
    }
    return $xmlPath;
}

function NewGroupItem($gIdx,$gName,$state){
    $prop = @{"index"=$gIdx;"name"=$gName;"state"=$state};
    $item = New-Object -TypeName PSObject -Property $prop;   
    return $item;
}

function GetGroupList($xmlGroups){
    $groupList = @();
    foreach ($group in $xmlGroups.ChildNodes){
        $groupList += NewGroupItem $group.Number $group.DisplayName 1;
    }
    return $groupList;
}

function GetContactList($xmlContacts){
    $contactList = @();
    #works even if Contacts is <Contacts></Contacts>
    foreach ($contact in $xmlContacts.ChildNodes){
        $contactList += NewContactItem $contact.Buddy $contact.Groups 1;
    }
    return $contactList;
}

function GetGroupIndex($gpName,$gpList){
    foreach($gp in $gpList){
        if($gpName -eq $gp.name){ return [int]$gp.index; }
    }
    return -1;
}

function GetGroupName($Idx,$gpList){
    foreach($gp in $gpList){
        if($Idx -eq $gp.index){ return $gp.name; }
    }
    
    return "";
}

function checkPath($fPath,$paraName){
    if ($fPath.Length -gt 0){
        $folderExists = Test-Path $fPath;
        if($folderExists -eq $false){
            finish "Error: Path $fPath does not exist, please check your input.";
        }
    }
    else{
        finish "Error: please make sure you have specified correct path for $paraName";
    }
}

function XmlToTpl($contacts,$groups){
    $template = @();
    foreach ($contact in $contacts){
        #skip tel-No. contact & non-buddy contact
        if (($contact.sip -eq $null) -or ($contact.sip.Length -lt 1) -or ($contact.sip.Contains(";"))){
            continue;
        }              

        $isCustomGroupExist = $false;
        foreach ($gp in $contact.group){
            $gpName = GetGroupName $gp $groups;
            if (($gpName -eq "~") -or ($gpName -eq "Pinned Contacts")){
                continue;
            }
            else{
                $template += NewTplItem $gpName $contact.sip;
                $isCustomGroupExist = $true;
            }
        }
        if (!$isCustomGroupExist){
            $template += NewTplItem "~" $contact.sip;
        }
    }

    return $template;
}

function GetXmlTemplate($uSip,$fqdn){
    $uItem = NewUserItem $uSip $fqdn;

    $userXml = GetUserXml $uItem;
    if ($userXml -eq ""){
        finish "Error: Can`'t get template user $uSip information!";
    }

    $user = [xml](Get-Content $userXml);

    $homedResource = $user.HomedResources.HomedResource;
    if ($homedResource -eq $null){
        Remove-Item $userXml;
        finish "Error: please verify template user $uSip contact list";
    }
    if ($homedResource.ContactGroups -eq $null){
        Remove-Item $userXml;
        finish "Error: please verify template user $uSip contact list";
    }

    $groups = GetGroupList $homedResource.ContactGroups;

    $contacts = @();
    if ($homedResource.Contacts -eq $null){
        Remove-Item $userXml;
        finish "Error: please verify template user $uSip contact list";
    }
    else{
        $contacts = [object[]](GetContactList $homedResource.Contacts);
        if ($contacts -eq $null){
            Remove-Item $userXml;
            finish "Error: please verify template user $uSip contact list";
        }
    }

    $template = XmlToTpl $contacts $groups;
    
    Remove-Item $userXml;
    return $template;
}

function LoadCsv($csv,$props){
# check csv file existence, structure etc.
# return csv data if load success
    checkPath $csv "csv file";

    #load csv file
    $csvData = Import-Csv $csv;
    if ($csvData -eq $null){
        finish "Error: no contact info exists";
    }

    $colNames = $csvData | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"};
    if ($colNames.Count -ne $props.Count){
        finish "Error: csv file structure not match!";
    }

    [string[]]$colStr = @($colNames[0].Name,$colNames[1].Name);
    foreach ($prop in $props){
        if( !$colStr.Contains($prop) ){
            finish "Error: csv file structure not match!";
        }
    }

    return $csvData;
}

function GetCsvTemplate($csv){
    $csvData = LoadCsv $csv @("groupName","userSip");

    $template = @();
    foreach($line in $csvData){
        $c = NewTplItem $line.groupName $line.userSip;
        $template += $c;
    }

    return $template;
}

function GetTemplate($tplPath,$poolFqdn){
# $tplPath has 2 patterns: file path or sip address
# calls GetXmlTemplate or GetCsvTemplate
# use $poolFqdn only when $tplPath is a sip address

    if ($tplPath.Length -gt 1){
        
        if ($tplPath.EndsWith(".csv",1)){
        #csv template
            checkPath $tplPath "tplPath";
            $template = GetCsvTemplate $tplPath;
        }
        elseif ($tplPath.Contains("@")){
        #sip template
            $uSip = $tplPath;
            $pool = $poolFqdn;
            $template = GetXmlTemplate $uSip $pool;
        }
        else{ 
            finish "Error: please make sure required parameters are correct"; 
        }
        
    }
    else{
        finish "Error: please make sure required parameters are correct";
    }

    return $template;
}

function UpdateGroupList($groupList,$template){
    foreach ($item in $template){
        $found = $false;
        foreach ($currGroup in $groupList){
            if ($item.gpName -eq $currGroup.name){
                $found = $true;
                break;
            }
        }
        if (!$found){
            $created = $false;
            $idx = 2;
            do{
                $idx++;
                if ((GetGroupName $idx $groupList) -eq ""){
                    $created = $true;
                    $groupList += NewGroupItem $idx $item.gpName 0;                    
                }
            }while (!$created)            
        }
    }

    return $groupList;
}

function isGroupExist($idx,$gpArr){
    foreach($gpIdx in $gpArr){
        if($gpIdx -eq $idx){ return $true; }
    }
    return $false;
}

function UpdateContactList($contactList,$groupList,$template){

    foreach ($contact in $template){
        $isnewContact = $true;
        foreach ($item in $contactList){
            if ($contact.userSip -eq $item.sip){
            #update contact
                $isnewContact = $false;
                [int]$idx = GetGroupIndex $contact.gpName $groupList;
                if(($idx -ne 2) -and !(isGroupExist $idx $item.group)){
                    $item.group += [string]$idx;
                    if ($item.state -eq 1){$item.state = 2;}
                }
            }
        }
        if ($isnewContact){
            #create new contact            
            [int]$idx = GetGroupIndex $contact.gpName $groupList;
            if(($idx -ne 1) -and ($idx -ne 2)){
                $contactList += NewContactItem $contact.userSip "1 $idx" 0;
            }
            else{
                $contactList += NewContactItem $contact.userSip "1" 0;
            }
        }
    }

    return $contactList;
}

function AddGroupXml($gp,$gpListXml){
    $gpXml = $user.CreateElement('ContactGroup',$homedResource.NamespaceURI);
    $gpXml.SetAttribute('Number',$gp.index);
    $gpXml.SetAttribute('DisplayName',$gp.name);
    $gpXml.SetAttribute('ExternalUri','');

    $newNode = $gpListXml.AppendChild($gpXml);
}

function AddContactXml($contact,$contactListXml){
    $contactXml = $user.CreateElement('Contact',$homedResource.NamespaceURI);
    $contactXml.SetAttribute('ExternalUri','');
    $contactXml.SetAttribute('DisplayName','');
    $contactXml.SetAttribute('Groups',[string]$contact.group);
    $contactXml.SetAttribute('SubscribePresence','1');
    $contactXml.SetAttribute('Buddy',$contact.sip);

    $newNode = $contactListXml.AppendChild($contactXml);
}

function UpdateContactXml($contact,$contactListXml){
    foreach ($item in $contactListXml.ChildNodes){
        if ($contact.sip -eq $item.Buddy){
            $item.SetAttribute('Groups',[string]$contact.group);
            break;
        }
    }
}

function ProcessUserXml($uItem,$template){

    $userXml = GetUserXml $uItem;
    if ($userXml -eq ""){
        $Host.UI.WriteWarningLine("Can`'t get $($uItem.userSip) information");
        return "";
    }
    $user = [xml](Get-Content $userXml);
    
    $homedResource = $user.HomedResources.HomedResource;
    if ($homedResource -eq $null){
        $Host.UI.WriteWarningLine("please verify $($uItem.userSip) has signed in at least once");
        Remove-Item $userXml;
        return $null;
    }
    if ($homedResource.ContactGroups -eq $null){
        $Host.UI.WriteWarningLine("please verify $($uItem.userSip) has signed in at least once");
        Remove-Item $userXml;
        return $null;
    }

    $groupList = GetGroupList $homedResource.ContactGroups;
    $groupList = UpdateGroupList $groupList $template;

    $contactList = @();
    if ($homedResource.Contacts -eq $null){
        #Add Contacts ChildNode
        $contacts = $user.CreateElement('Contacts',$homedResource.NamespaceURI);
        $ret = $homedResource.InsertAfter($contacts,$homedResource.FirstChild);
    }
    else{
        $contactList = [object[]](GetContactList $homedResource.Contacts);
        if ($contactList -eq $null) { $contactList = @(); }
    }
    
    $contactList = UpdateContactList $contactList $groupList $template;

##update user xml
#update groups
    foreach ($gp in $groupList){
        if ($gp.state -eq 0){
        #add new group
            AddGroupXml $gp $homedResource.ContactGroups;
        }
    }
#update contacts
    foreach ($contact in $contactList){
        #skip adding self as contact
        if ($contact.sip -eq $uItem.userSip) { continue; }

        if ($contact.state -eq 0){
        #add new contact
        #in case that contacts is empty, using Item() method
            AddContactXml $contact $homedResource.Item("Contacts");
        }
        elseif ($contact.state -eq 2){
        #update exist contact
            UpdateContactXml $contact $homedResource.Contacts;
        }
    }

    $user.Save($userXml);
    return $userXml;
}

function GetUserList($csv){

    $csvData = LoadCsv $csv @("userSip","poolFqdn");

    $uList = @();
    foreach($line in $csvData){
        $u = NewUserItem $line.userSip $line.poolFqdn;
        $uList += $u;
    }

    return $uList;
}

function UpdateUser($xmlName,$uItem){
    Update-CsUserData -FileName $xmlName -Confirm:(!($noConfirm));
    Write-Host "Updating $($uItem.userSip) contact list finished!";
    
    if($reserveXml -eq $false){
        Remove-Item $xmlName;
    }    
}

function UpdateUserContact($uList,$template){

    foreach ($uItem in $uList){
                
        $userXml = ProcessUserXml $uItem $template;
        if (($userXml -ne $null) -and ($userXml -ne "")){
            UpdateUser $userXml $uItem;
        }
    }
    return 0;
}


# function definitaion over/////////////////////////////

# main part starts+++++++++++++++++++++++++++++++
#

#path existence check
checkPath $userCsv "userCsv";
checkPath $folder "folder";

# 1:get & validate contact list template, store to $template
# $template is a collection of contact-type object
# contact object has 2 properties: gpName & userSip
$template = GetTemplate $tplPath $poolFqdn;

# 2:get list of user to be updated, store to $uList
# $uList is a collection of user-type object
# user object has 2 properties: userSip & poolFqdn
$uList = GetUserList $userCsv;

# 3:update users' contact list with template
$ret = UpdateUserContact $uList $template;

# 4:over
Write-Host "all users are updated!";

#
# main part over+++++++++++++++++++++++++++++++
