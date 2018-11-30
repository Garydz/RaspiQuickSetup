#!/bin/bash
# Program:
#  A reverse operation of conf_backup.sh
#  Restore all files and subfolders in current current folder
#  or path specified in commandline
#  to ${toRoot}
# Version:
#  20181129 - Fix write permission issue
#  20181119 - First release

conf=$(dirname ${0})/$(basename ${0} .sh).conf
if [ ! -f ${conf} ]; then
        echo "${conf} not found! Creating a basic one..."
	touch ${conf}
	echo "# Where should the files be put back," >> ${conf}
	echo "# the path must be full path end with /" >> ${conf}
        echo "toRoot=\"/home/pi/test/\"" >> ${conf}
	echo "#" >> ${conf}
fi
. ${conf}

if [ ${#} -gt 0 ]; then
	wd=${1}
else
	wd=$(pwd)
fi

echo "Restoring files in ${wd} to ${toRoot}"
read -n 1 -p "All existing files will be overwritten! Continue?[Yes/no]: " c
case ${c} in
	n|N)
		exit 0
		;;
	*)
		;;
esac

if [ -d ${wd} ]; then
	cd ${wd}
else
	echo "${wd} is not a folder! Stopped!"
	exit 1
fi

if [ ! -d ${toRoot} ]; then
	mkdir -p ${toRoot}
fi

files=`find * | grep -v "crontab"`

for f in ${files[*]}
do
	if [ -d ${f} ]; then
		echo "mkdir ${toRoot}${f}"
		if [ -w $(dirname ${toRoot}${f}) ]; then
			mkdir -p ${toRoot}${f}
		else
			sudo mkdir -p ${toRoot}${f}
		fi
	elif [ -f ${f} ]; then
		echo "cp ${f}"
		if [ -w ${toRoot}${f} ]; then
			cp ${f} ${toRoot}${f}
		else
			sudo cp ${f} ${toRoot}${f}
		fi
	fi
done

if [ -f "crontab" ]; then
	crontab crontab
	if [ ${?} -eq 0 ]; then
		echo -e "\nAll files and your crontab restored!"
	else
		echo -e "\nAll files restored!\nDon't forget your crontab!"
	fi
fi

exit 0
