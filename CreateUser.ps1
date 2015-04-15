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

param(
    [String]$FirstName = "First",
    [String]$MiddleName = "Middle",
    [String]$LastName = "Last",
    [String]$OtherName = "NickName",
    [String]$TempPass = "P@22word",
    [String]$Domain = "cloudmy.it",
    [String]$OU = "OU=user,OU=accounts,DC=cloudmy,DC=it",
    [String]$Quota = "10G",
    [String]$EmailQuota = "1G",
    [String]$SAMName = "fmlast"
)

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
Function generateSam([int]$x)
{
	#Naming Standard
    $initSAM = ""
    If($global:FirstName.Length -ge 1)
    {
        $initSAM = $global:FirstName.substring(0,1)
    }
    If($global:MiddleName.Length -ge 1)
    {
        $initSAM = $initSAM +$global:MiddleName.substring(0,1)
    }
    If($global:LastName.Length -ge 6)
    {
        $initSAM = $initSAM + $global:LastName.substring(0,6)
    }
    Else
    {
         $initSAM = $initSAM + $global:LastName
    }

    Write-Host $initSAM
	If($global:SAMName -eq "fmlast")
	{
		$global:SAMName = $initSAM.tolower()
	}
	
	If ($x -gt 0)
	{
		$numChar = [string]$x | measure-object -character | select -expandproperty characters
        If($initSAM.length -gt 8-$numChar)
        {
		    $global:SAMName = ($initSAM.substring(0,8-$numChar)+$x).tolower()
        }
        Else
        {
            $global:SAMName = ($initSAM+$x).tolower()
        }
	}
	If(checkExistance($global:SAMName))
	{
		generateSam($x+1);
	}
    Else
    {
        return $global:SAMName
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
    if($global:MiddleName -ge 1)
    {
	    return [string] $global:FirstName + " " + $global:MiddleName.Substring(0,1) + ". " + $global:LastName
    }
    Else
    {
        return [string] $global:FirstName + " " + $global:MiddleName + ". " + $global:LastName
    }
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
		$global:MiddleName = $global:MiddleName.substring(0,1).toupper()
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
If(checkInput -eq $FALSE)
{
	#DIE Input Was Bad!
	throw 'Bad Input Error'
}

#Must Be First!
$SAMName=generateSam
$FullName=generateFullName

#Must Be After generateSam
$HomeFolder = generateHomeFolder

#*=============================================================================
#* Create User Account
#*=============================================================================

Write-Host $FirstName $MiddleName $LastName

write-host $SAMName

$NewUser = New-ADUser `
	-GivenName $FirstName `
	-Initials $MiddleName `
	-Surname $LastName `
	-DisplayName $FullName `
	-OtherName $OtherName `
	-SamAccountName $SAMName `
	-Name $SAMName `
	-HomeDirectory "$HomeFolder" `
	-ProfilePath "$HomeFolder\_sys\$SAMName.pds" `
	-HomeDrive "U:" `
	-Path $OU `
	-UserPrincipalName "$SAMName@$Domain"
	-EmailAddress "$SAMName@$Domain"
	-AccountPassword (Read-Host -AsSecureString $TempPass) `
	-AllowReversiblePasswordEncryption $false `
	-CannotChangePassword $false `
	-ChangePasswordAtLogon $true `
	-Enabled $true `
	-PassThru `
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
New-Item -ItemType Directory -Force -Path $HomeFolder
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
$NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("$Domain\$SAMName", $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)  
#Get the current ACL for the folder
$currentACL = Get-ACL -path $HomeFolder 
#Add this access rule to the ACL 
$currentACL.SetAccessRule($NewAccessrule) 
#Write the changes to the user folder 
Set-ACL -path $HomeFolder -AclObject $currentACL

#*=============================================================================
#* Create CMIT Scripts Folder
#*=============================================================================
New-Item -ItemType Directory -Force -Path $HomeFolder/_sys/scripts
#Define FileSystemAccessRights:identifies what type of access we are defining, whether it is Full Access, Read, Write, Modify 
$FileSystemAccessRights = [System.Security.AccessControl.FileSystemRights]"Write" 
#define InheritanceFlags:defines how the security propagates to child objects by default 
#Very important - so that users have ability to create or delete files or folders in their folders 
$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit" 
#Define PropagationFlags: specifies which access rights are inherited from the parent folder (users folder). 
$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None 
#Define AccessControlType:defines if the rule created below will be an 'allow' or 'Deny' rule 
$AccessControl =[System.Security.AccessControl.AccessControlType]::Deny 
#define a new access rule to apply to users folfers 
#TODO USE SERVICE ACCOUNT
$NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("$Domain\$SAMName", $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)  
#Get the current ACL for the folder
$currentACL = Get-ACL -path $HomeFolder/_sys/scripts 
#Add this access rule to the ACL 
$currentACL.SetAccessRule($NewAccessrule) 
#Write the changes to the user folder 
Set-ACL -path $HomeFolder/_sys/scripts -AclObject $currentACL

#*=============================================================================
#* Start Exchange Mailbox Setup
#*=============================================================================
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://dc1-msmr-t1.cloudmy.it/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session
Enable-Mailbox -Identity "$Domain\$SAMName" -Database $EmailQuota
Remove-PSSession $Session
#*=============================================================================
#* Finish Exchange Mailbox Setup
#*=============================================================================

#*=============================================================================
#* END OF SCRIPT: CMIT Create User
#*=============================================================================