
'Specific value
Var_Value="*.kk.com"
On Error Resume Next

Const HKEY_CLASSES_ROOT		= &H80000000
Const HKEY_CURRENT_USER		= &H80000001
Const HKEY_LOCAL_MACHINE	= &H80000002
Const HKEY_USERS			= &H80000003
Const HKEY_CURRENT_CONFIG	= &H80000005

Dim HKey
HKey=HKEY_CURRENT_USER
strCheck = "Software\Microsoft\Windows\CurrentVersion\Internet Settings"

checkExists HKey,strCheck,Var_Value

function checkExists(HKey,strCheck,Var_Value)
    Dim strValue,found
	found=false
	Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
	If oReg.EnumKey(HKey, strCheck, "", "") = 0 Then
		strValue=getSubValue (HKey,strCheck)
		'wscript.echo "Success" & strValue 
		arr_val=split(strValue,";")
		for each str_val in arr_val
		    if str_val = Var_Value then
			    found=true
				'wscript.echo "str_val:" & str_val
				exit for
			end if
		Next

		if found=false then
		    finaValue= Var_Value & ";" & strValue 
			WriteReg "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyOverride", finaValue, "REG_SZ"
		end if
	Else
		'wscript.echo "failed"
		wscript.quit
	End IF

end function

Function getSubValue (HKey,strCheck)
	Dim arrValueNames
	Dim arrTypes
	Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
	'oReg.EnumKey HKey, strCheck, arrSubKeys
	oReg.EnumValues HKey, strCheck, arrValueNames, arrTypes
    
	For Each strValueName In arrValueNames
		if strValueName = "ProxyEnable" then
			 oReg.GetDWORDValue HKey,strCheck,strValueName,strValueEnable 
			 if strValueEnable <> 1 then
                 wscript.quit
			 end IF
			 'Wscript.Echo "Current WSH Trust Policy Value: " & strValue 		
		end if
		if strValueName = "ProxyOverride" then
			 'wscript.echo "returned " & strValueName
			 oReg.GetStringValue HKey,strCheck,strValueName,strValue 
			 getSubValue=strValue	
		end if
	 Next
End Function


Function WriteReg(RegPath, Value, RegType)
      'Regtype should be “REG_SZ” for string, “REG_DWORD” for a integer,…
      '”REG_BINARY” for a binary or boolean, and “REG_EXPAND_SZ” for an expandable string
      Dim objRegistry
      Set objRegistry = CreateObject("Wscript.shell")

      objRegistry.RegWrite RegPath, Value, RegType 
      
End Function

