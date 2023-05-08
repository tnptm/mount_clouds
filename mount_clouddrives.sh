#!/bin/bash
###################################################
# Mounting rclone services in linux
# toni.patama@gmail.com 2023
####################################################

#--------------------------------
# Global settings
#--------------------------------

# Main directory path where under cloud service directories will be mounted

services_mainpath=~/clouds

# List of available services of rclone in your system 
# NOTE: rclone must be set up before using this script

services=(Onedrive) # (Name1 Name2 Name3 ...) ${myArray[@]}

#End of Global settings-----------------

# defining dir for temp files
tmp_dir=$services_mainpath/.tmp


if ! [ -x $tmp_dir ]
then
	mkdir $tmp_dir
fi

# tests that service is alive and having the file
test_service()
{
	# testing does pidfile exist
	if [ -s $pidfile ] 
	then
		# read pid from pidfile
		tpid=`cat $tmp_dir"/"$sname_lower".pid"|grep ^[0-9]*$`
		
		# Is service really running?
		if [ `ps -C rclone | grep $tpid | wc -l` == "0" ]
		then
			tpid=""
			echo "Service isn't running."
		fi
	else
		tpid=""
	fi
	#echo "Tpid result is: "$tpid
}


# starts the service and saves the PID in tmp dir in home dir
start_service()
{
	echo "Service: "$service_name" mounting.."

	# mountpoint and rclone service name must be defined with lowercase. PID read to variable PIDR
	rclone --vfs-cache-mode writes mount $sname_lower: $services_mainpath"/"$sname_lower & PIDR=$!
	echo $PIDR > $tmp_dir"/"$sname_lower".pid"
}

# Unmount the service based on mount directory, if process exists 
unmount_service()
{
	# if process really is alive still
	if [ `ps -C rclone | grep $tpid | wc -l` == "1" ]
	then
		#kill -9 $tpid # don't use

		# Don't use the kill because it is not gender. It breaks the folder and script is not working after that
		fusermount -uz $services_mainpath"/"$sname_lower
		# rm pidfile...
	else
		echo "Service wasn't found running.. Nothing to do"
	fi
}



# if [ -x $tm ]; then echo "yes"; else echo "no"; mkdir $tm; fi

for service_name in ${services[@]}
do

	# lowercase of name
	sname_lower=`echo $service_name| tr '[:upper:]' '[:lower:]'`
	pidfile=$tmp_dir"/"$sname_lower".pid"

	
	# test service alive, if yes ask, would you like to kill it
	# if not existing -> start
	
	
	test_service
	if [ "$tpid" ] 
	then
		
		while ! [ "$confi" ] || [ "$confi" != "y" ] && [ "$confi" != "n" ]
		do
			echo "Should I quit service: \""$service_name"\"? Answer (y)es/(n)o and enter";
			read confi
			if [ "$confi" == "y" ]
			then
				echo "Unmounting (fusermount) the "$service_name"..."
				
				# Calling the kill function
				unmount_service
				echo "Done!"
				break
			elif [ "$confi" == "n" ]
			then
				echo "Exiting..."
				break
			fi
		done
		
	else
		echo "The service will start after 5 seconds..CTRL-C to cancel";
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



#echo "Google drive..."
#echo "Google no available yet"
