#* FileName: CreateUser.ps1
#*=============================================================================
#* Script Name: [CMIT Create User]
#* Created: [12APR15]
#* Version: 0.1
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
param([String]$MiddleName = "Middle")
param([String]$LastName = "Last")
param([String]$OtherName = "NickName")
param([String]$TempPass = "P@22word")
#OPTIONAL TO BE PASSED We Assume you don't know about them...
param([String]$Domain = "cloudmy.it")
param([String]$OU = "OU=user,OU=accounts,DC=cloudmy,DC=it")
param([String]$Quota = "NULL")
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
		#User Doesn't Exist
		return $FALSE
	}
	Else
	{
		#User Exists
		return $TRUE
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
	If ($global:Quota -eq "NULL")
	{
		return "\\$global:Domain\profiles\$global:SAMName"
	}
	Else
	{
		If (Test-Path "\\$global:Domain\profiles\$global:Quota" -PathType Container )
		{
			return "\\$global:Domain\profiles\$global:Quota\$global:SAMName"
		}
		Else
		{
			return "\\$global:Domain\profiles\$global:SAMName"
		}
	}
}

#*=============================================================================
#* FUNCTION LISTINGS
#*=============================================================================
# Function: generateSam
# Created: [12APR15]
# Author: Will G
# Arguments: None
# Purpose: Automatically generate the SamAccountName for a user based on our naming standard
#*=============================================================================
Function generateSam($x=0)
{
	#Naming Standard FMLLLLLL
	$initSAM = $global:FirstName.substring(0,1)+$global:MiddleName.substring(0,1)+$global:LastName.substring(0,6)
	If($global:SAMName -eq "fmlast")
	{
		$global:SAMName = $initSAM.tolower()
	}
	
	If ($x > 0)
	{
		$numChar = [string]$x | measure-object -character | select -expandproperty characters
		$global:SAMName = ($initSAM.substring(0,8-$numChar)+$x).tolower()
	}
	If(checkExistance($global:SAMName))
	{
		generateSam($x++);
	}
}

#*=============================================================================
#* FUNCTION LISTINGS
#*=============================================================================
# Function: generateFullName
# Created: [12APR15]
# Author: Will G
# Arguments: None
# Purpose: Automatically generate the Display Name, and Full Name based on our naming standard
#*=============================================================================
Function generateFullName()
{
	return $global:First+" "+$global:MiddleName.substring(0,1)+". "+$global:Last
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
	If($global:firstName -eq "First")
	{
		return $FALSE
	}
	Else
	{
		$global:firstName = $global:firstName.substring(0,1).toupper()+$global:firstName.substring(1).tolower()
	}
	If($MiddleName -eq "Middle")
	{
		$MiddleName=""
	}
	Else
	{
		$global:MiddleName = $global:MiddleName.substring(0,1).toupper()+$global:MiddleName.substring(1).tolower()
	}
	If($global:LastName -eq "Last")
	{
		return $FALSE
	}
	Else
	{
		$global:LastName = $global:LastName.substring(0,1).toupper()+$global:LastName.substring(1).tolower()
	}
	If($global:OtherName -eq "NickName")
	{
		return $FALSE
	}
	Else
	{
		$OtherName = $global:OtherName.substring(0,1).toupper()+$global:OtherName.substring(1).tolower()
	}
	
	If($global:TempPass -eq "P@22word")
	{
		#I mean it is a temporay password, but lets try to randomly generate them?
		return $FALSE
	}
	return $TRUE
}

#*=============================================================================
#* FUNCTION LISTINGS
#*=============================================================================
# Function: trap
# Created: [12APR15]
# Author: Will G
# Arguments: 
# Purpose: To exit the script and return a resonable error message
# =============================================================================
trap 
{ 
  write-output $_ 
  exit 1 
} 

#*=============================================================================
#* SCRIPT BODY
#*=============================================================================

#Generate additional information
If(checkInput() -eq $FALSE)
{
	#DIE Input Was Bad!
	throw 'Bad Input Error'
}

$HomeFolder = generateHomeFolder()
$SAMName=generateSam()
$FullName=generateFullName()

#*=============================================================================
#* Create User Account
#*=============================================================================
$NewUser = New-ADUser `
	-GivenName $FirstName `
	-Initials $MiddleName `
	-Surname $LastName `
	-Name $FullName `
	-DisplayName $FullName `
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
#* Exchange Mailbox Setup
#*=============================================================================
#TODO DEFINE DATABASE/QUOTA FOR MAILBOXES
Enable-Mailbox -Identity "$Domain\SAMName" -Database Database01

#*=============================================================================
#* OpenPGP Setup
#*=============================================================================
#TODO
#Place Script in Users Login Scripts Directory

#Import the key into Kleopatra For Future Use
.\kleopatra -i PrivateKey.gpg



#*=============================================================================
#* END OF SCRIPT: CMIT Create User
#*=============================================================================