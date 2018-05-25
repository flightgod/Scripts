$import = "C:\temp\SharedMailboxes.csv"
$data = Import-Csv $import

$ServiceAccount = svc_CRMExchange@epiqsystems.com


ForEach ($entry in $data){

Get-Mailbox $entry.'Email Address' | Add-MailboxPermission -User CRMSYS_EXCHANGE -AccessRights FullAccess -InheritanceType All

}