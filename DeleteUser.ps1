#* FileName: DeleteUser.ps1
#*=============================================================================
#* Script Name: [CMIT Delete User]
#* Created: [12APR15]
#* Version: 0.1
#* Author: Will G
#* Company: CloudMy.IT LLC
#* Web: http://www.cloudmy.it
#* Reqrmnts:
#* Keywords:
#*=============================================================================
#* Purpose: To automate the process of deleting users
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
param([String]$SAMName = "fmlast")
param([String]$Domain = "cloudmy.it")
param([String]$OU = "OU=user,OU=accounts,DC=cloudmy,DC=it")

#*=============================================================================
#* SCRIPT BODY
#*=============================================================================
$DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($OU)
$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher 

#Get Identity From SAMName
$UserName = $Domain+"\"+$SAMName

$SearchFilter = "(&(objectClass=user)(sAMAccountName= $UserName))"
[void]$DirectorySearcher.PropertiesToLoad.Add('homeDirectory') 

$DirectorySearcher.Filter = $SearchFilter
$DirectorySearcher.SearchScope = "Subtree"

$Account = $DirectorySearcher.FindOne() 
$Account 

$User = [adsi]"$($Account.Properties.adspath)" 
$User 
$User.DeleteTree() 
Remove-Item -Path $Account.Properties.homedirectory -Recurse -Force 

	
#*=============================================================================
#* END OF SCRIPT: CMIT Delete User
#*=============================================================================