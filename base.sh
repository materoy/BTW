#!/bin/bash

timedatectl set-ntp true

echo List of all disks
lsblk

echo Enter boot disk
read boot_disk

echo Enter root disk 
read root_disk

echo Enter home disk
read home_disk

echo Enter swap partition
read swap_disk

mkfs.ext4 $root_disk

mkswap $swap_partition

# Mount disks
mount $root_disk /mnt

mount $boot_disk /mnt/boot

if [[ condition ]]; then
  mkfs.ext4 $home_disk
  mount $home_disk /mnt/home
fi

swapon $swap_disk

pacstrap /mnt base linux linux-firmware


genfstab -U /mnt >> /mnt/etc/fstab

arch-choot /mnt


ln -sf /usr/share/zoneinfo/Africa/Nairobi /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf

# Hostname
echo Enter hostname
read hostname

echo $hostname >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts

echo Input root password
read root_passwd

echo root:$root_passwd | chpasswd

# You can add xorg to the installation packages, I usually add it at the DE or WM install script
# You can remove the tlp package if you are installing on a desktop or vm

pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font

# pacman -S --noconfirm xf86-video-amdgpu
pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp # You can comment this command out if you didn't install tlp, see above
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid


# User related
echo Enter username
read username

echo Enter password for $username
read user_passwd

useradd -m $username
echo $username:$user_passwd | chpasswd

usermod -aG libvirt $username

echo "$username ALL=(ALL) ALL" >> /etc/sudoers.d/$username


printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"
