#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Run as Root"
  exit
fi

function nL {
	echo -e "\n"
}

y="y"
Y="Y"
FDISK=$(fdisk -l | grep -s "Disk /dev/*" | cut -d " " -f 2-4 | cut -d ":" -f 1,2 | sed 's/.$//'| nl)
echo "${FDISK}"
DISKNUMMAX=$(echo "$FDISK" | tail -n 1 | awk '{print $1}')
if [ $DISKNUMMAX -lt 10 ]; then 
    read -n1 -p "Type the number of the disk you would like to mount: " DISKNUMB
elif [ $DISKNUMMAX -gt 10 ]; then
    read -n2 -p "Type the number of the disk you would like to mount: " DISKNUMB
fi

nL
if [[ $DISKNUMB > $DISKNUMMAX || $DISKNUMB < 1 ]]; then
	echo "No disk with that number available, please restart."
	exit
fi

read -n1 -p "You typed ${DISKNUMB}, is this correct? [y,n] " yn
nL
while [[ "$yn" != "Y" && "$yn" != "y" ]]; do
	echo "${FDISK}"
	read -n1 -p "Type the correct disk number: " DISKNUM
	nL
	read -n1 -p "You typed ${DISKNUMB}, is this correct? [y,n] " yn
	nL
done

SPACENUMB=$(expr $DISKNUMB \* 4 - 2)
MOUNT=$(echo $FDISK | cut -d " " -f "$SPACENUMB" | sed 's/.$//')
MOUNT2=$(fdisk -l $MOUNT | grep $MOUNT | tail -n +2| awk '{print $1,$5}'| nl)
echo -e "$MOUNT2\n"
PARTMAX=$(echo "$MOUNT2" | tail -n 1 | awk '{print $1}')
read -n1 -p "Type the number of the partition you want to mount: " MOUNT2
nL
while [[ $MOUNT2 > $PARTMAX || $MOUNT2 < 1 ]]; do
        read -n1 -p "No partition with that number available, please pick a new partition. " MOUNT2
	nL
done

MOUNT2=$MOUNT$MOUNT2
nL

read -p "Where would you like to mount to? " POINT
read -n1 -p "You typed \"$POINT\", is this correct [y,n] " yn 
nL
CHECK=$(ls $POINT)
LOCATE=$(locate -en 1 "$POINT")
if [[ $yn == "Y" || $yn == "y" ]]; then

	if [[ $CHECK ]]; then
		echo -e "$CHECK\n"
		read -n1 -p "Directory contents are listed above, would you still like to mount? [y,n] " yn1 
		if [[ $yn1 == "N" || $yn1 == "n" ]]; then
			nL
			read -p "Choose a new mount point: " POINT
		elif [[ $yn1 == "Y" || $yn1 == "y" ]]; then
			mount.fuse $MOUNT2 $POINT -o nonempty
		fi
	elif [[ $LOCATE == 1 ]]; then
		read -n1 -p "There is no directory with this name, would you like to make one? [y,n] " yn2
		nL
		if [[ $yn2 == "Y" || $yn2 == "y" ]]; then
                	mkdir $POINT
        	elif [[ $yn2 == "N" || $yn2 == "n" ]]; then
                	read -n1 -p "Would you like to choose a new directory? [y,n] " yn3
			nL
			if [[ $yn3 == "N" || $yn3 == "n" ]]; then
				exit
			elif [[ $yn3 == "Y" || $yn3 == "y" ]]; then
				read -p "Choose a new mount point: " POINT
				nL
			fi
		fi
	fi
fi
while [[ $yn == "N" || $yn == "n" ]]; do
    nL
    read -p "Where would you like to mount to? " POINT
    read -n1 -p "You typed $POINT, is this correct [y,n] " yn;
    nL
done

CHECK=$(ls $POINT)
LOCATE=$(locate -en 1 "$POINT")
if [[ $yn == "Y" || $yn == "y" ]]; then
    if [[ $CHECK ]]; then
		echo -e "$CHECK\n"
		read -n1 -p "Directory has contents, would you still like to mount? [y,n] " yn1 
		if [[ $yn1 == "N" || $yn1 == "n" ]]; then
			nL
			read -p "Choose a new mount point: " POINT
		elif [[ $yn1 == "Y" || $yn1 == "y" ]]; then
			mount.fuse $MOUNT2 $POINT -o nonempty
		fi
	elif [[ $LOCATE == 1 ]]; then
		read -n1 -p "There is no directory with this name, would you like to make one? [y,n] " yn2
		nL
		if [[ $yn2 == "Y" || $yn2 == "y" ]]; then
                	mkdir $POINT
        	elif [[ $yn2 == "N" || $yn2 == "n" ]]; then
                	read -n1 -p "Would you like to choose a new directory? [y,n] " yn3
			nL
			if [[ $yn3 == "N" || $yn3 == "n" ]]; then
				exit
			elif [[ $yn3 == "Y" || $yn3 == "y" ]]; then
				read -p "Choose a new mount point: " POINT
				nL
			fi
		fi
	fi
fi

nL
mount $MOUNT2 $POINT && echo "Your device is now mounted."
