add-type -AssemblyName PresentationFramework

[xml]$Form = Get-Content "C:\Users\kbennett\source\repos\WpfApp1\WpfApp1\ServiceDesk.xaml"

$NR=(New-Object System.Xml.XmlNodeReader $Form)
$Win=[Windows.Markup.XamlReader]::Load( $NR )


# user Tab Variables
$res = $win.FindName("txtUserResults")
$start = $win.FindName("btnUserGetInfo")
$eid = $win.FindName("txtUserEmployeeID")
$em = $win.FindName("txtUserEMail")
$upn = $win.FindName("txtUserUPN")
$fname = $win.FindName("txtUserFirstName")
$lname = $win.FindName("txtUserLastName")
$clr = $win.FindName("btnClear")
$UN = $win.FindName("txtUserUserName")
$exit = $win.FindName("btnUserExit")
$en = $win.FindName("cbUserEnabled")
# Email Tab Variables
$emUN = $win.FindName("txtEmailUserName")
$emem = $win.FindName("txtEmailEmail")

# On Get Info Click for User Tab
$start.Add_Click({
    If (!$UN.Text){
        [System.Windows.MessageBox]::Show('Error: Username is Blank','Error','OK','Error')
    } Else {
        Clear-Fields
        $UserValues = Get-ADUser $UN.Text -Properties MemberOf,EmployeeID, Mail, SamAccountName, CanonicalName
        $res.text += $UserValues.CanonicalName
        $eid.text += $UserValues.EmployeeID
        $em.text += $UserValues.Mail
        $upn.text += $UserValues.UserPrincipalName
        $fname.text += $UserValues.GivenName
        $lname.text += $UserValues.Surname
        $emUN.text += $UserValues.SamAccountName
        $emem.text += $UserValues.Mail
        If ($UserValues.Enabled = $True){
            $en.ischecked = $True
        } Else {
            $en.ischecked =$false
        }
    }
})

$clr.Add_Click({
$un.text = $Null
Clear-Fields

})

Function Clear-Fields {

$res.Text = $null
$eid.text = $null
$em.text = $null
$upn.text = $null
$fname.text = $null
$lname.text = $null
$emUN.text = $null
$emem.text = $null
$en.ischecked =$false
}

$exit.Add_Click({
  $win.Close()
})


$Win.Showdialog()