#!/bin/bash

loadkeys ru
setfont cyr-sun16
echo 'Synchromizing of system clock'
timedatectl set-ntp true


echo '###### Disk Partitions ######'
echo "
Right now your disks look like this:
     "
echo " "
fdisk -l
echo "
    1 - automatic: 4 partitions
    /dev/sda1 - boot = 100M
    /dev/sda2 - root = 30G
    /dev/sda3 - swap = 1024M
    /dev/sda4 - home = remaining space
    
    0 - manually 
    it must be consists of 4 partitions
    difference with the first method in manual determining of partition's size
    but with the same hierarchy
  
    input your choice:"
    echo " "
while 
    read -n1 -p  "
    1 - automatically    
    0 - manually: " cfdisk # sends right after the keypress
    echo ''
    [[ "$cfdisk" =~ [^10] ]]
do
    :
done
 if [[ $cfdisk == 1 ]]; then
  echo 'automatically'
  echo 'creating of partitions...'
  (
  echo o;
  #boot
  echo n;
  echo;
  echo;
  echo;
  echo +100M;
  #root
  echo n;
  echo;
  echo;
  echo;
  echo +30G;

  #swap
  echo n;
  echo;
  echo;
  echo;
  echo +1024M;
  #/
  echo n;
  echo p;
  echo;
  echo;
  echo a;
  echo 1;

  echo w;
) | fdisk /dev/sda

  echo 'formatting of partitions...'
  mkfs.ext2  /dev/sda1 -L boot
  mkfs.ext4  /dev/sda2 -L root
  mkswap /dev/sda3 -L swap
  mkfs.ext4  /dev/sda4 -L home

  echo 'mounting of partitions...'
  mount /dev/sda2 /mnt
  mkdir /mnt/{boot,home}
  mount /dev/sda1 /mnt/boot
  swapon /dev/sda3
  mount /dev/sda4 /mnt/home

elif [[ $cfdisk == 0 ]]; then
  read -p "select disk (for example: sda) : " cfd
  cfdisk /dev/$cfd  
  read -p "select boot partition (for example: sda1):" bootd
  mkfs.ext2 /dev/$bootd -L boot
 
    #elif [[ $boots == 0 ]]; then
    #echo "boot раздел пропущен"   
  read -p "select ROOT partition (for example: sda2 ):" root
  echo ""
  mkfs.ext4 /dev/$root -L root
  mount /dev/$root /mnt
  mkdir /mnt/{boot,home}
  mount
  echo ""
  ########## boot ##########
  mount /dev/$bootd /mnt/boot
  ############ swap ############
  read -p "select swap partition (for example: sda3):" swaps
  swapon /dev/$swaps
  ########### home ########### 
  clear
  read -p "select home partition(for example: sda4):" home
  mount /dev/$home /mnt/home
fi

echo 'now:'
fdisk -l
echo "if you need to set up mirror from yandex"
read -p "press 1: " mirr
if [[ $mirr == 1 ]]; then
  echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
elif [[ $mirr != 1 ]]; then
  echo "setting up of mirror skipped"
fi


echo 'Installing of base packages...'
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl

echo 'Setting up of the system...'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/UserNameMikko/archinstall/master/arch2.sh)"