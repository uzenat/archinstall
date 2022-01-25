#!/bin/bash



# Set variables :
#----------------

# Hostname
export hostname='p4nd3m1k'

# Partitions size
export boot_size="+300M"
export swap_size="+500M"
export root_size="+3G"


# Creation des partitions :
#--------------------------

echo "- Create partitions :"

echo -n "  > Create boot partition (/boot)..."
(echo n; echo p; echo 1; echo ''; echo $boot_size; echo w) | fdisk /dev/sda > /dev/null
echo "[OK]"

echo -n "  > Create Swap partition..........."
(echo n; echo p; echo 2; echo ''; echo $swap_size; echo w) | fdisk /dev/sda > /dev/null
echo "[OK]"

echo -n "  > Create Root partition (/)......."
(echo n; echo p; echo 3; echo ''; echo $root_size; echo w) | fdisk /dev/sda > /dev/null
echo "[OK]"

echo -n "  > Create Home partition (/home)..."
(echo n; echo p; echo ''; echo ''        ; echo w) | fdisk /dev/sda > /dev/null
echo "[OK]"



# Formatage des partitions :
#---------------------------

# Partition :
# /dev/sda1 /boot
# /dev/sda2 swap
# /def/sda3 /
# /dev/sda4 /home

echo -n "- Format partitions................."

mkfs.ext2 /dev/sda1 > /dev/null 2> /dev/null
mkfs.ext4 /dev/sda3 > /dev/null 2> /dev/null
mkfs.ext4 /dev/sda4 > /dev/null 2> /dev/null
mkswap /dev/sda2    > /dev/null 2> /dev/null

echo "[OK]"


# Montage des partitions :
#-------------------------

echo -n "Create reo & mount partitions......."

# Partition systeme
mount /dev/sda3 /mnt > /dev/null

# Partition utilisateur
mkdir /mnt/home && mount /dev/sda4 /mnt/home > /dev/null

# Swap
swapon /dev/sda2 > /dev/null

# Partition boot
mkdir /mnt/boot && mount /dev/sda1 /mnt/boot > /dev/null

echo "[OK]"



# Selection du mirror :
#----------------------

echo -n "- Select best mirror... "

# Installation de pacman-contrib
echo y | pacman -Sy pacman-contrib > /dev/null

# Création d'un fichier de backup des mirroirs
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Decommenter tout les mirroirs du backup
sed -s 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Choisir le meilleur mirroir
rankmirrors -n 1 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

echo "[OK]"



# Installation des paquets de base :
#-----------------------------------

echo -n "- Install base package... "

pacstrap /mnt base linux linux-firmware > /dev/null

echo "[OK]"


# Configuration du system :
#--------------------------

echo "- System configure"

# générer le fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# Chrooter dans le nouveau system
#arch-chroot /mnt

# Renseigner le nom de la machine dans /etc/hostname & /etc/hosts
echo $hostname > /mnt/etc/hostname
echo "127.0.1.1 $hostname.localdomain $hostname" >> /mnt/etc/hosts

# Choix du fuseau horaire
ln -sf /mnt/usr/share/zoneinfo/Europe/Paris /mnt/etc/localtime

# Decommenter notre local dans /etc/locale.gen
cp /mnt/etc/locale.gen /mnt/etc/locale.gen.backup
sed -s 's/^#fr_FR.UTF-8/fr_FR.UTF-8/' /mnt/etc/locale.gen.backup > /mnt/etc/locale.gen

# Run local-gen
locale-gen

# Ajoutez le nom de la locale au fichier /etc/locale.conf
echo LANG="fr_FR.UTF-8" > /mnt/etc/locale.conf

# Spécifier la locale pour la session courante
export LANG=fr_FR.UTF-8

# Éditez le fichier /etc/vconsole.conf afin d'y spécifier la disposition de clavier
echo KEYMAP=fr > /mnt/etc/vconsole.conf

echo "[OK]"



# Install grub :
#---------------

echo "- Install grub"

echo y | pacman -S grub-bios

grub-install --root-directory=/mnt /dev/sda
grub-mkconfig -o /mnt/boot/grub/grub.cfg



# Network :
#----------

# Install net tools
pacman -S net-tools

# Install dhcpcd
pacman -S dhcpcd

# Active
systemctl start dhcpcd@<interface>
systemctl enable dhcpcd@<interface>



# GUI :
#------

# Installer xorg
pacman -Syu xorg-server
pacman -Syu xorg-xinit xorg-twm xorg-xclock xterm

# Installer xmonad
pacman -S xmonad

pacman -S xorg-xinit xorg-twm xorg-xclock xterm


