#!/bin/bash

loadkeys ru
setfont cyr-sun16
echo 'Синхронизация системных часов'
timedatectl set-ntp true

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

echo 'разметка диска'
fdisk -l

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

echo 'Выбор зеркал для загрузки. Ставим зеркало от Яндекс'
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

echo 'Установка основных пакетов'
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl

echo 'Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/UserNameMikko/archinstall/master/arch2.sh)"
