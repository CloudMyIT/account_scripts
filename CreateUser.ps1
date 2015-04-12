#* FileName: CreateUser.ps1
#*=============================================================================
#* Script Name: [CMIT Create User]
#* Created: [12APR15]
#* Author: Will G
#* Company: CloudMy.IT LLC
#* Web: http://www.cloudmy.it
#* Reqrmnts:
#* Keywords:
#*=============================================================================
#* Purpose: To automate the process of creating users
#*=============================================================================
#*=============================================================================
#* REVISION HISTORY
#*=============================================================================
#* Date: 
#* Time: 
#* Issue:
#* Solution:
#*
#*=============================================================================

#REQUIRED TO BE PASSED
param([String]$FirstName = "First")
param([String]$MiddleInital = "Middle")
param([String]$LastName = "Last")
param([String]$OtherName = "NickName")
param([String]$TempPass = "P@22word")
#OPTIONAL TO BE PASSED
param([String]$Domain = "cloudmy.it")
param([String]$OU = "OU=user,OU=accounts,DC=cloudmy,DC=it")
param([String]$Quota = "NONE")
param([String]$SAMName = "fmlast")

#This would be the Account that will create the New User
#$AdminCredentials = Get-Credential "$Domain\SERVICE_ACCT"

#*=============================================================================
#* FUNCTION LISTINGS
#*=============================================================================
# Function: checkExistance
# Created: [12APR15]
# Author: Will G
# Arguments: SamAccountName
# Purpose: Check to see if a user with that username already exists in AD
#*=============================================================================
Function checkExistance($SAM)
{
	$User = Get-ADUser -Filter {sAMAccountName -eq $SAM}
	If ($User -eq $Null) 
	{
		return $TRUE
	}
	Else
	{
		return $FALSE
	}
}

#*=============================================================================
#* FUNCTION LISTINGS
#*=============================================================================
# Function: generateHomeFolder
# Created: [12APR15]
# Author: Will G
# Arguments: 
# Purpose: Figure out where the users HomeFolder should be located
#*=============================================================================
Function generateHomeFolder()
{
	#TODO
	return "\\$Domain\profiles\$Quota\$SAMName"
}

#*=============================================================================
#* FUNCTION LISTINGS
#*=============================================================================
# Function: generateSam
# Created: [12APR15]
# Author: Will G
# Arguments: FirstName, MiddleName, LastName
# Purpose: Automatically generate the SamAccountName for a user based on our naming standard
#*=============================================================================
Function generateSam($First, $Middle, $Last)
{
	If($SAMName -ne "fmlast")
	{
		return $SAMName
	}
	Else
	{
		#TODO GENERATE SAM
		return "fmlast"
	}
}

#*=============================================================================
#* FUNCTION LISTINGS
#*=============================================================================
# Function: generateFullName
# Created: [12APR15]
# Author: Will G
# Arguments: FirstName, MiddleName, LastName
# Purpose: Automatically generate the Display Name, and Full Name based on our naming standard
#*=============================================================================
Function generateFullName($First, $Middle, $Last)
{
	#TODO
	return "First M. Last"
}

#*=============================================================================
#* FUNCTION LISTINGS
#*=============================================================================
# Function: checkInput
# Created: [12APR15]
# Author: Will G
# Arguments: 
# Purpose: Check to ensure we have all the information we need to create the user
# =============================================================================
Function checkInput()
{
	If($firstName -eq "First")
	{
		return $FALSE
	}
	If($MiddleInital -eq "Middle")
	{
		$MiddleInital=""
	}
	If($LastName -eq "Last")
	{
		return $FALSE
	}
	If($OtherName -eq "NickName")
	{
		return $FALSE
	}
	If($OtherName -eq "NickName")
	{
		return $FALSE
	}
	If($TempPass -eq "P@22word")
	{
		return $FALSE
	}
	return $TRUE
}

#*=============================================================================
#* SCRIPT BODY
#*=============================================================================

#Generate additional information
$HomeFolder = generateHomeFolder()
$SAMName=generateSam($FirstName,$MiddleInital,$LastName)
$FullName=generateFullName($FirstName,$MiddleInital,$LastName)

#*=============================================================================
#* Create User Account
#*=============================================================================
$NewUser = New-ADUser `
	-GivenName $FirstName `
	-Initials $MiddleInital `
	-Surname $LastName `
	-Name "$FirstName $MiddleInital. $LastName" `
	-DisplayName "$FirstName $MiddleInital. $LastName" `
	-OtherName $OtherName `
	-SamAccountName $SAMName `
	-HomeDirectory "$HomeFolder" `
	-ProfilePath "$HomeFolder\_sys\$SAMName.pds" `
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

#TODO Add these into the account creation process
#-AccountExpirationDate <System.NullableSystem.DateTime> `
#-Credential $AdminCredentials `


#*=============================================================================
#* Create Home Folder, Set Permissions
#*=============================================================================
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
$userfolder = "$HomeFolder"

#Get the current ACL for the folder
$currentACL = Get-ACL -path $userfolder 

#Add this access rule to the ACL 
$currentACL.SetAccessRule($NewAccessrule) 

#Write the changes to the user folder 
Set-ACL -path $userfolder -AclObject $currentACL
#*=============================================================================
#* END OF SCRIPT: CMIT Create User
#*=============================================================================