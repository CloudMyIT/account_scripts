# account_scripts
##About
These scripts are used by CloudMy.IT to help automate the process of managing our users.

They are used to Create and Delete users, as well as update the expiration date of accounts when they pay each months invoice.

CloudMy.IT LLC uses other scripts found on the internet to create scripts that do what we need. If we used your work, please let us know and we will credit your work to you.

##Setup
Before using these scripts we want to ensure you have the correct enviroment setup. 

By default we use DFS Name Spaces for all user content. As such, we don't manage any local paths or server names in these scripts.

To assist in the setup, we will assume all DFS shared folders are located in the same folder: C:\DATA

###Profiles
First we will create the Profiles Folder. This will be used to store al of the users files.

1. Create a new Directory named profiles.
2. Change the NTFS security permissions and set it so ONLY "SYSTEM" and "Domain Admins" have "FULL CONTROL" For "This Folder, Subfolders and Files"
3. Add this folder to the DFS Share.
4. Set the share permissions so ONLY "Authenticated Users" has "FULL CONTROL"
####Optional Quota Setup
We need to manage the space our Clients have, so we setup some additional folders.

5. Create the folders with the following names: "1G, 2G, 5G, 10G, 15G, 20G, 25G, 50G, 100G, NONE"
6. For each of the above folders create a corosponding quota, ensuring your select "Auto apply template and create quotas on existing and new subfolders"

