#!/bin/bash

loadkeys ru
setfont cyr-sun16
echo 'Синхронизация системных часов'
timedatectl set-ntp true


echo '###### Разметка диска ######'
echo "
    Тут можно выбрать

    1 -  автоматическую разметку: 4 раздела
    /dev/sda1 - boot = 100M
    /dev/sda2 - root = 30G
    /dev/sda3 - swap = 1024M
    /dev/sda4 - home = остаток
    
    0 - либо же сделать разметку вручную
    предполагается, что будет также 3 раздела
    отличие заключается лишь в том, что доступно изменить размеры дисков
    иерархия для корректной работы должна оставаться такой же
    
    введите цифру своего предпочтения:"
    echo " "
while 
    read -n1 -p  "
    1 - автоматически    
    0 - вручную: " cfdisk # sends right after the keypress
    echo ''
    [[ "$cfdisk" =~ [^10] ]]
do
    :
done
 if [[ $cfdisk == 1 ]]; then
  echo 'автоматическая разметка'
  echo 'создание разделов'
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

  echo 'Форматирование дисков'
  mkfs.ext2  /dev/sda1 -L boot
  mkfs.ext4  /dev/sda2 -L root
  mkswap /dev/sda3 -L swap
  mkfs.ext4  /dev/sda4 -L home

  echo 'Монтирование дисков'
  mount /dev/sda2 /mnt
  mkdir /mnt/{boot,home}
  mount /dev/sda1 /mnt/boot
  swapon /dev/sda3
  mount /dev/sda4 /mnt/home

elif [[ $cfdisk == 0 ]]; then
  read -p "Укажите диск (sda/sdb например sda) : " cfd
  cfdisk /dev/$cfd  
  read -p "Укажите boot раздел (sda1/sdb1):" bootd
  mkfs.ext2 /dev/$bootd -L boot
 
    #elif [[ $boots == 0 ]]; then
    #echo "boot раздел пропущен"   
  read -p "Укажите ROOT раздел(sda/sdb 1.2.3.4 (sda5 например)):" root
  echo ""
  mkfs.ext4 /dev/$root -L root
  mount /dev/$root /mnt
  mkdir /mnt/{boot,home}
  mount
  echo ""
  ########## boot  ########
  mount /dev/$bootd /mnt/boot
  ############ swap   #########################################################
  read -p "Укажите swap раздел(sda/sdb 1.2.3.4 (sda7 например)):" swaps
  swapon /dev/$swaps
  ################  home     ############################################################ 
  clear
  read -p "Укажите HOME раздел(sda1/sdb3):" home
  mount /dev/$home /mnt/home
fi

echo 'разметка диска'
fdisk -l

echo 'Выбор зеркал для загрузки. Ставим зеркало от Яндекс'
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

echo 'Установка основных пакетов'
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl

echo 'Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/UserNameMikko/archinstall/master/arch2.sh)"