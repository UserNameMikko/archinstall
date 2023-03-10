#!/bin/bash
read -p "input the computer's name: " hostname
read -p "input the user's name: " username

echo "writing the computer's name..."
echo $hostname > /etc/hostname
ln -svf /usr/share/zoneinfo/Europe/Moscow  /etc/localtime

echo 'Choose a system language'
read -p "1 - en  2 - ru (include ru and en_US locale)  3 - de (include de and en_US locale): " lang_num
if [[ $lang_num == 1 ]]; then
  echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen
  echo 'KEYMAP=en' >> /etc/vconsole.conf
elif [[ $lang_num == 2 ]]; then
  echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 
  locale-gen
  echo 'KEYMAP=ru' >> /etc/vconsole.conf
elif [[ $lang_num == 3 ]]; then
  echo 'LANG="de_DE.UTF-8"' > /etc/locale.conf
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen
  echo 'KEYMAP=de' >> /etc/vconsole.conf
fi
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

echo 'creating of RAM...'
mkinitcpio -p linux

echo 'installing of grub...'
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sda

echo 'updating grub.cfg...'
grub-mkconfig -o /boot/grub/grub.cfg

echo 'addind soft for Wi-fi...'
pacman -S dialog wpa_supplicant --noconfirm 

echo 'adding the user...'
useradd -m -g users -G wheel -s /bin/bash $username

echo 'installing root password...'
passwd

echo 'installing user password... '
passwd $username

echo 'Installing sudo...'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo 'uncommenting multilib for x86 applications in x64...'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy

echo "is it a virtual machine?"
echo "(yes, it is really matter)"
read -p "1 - Yes, 0 - No: " vm_setting
if [[ $vm_setting == 0 ]]; then
  gui_install="xorg xorg-server xorg-drivers xorg-xinit"
elif [[ $vm_setting == 1 ]]; then
  gui_install="xorg xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils"
fi

echo 'installing of xorg and drivers'
pacman -S $gui_install

echo "Choose Desktop Environment"
read -p "1 - KDE and sddm 2 - xfce and lxdm 3 - GNOME and gdm: " de_dm
if [[ $de_dm == 1 ]]; then
  echo 'installing of KDE...'
  pacman -S plasma plasma-wayland-session kde-applications sddm --noconfirm
  echo 'installing DM...' 
  systemctl enable sddm
elif [[ $de_dm == 2 ]]; then
  echo 'installing of XFCE...'
  pacman -S xfce4 xfce4-goodies lxdm --noconfirm
  echo 'installing DM...' 
  systemctl enable lxdm
elif [[ $de_dm == 3 ]]; then
  echo 'installing of GNOME...'
  pacman -S gnome gnome-extra gdm --noconfirm
  systemctl enable gdm
fi

echo 'installing fonts...'
pacman -S ttf-liberation ttf-dejavu --noconfirm 

echo 'installing of base programs and packages...'
pacman -S reflector firefox firefox-i18n-ru ufw f2fs-tools dosfstools ntfs-3g alsa-lib alsa-utils file-roller p7zip unrar gvfs aspell-ru pulseaudio pavucontrol --noconfirm

read -p "if you need i3 press 1: " i_three
if [[ $i_three == 1 ]]; then
  pacman -S i3-gaps polybar dmenu pcmanfm xterm ttf-font-awesome feh gvfs udiskie ristretto tumbler picom jq --noconfirm
elif [[ $i_three != 1 ]]; then
  echo "i3 installation skipped"
fi

    
echo 'setting up the network..'
pacman -S networkmanager network-manager-applet ppp --noconfirm

echo 'setting up autoloading the login manager and internet...'
systemctl enable NetworkManager

echo 'Installation complete! Please reboot the system.'

echo '###############################################################################################################################################################################'
echo '######################################################################              ###########################################################################################'
echo '###############                                                         | THE END |                                                                           #################'
echo '######################################################################              ###########################################################################################'
echo '###############################################################################################################################################################################'
exit