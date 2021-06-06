#!/bin/bash
#Creator: kxisxr
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


echo -e "${greenColour}""
 _      _  _               __  _               _                
| |__  (_)| |_  /\ /\   /\ \ \| |  ___    ___ | | __  ___  _ __ 
| '_ \ | || __|/ / \ \ /  \/ /| | / _ \  / __|| |/ / / _ \| '__|
| |_) || || |_ \ \_/ // /\  / | || (_) || (__ |   < |  __/| |   
|_.__/ |_| \__| \___/ \_\ \/  |_| \___/  \___||_|\_\ \___||_|   

by kxisxr                                                                
@pixelbit131
""${endColour}"

echo -e "${blueColour}"'------------------------------------------------------------------'"${endColour}"
echo -e ' '

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo -e -n "${redColour}"'Not running as root \nExiting...'"${endColour}"
    exit
fi

echo -e -n "${greenColour}"'Checking for dislocker...'"${endColour}"
echo -e ' '
sleep 0.5

if ! command -v dislocker &> /dev/null
then
    echo -e -n "${greenColour}"'Installing' "${blueColour}"'dislocker...'"${endColour}""${endColour}"
    echo -e ' '
    sudo apt-get install dislocker -y > /dev/null 2>&1
    echo -e ' '
    sleep 0.5
else
echo -e "${redColour}"'Dislocker exists, skipping...'"${endColour}"
fi

echo -e ' '
echo -e -n "${greenColour}"'Creating the bitlocker directory: '"${endColour}"
echo -e ' '
sleep 0.5

cd /mnt

if [ -d "bitlocker" ]; then
    echo -e "${redColour}"'The directory exists, skipping...'"${endColour}"
else
echo "Directory created: in /mnt/bitlocker"
mkdir bitlocker
fi
cd - | 0>&1
echo -e ' '

sleep 0.5

echo -e -n "${greenColour}"'Disks available: '"${endColour}"
echo -e ' '

lsblk -o NAME,SIZE,MODEL,PARTTYPENAME,HOTPLUG | grep -v -E "VBOX|VMWARE" | grep -v -E "pkt|sda"
echo -e ' '


encryptedDisks=$(sudo dislocker-find | sed 's/\/dev\///g')
echo -e -n "${greenColour}"'[*] Eligible encrypted disks:'"${endColour}" "${purpleColour}"$encryptedDisks"${endColour}\n"
echo -e ' '


echo -e -n "${yellowColour}"'Select the disk to unlock:' "${endColour}"
read disk



unset password
prompt=$(echo -e -n "${yellowColour}"'Enter the password: '"${endColour}")
echo -e ' '
while IFS= read -p "$prompt" -r -s -n 1 char
do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
done
echo -e '\n'
sleep 0.5

echo -e -n "${yellowColour}"'1.- Yes.\n'"${endColour}"
echo -e -n "${yellowColour}"'2.- No.\n'"${endColour}"
echo -e ' '
echo -e -n "${yellowColour}"'Create a new directory to mount?' "${endColour}"
read var

if [ $var == '1' ]
then
echo -e ' '
echo -e -n "${yellowColour}"'Name: '"${endColour}"
read newDir

cd /mnt
if [ -d $newDir ]
then
    echo -e "${redColour}"'This directory already exists!!!, skipping...'"${endColour}"
else
mkdir /mnt/$newDir
echo -e ' '
echo -e -n "${yellowColour}"'Directory created in /mnt/'$newDir"${endColour}"
echo -e ' '
fi
fi
cd - | 0>&1

echo -e ' '
echo -e -n "${greenColour}"'Directories in /mnt :' "${endColour}"
echo -e ' '
ls /mnt
echo -e ' '
echo -e -n "${yellowColour}"'Directory to mount: '"${endColour}"
read dir
echo -e ' '
sleep 0.5


if [ "$(ls -A /mnt/$dir)" ] 
then
    echo -e "${redColour}"'Dir'"${endColour}" $dir "${redColour}"'is not Empty!, probably mounted already'"${endColour}"
    echo -e "${greenColour}"'Exiting...'"${endColour}"
    exit 0
else
	sudo dislocker -v -V /dev/$disk -u$password /mnt/bitlocker
	sleep 0.5
	sudo mount --rw -o loop /mnt/bitlocker/dislocker-file /mnt/$dir
	sleep 0.5

	echo -e -n "${turquoiseColour}"'Mounted on: /mnt/'$dir"${endColour}"
fi
