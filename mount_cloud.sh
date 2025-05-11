#!/bin/bash
#################################################
#												#
# Mounting rclone services in linux         	#
# - only works with systems having fuse (not 	#
#	compatible with MacOS)						#
#												#	
# author: tonipat047@gmail.com 					#
#												#	
#################################################

ver=0.99
dt=2025.05.10

#--------------------------------
# Global settings               |
#--------------------------------

# Main directory path where under cloud service directories will be mounted

services_mainpath=~/clouds

# List of available services of rclone in your system 
# NOTE: rclone must be set up before using this script

#services=(Onedrive GoogleDrive-tnpptm) # (Name1 Name2 Name3 ...) ${myArray[@]}
#services=() 
services=(`rclone listremotes`)
number_of_services=${#services[@]}

if [ $number_of_services -eq 0 ] 
then
	echo -e "There was no CLOUD FILE SHARES defined by rclone. Define first. \nExiting..."
	exit
fi

#End of Global settings-----------------

# defining dir for temp files
tmp_dir=$services_mainpath/.tmp


if ! [ -x $tmp_dir ]
then
	mkdir $tmp_dir
fi

# Functions
is_cloudshare_mounted()
{
	# rclone mounts
	# $1 = "service_name"
	row_of_mount=(`mount | grep rclone | grep $1`)
	if [ ${#row_of_mount[@]} -gt 0 ]
	then
		return 1
	else
		return 0
	fi
}

color_text()
{
	# green or red
	local text="$1"
	local color="$2"
	case $color in
		red)
			echo -en "\033[0;31m$text\033[0m"
			;;
		green)
			echo -en "\033[0;32m$text\033[0m"
			;;
		blue)
			echo -en "\033[0;34m$text\033[0m"
			;;
		yellow)
			echo -en "\033[0;33m$text\033[0m"
			;;
	esac

}

dotline() {
  # result: text1........text2
  local left="$1"
  local right="$2"
  local width="$3"
  local dots=$(( width - ${#left} - ${#right} ))
  printf "%s%*s" "$left" $dots "."  | sed 's/ /./g'
}


# starts the service and saves the PID in tmp dir in home dir
start_service()
{
	echo "Service: "$service_name" mounting.."
	echo "Mountpoint: "$mountpoint

	# mountpoint and rclone service name must be defined with lowercase. PID read to variable PIDR
	rclone --vfs-cache-mode writes mount $service_name: $mountpoint & # PIDR=$!
	#echo $PIDR > $pidfile
}

find_fusermount_bin()
{
	if command -v fusermount3 &> /dev/null; then
		FUSERMOUNT=$(command -v fusermount3)
	elif command -v fusermount &> /dev/null; then
		FUSERMOUNT=$(command -v fusermount)
	else
		echo "Error: fusermount or fusermount3 not found. Try manually umount command or kill the rclone process. Exiting..." >&2
		exit 1
	fi
}

# Unmount the service based on mount directory, if process exists 
# 
unmount_service()
{
	echo -n "Unmounting (fusermount) the "$service_name"... "
	find_fusermount_bin
	
	$FUSERMOUNT -uz $1
}


# main function looping services
mainf(){
	# select services to mount or unmount by giving a number
	serv_counter=1 # mininmum
	number_of_services=${#services[@]}

	for service_name in ${services[@]}
	do
		is_cloudshare_mounted $service_name
		mounted=$?
		mounted_text=""
		color=""
		if [ $mounted -eq 1 ]
		then
			mounted_text="MOUNTED"
			color="green"
		else
			mounted_text="NOT MOUNTED"
			color="red"
		fi
		
		#echo "$serv_counter) $service_name $mounted_text"
		dotline "$serv_counter) $service_name" $mounted_text 56
		printf "%s" "["
		color_text "$mounted_text" $color
		printf "%s\n" "]"
		
		#echo$mounted_color_text

		let "serv_counter++"
	done
	
	echo -e "\nWhich services do you want to mount or unmount? \nGive a number(s) above separated by space(0 to exit, all is default)"
	echo -en "\tExample: 1 2 3.. ? "
	
	# read answer from command line
	read answer
	
	ans_list=($answer)
	number_of_answers=${#ans_list[@]}

	if [ $number_of_answers -eq 1 ] && [ $answer -eq 0 ]
	then
		echo "Exiting..."
		exit
	
	elif [ $number_of_answers -eq 0 ]
	then
		# all options
		
		ans_list=(`seq 1 $number_of_services`)
		echo " -> All selected. ${#ans_list[@]} / $number_of_services"
	fi
		
	#list_answer=($answer)
	
	
	for ref_id in ${ans_list[@]}
	do
		service_name=${services[${ref_id}-1]}
		# remove last character from service name if it is ":"
		service_name=${service_name%:}
		
		# lowercase of name
		sname_lower=`echo $service_name| tr '[:upper:]' '[:lower:]'`
		#pidfile=$tmp_dir"/"$sname_lower".pid"
		mountpoint=$services_mainpath"/"$sname_lower



		# test service alive?
		is_cloudshare_mounted $service_name
		local mounted=$?
		
		if [ $mounted -eq 1 ]
		then

			echo -en "\nDo you want to UNMOUNT the service: \""$service_name"\"?\n   Answer (y)es/(n)o and enter: ";
			read confi
			if [ "$confi" == "y" ]
			then
				# Calling the kill function
				unmount_service $mountpoint
				echo "Done!"
				#break
			elif [ "$confi" == "n" ]
			then
				echo "Nothing to do."
				#exit
			fi
			
		else
			# check that if mountpoint directory doesn't exist. And if not, create it
			if [ ! -d $mountpoint ]
			then
				mkdir -p $mountpoint
			fi
			
			echo "The service: \"$service_name\" will start in 5 seconds.. Press CTRL-C to cancel!";
			l=0
			while [ $l -lt 5 ]
			do
				sleep 1
				printf "."
				let l++
			done
			echo "Starting"
			
			# Call start service function
			start_service
			echo "Done!"
		fi		
	done
}

#----------------
# Main program  |
#----------------

echo -e "------------------------------------------------------------------"

echo -en "| Mount Cloud Drives - vers. $ver $dt tonipat047@gmail.com |"
echo -e "\n------------------------------------------------------------------\n"

if [ "$1" ]
then
	echo "Usage: mount_cloud.sh"
else
	mainf
fi

