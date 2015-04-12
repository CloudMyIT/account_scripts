$FirstName = "First"
$MiddleInital = "M"
$LastName = "Last"
$SAMName = "fmlast"
$OtherName = "NickName"
$OU = "OU=user,OU=accounts,DC=example,DC=com"
$Domain = "example.com"
$TempPass = "P@22word"

#$AdminCredentials = Get-Credential "$Domain\SERVICE_ACCT"

$NewUser = New-ADUser `
	-GivenName $FirstName `
	-Initials $MiddleInital `
	-Surname $LastName `
	-Name "$FirstName $MiddleInital. $LastName" `
	-DisplayName "$FirstName $MiddleInital. $LastName" `
	-OtherName $OtherName `
	-SamAccountName $SAMName `
	-HomeDirectory "\\$Domain\profiles\$SAMName" `
	-ProfilePath "\\$Domain\profiles\$SAMName\_sys\$SAMName.pds" `
	-HomeDrive "U:" `
	-Path $OU `
	-AccountPassword (Read-Host -AsSecureString $TempPass) `
	-AllowReversiblePasswordEncryption $false `
	-CannotChangePassword $false `
	-ChangePasswordAtLogon $true `
	-Enabled $true `
	-PassThru $true `
	-PasswordNeverExpires $false `
	-PasswordNotRequired $false `
	-SmartcardLogonRequired $false `
	-TrustedForDelegation $false `
	-Type "User"
	
#-AccountExpirationDate <System.NullableSystem.DateTime> `
#-Credential $AdminCredentials `


 
#Define FileSystemAccessRights:identifies what type of access we are defining, whether it is Full Access, Read, Write, Modify 
$FileSystemAccessRights = [System.Security.AccessControl.FileSystemRights]"FullControl" 
 
#define InheritanceFlags:defines how the security propagates to child objects by default 
#Very important - so that users have ability to create or delete files or folders in their folders 
$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit" 
 
#Define PropagationFlags: specifies which access rights are inherited from the parent folder (users folder). 
$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None 
 
#Define AccessControlType:defines if the rule created below will be an 'allow' or 'Deny' rule 
$AccessControl =[System.Security.AccessControl.AccessControlType]::Allow  

#define a new access rule to apply to users folfers 
$NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule ` 
    ("$Domain\$SAMName", $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)  
 
 
#set acl for each user folder
#First, define the folder for each user 
$userfolder = "\\$Domain\profiles\$SAMName"

#Get the current ACL for the folder
$currentACL = Get-ACL -path $userfolder 

#Add this access rule to the ACL 
$currentACL.SetAccessRule($NewAccessrule) 

#Write the changes to the user folder 
Set-ACL -path $userfolder -AclObject $currentACL 