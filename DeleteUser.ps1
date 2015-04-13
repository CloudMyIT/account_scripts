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
param([String]$FirstName = "First")

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

"`nAD provider"            
Get-ChildItem -Filter "(&(objectclass=user)(objectcategory=user)(accountExpires>=1)(accountExpires<=$now))" `
 -Path Ad:\"DC=Manticore,DC=org" -Recurse | foreach {             
 $user = [adsi]"LDAP://$($_.DistinguishedName)"            
 $user | select  @{N="Name"; E={$_.name}}, @{N="DistinguishedName"; E={$_.distinguishedname}},            
 @{N="AccountExpirationDate"; E={([datetime]$_.ConvertLargeIntegerToInt64($_.accountExpires.value)).AddYears(1600)}}            
} | Format-Table -AutoSize       

#*=============================================================================
#* END OF SCRIPT: CMIT Delete User
#*=============================================================================