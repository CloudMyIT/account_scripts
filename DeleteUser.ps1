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

#Get Identity From SAMName

Remove-ADUser `
	-Identity "$Domain\$SAMName" `
	-Partition $OU

	#-Credential <PSCredential> `
	
#*=============================================================================
#* END OF SCRIPT: CMIT Delete User
#*=============================================================================