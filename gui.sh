#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c Kenya -a 6 --sort rate --save /etc/pacman.d/mirrorlist

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

git clone https://aur.archlinux.org/pikaur.git
cd pikaur/
makepkg -si --noconfirm
cd ..

pikaur -S --noconfirm system76-power
sudo systemctl enable --now system76-power
sudo system76-power graphics integrated
pikaur -S --noconfirm auto-cpufreq
sudo systemctl enable --now auto-cpufreq

sudo pacman -S --noconfirm xorg sddma i3 vlc 

sudo systemctl enable sddm

git clone git://git.suckless.org/dwm
cd dwm
make
make install 
cd ..

/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
reboot
