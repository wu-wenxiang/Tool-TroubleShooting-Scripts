$errorcse = "{A2E30F80-D7DE-11d2-BBDE-00C04F86AE3B}"
$cse = $errorcse
$computerpolicy = Get-WMIObject -query "Select * From RSOP_ExtensionStatus Where extensionGUID = '$cse'" -namespace "root\rsop\computer"
if($computerpolicy)
{
$computerpolicy | Remove-WMIObject
}
$usernamespaces = Get-WMIObject -query "Select * From __NAMESPACE" -namespace "root\rsop\user"
foreach ($namespace in $usernamespaces)
{
   $targetn = "root\rsop\user\$($namespace.NAME)"
   $userpolicy = Get-WMIObject -query "Select * From RSOP_ExtensionStatus Where extensionGUID = '$cse'" -namespace $targetn
   if($userpolicy)
   {
      $userpolicy | Remove-WMIObject
   }
}
