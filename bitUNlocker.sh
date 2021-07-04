#!/bin/bash
#Creator: kxisxr
greenColour="\x1B[0;32m\033[1m"
endColour="\033[0m\x1B[0m"
redColour="\x1B[0;31m\033[1m"
blueColour="\x1B[0;34m\033[1m"
yellowColour="\x1B[0;33m\033[1m"
purpleColour="\x1B[0;35m\033[1m"
turquoiseColour="\x1B[0;36m\033[1m"
grayColour="\x1B[0;37m\033[1m"

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

if [[ "$OSTYPE" == "linux-gnu"* ]]
then
so=linux
elif [[ "$OSTYPE" == "darwin"* ]]
then
so=mac
else
echo -e -n "${greenColour}"' Operating system not supported, exitting... '"${endColour}"
exit 0
fi

if [ $so = "linux" ]
then
echo -e -n "${greenColour}"'Checking for dislocker...'"${endColour}"
echo -e ' '
sleep 0.5

if ! command -v dislocker &> /dev/null
then
    echo -e -n "${greenColour}"'Installing' "${blueColour}"'dislocker...'"${endColour}""${endColour}"
    echo -e ' '
    sudo apt-get install dislocker -y 2>/dev/null
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
echo -e ' '

sleep 0.5

echo -e -n "${greenColour}"'Disks available: '"${endColour}"
echo -e ' '

lsblk -o NAME,SIZE,MODEL,FSTYPE | grep -v -E "VBOX|VMWARE" | grep -v -E "pkt|sda|loop"
echo -e ' '


encryptedDisks=$(lsblk -o NAME,SIZE,MODEL,FSTYPE | grep -v -E "loop|pkt|VBOX|VMWARE" | grep BitLocker | awk '{print $1}')

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
echo -e -n "${redColour}"'3.- Exit.\n'"${endColour}"
echo -e ' '
echo -e -n "${yellowColour}"'Create a new directory to mount?' "${endColour}"
read var

if [ $var == '1' ]
then
echo -e ' '
echo -e -n "${yellowColour}"'Name: '"${endColour}"
read newDir
mkdir /mnt/$newDir
echo -e ' '
echo -e -n "${yellowColour}"'Directory created in /mnt/'$newDir"${endColour}"
echo -e ' '
else
echo -e -n "${redColour}"'Skipping...'"${endColour}"
echo -e ' '
fi

echo -e ' '
echo -e -n "${greenColour}"'Directories in /mnt :' "${endColour}"
echo -e ' '
ls /mnt
echo -e ' '
echo -e -n "${yellowColour}"'Directory to mount: '"${endColour}"
read dir
echo -e ' '
sleep 0.5

sudo dislocker -v -V /dev/$disk -u$password /mnt/bitlocker
sleep 0.5






sudo mount --rw -o loop /mnt/bitlocker/dislocker-file /mnt/$dir
sleep 0.5

echo -e -n "${turquoiseColour}"'Mounted on: /mnt/'$dir"${endColour}"
#----------------------------------------------------------------------------------------------------------------------------------------
#Running on mac
elif [ $so = "mac" ]
then
echo -e -n "${greenColour}"'Checking for dislocker...'"${endColour}"
echo -e ' '
sleep 0.5

if ! command -v dislocker &> /dev/null
then
    echo -e -n "${greenColour}"'Installing' "${blueColour}"'dislocker...'"${endColour}""${endColour}"
    echo -e ' '
    git clone https://github.com/Aorimn/dislocker 2>/dev/null
    cd dislocker
    brew update
    brew install caskroom/cask/macfuse > /dev/null
    brew install src/dislocker.rb > /dev/null
    echo -e ' '
    sleep 0.5
else
echo -e "${redColour}"'Dislocker exists, skipping...'"${endColour}"
fi

echo -e ' '
sleep 0.5

echo -e "${greenColour}"'Disks available: '"${endColour}"
diskutil list external
echo -e ' '

show_disk=$(diskutil list | grep external | awk '{print $1}')
show_disk2=$(diskutil list external | grep "[0-9]s[0-9]$" | awk '{print $6}')

echo -e ' '
echo -e "${greenColour}"'[*] Eligible encrypted disks:'"${endColour}" "${purpleColour}"$show_disk $show_disk2"${endColour}\n"
echo -e ' '

echo -e -n "${greenColour}"'Select the disk: '"${endColour}"
read disk
echo -e ' '

echo -e -n "${greenColour}"'Name of the directory to mount: '"${endColour}"
read dir
echo -e ' '

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

echo -e -n "${greenColour}"'Creating the dislocker file...'"${endColour}"
echo -e ' '
sleep 0.5

sudo dislocker -v -V $disk -u$password -- $dir 2>/dev/null

echo -e -n "${greenColour}"'Attaching the image... '"${endColour}"
echo -e ' '
sleep 0.5
 
sudo hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount $dir/dislocker-file >> /dev/null 2>&1

disk2=$(diskutil list | grep image | awk '{print $1}')
format=$(diskutil info $disk2 | grep "Bundle" | awk '{print $3}')
sleep 1

echo -e "${greenColour}"'Mounting the disk...'"${endColour}"
echo -e ' '

sleep 0.5

sudo mount -t $format $disk2 $dir 2>/dev/null

echo -e -n "${purpleColour}"'Disk mounted on:'"${endColour}" "${turquoiseColour}"$PWD/$dir "${endColour}"
echo -e ' '
fi
