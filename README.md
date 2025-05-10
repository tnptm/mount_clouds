# mount_clouds.sh

This script mounts and unmounts cloud drives in user's i.e home directory. In Linux environment it is handy, because it allows This requires rclone and logically bash as well. Rclone manages all the mounts and management.

## Installation 
- give to script permissions to run (chmod +x file)
- then starting: ./mount_clouds.sh
  
## Info

This Bash script mount_clouddrives.sh was planned to be one of a kind 
way of using rclone when having one or more cloud drives in Linux. It can 
mount and unmount the services interactive way.

The basic idea is to mount all services to one directory in your home 
directory for easy access for project files or photos etc. It is not meant 
automatic service which saves resources of computer and internet. But when 
you need it, you don't have to think much, just run the script and it 
makes everything you need.

However setting up the services it won't make. You need to follow rclone
help from web to set up your cloud drives like Onedrive or Google Drive.

The structure of "clouds" directory is (recommended to be in your 
home/user directory):

```
--clouds/
	|--src/ (script dir)
	|--.tmp/ (temporary file dir)
	|--onedrive/ (service 1)
	|--googledrive/ (service 2)
	|...
```
	
Tip: You can make to symbolic link to some bin directory, to add it to 
$PATH or make alias to the script with command alias and put it to .bashrc.

Requirements

System is tested Ubuntu 22.04 and 24.04 based system

- rclone 1.52 -> 1.69
- fuse: fusermount

