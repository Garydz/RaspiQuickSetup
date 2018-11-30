#!/bin/bash
# Program:
#  Backup files specified in SCRIPTNAME.conf and user's crontab
#  to folder name specified in SCRIPTNAME.conf or commandline
# Version:
#  20181129 - Fix read permission issue
#    If there is a file without read permission under a backuping folder,
#    this file should be listed in bakFiles separately.
#  20181118 - First release

conf=$(dirname ${0})/$(basename ${0} .sh).conf
if [ ! -f ${conf} ]; then
	echo "${conf} not found! Creating a basic one..."
	touch ${conf}
	echo "# Where should the files be backup," >> ${conf}
	echo "# the path must be full path end with /" >> ${conf}
	echo "bakFolderRoot=\"/home/pi/conf_bak/\"" >> ${conf}
	echo "#" >> ${conf}
	echo "# Which files or folders will be backup," >> ${conf}
	echo "# must be full path from /" >> ${conf}
	echo "bakFiles=(\"/home/pi/.bashrc\" \"/home/pi/bin/\" \"/etc/fstab\")" >> ${conf}
	echo "#" >> ${conf}
fi
. ${conf}

if [ ${#} -gt 0 ]; then
	bakFolderRoot=${1}
fi

bakFolder=${bakFolderRoot}conf_$(date +%Y%m%d%H%M%S)
echo "All files backup to ${bakFolder}"

for f in ${bakFiles[*]}
do
	if [ -d ${f} ]; then
		echo "Backup dir \"${f}\" "
		mkdir -p ${bakFolder}$(dirname ${f})
		if [ -r ${f} ]; then
			cp -r ${f} ${bakFolder}$(dirname ${f})
		else
			sudo cp -r ${f} ${bakFolder}$(dirname ${f})
		fi
	elif [ -f ${f} ]; then
		echo "Backup file \"${f}\" "
		mkdir -p ${bakFolder}$(dirname ${f})
		if [ -r ${f} ]; then
			cp ${f} ${bakFolder}$(dirname ${f})
		else
			sudo cp ${f} ${bakFolder}$(dirname ${f})
		fi
	else
		echo "Item \"${f}\" is not backable"
	fi
done

echo "Backup your crontab"
crontab -l > ${bakFolder}/crontab

exit 0
