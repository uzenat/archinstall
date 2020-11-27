#!/bin/bash



# Formatage des partitions :
#---------------------------

# Partition :
# /dev/sda1 /boot
# /dev/sda2 swap
# /def/sda3 /
# /dev/sda4 /home

mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4
mkswap /dev/sda2



# Montage des partitions :
#-------------------------

# Partition systeme
mount /dev/sda3 /mnt

# Partition utilisateur
mkdir /mnt/home && mount /dev/sda4 /mnt/home

# Swap
swapon /dev/sda2

# Partition boot
mkdir /mnt/boot && mount /dev/mnt/boot



# Selection du mirror :
#----------------------

# Installation de pacman-contrib
yes | pacman -S pacman-contrib

# Création d'un fichier de backup des mirroirs
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Decommenter tout les mirroirs du backup
sed -s 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup

# Choisir le meilleur mirroir
rankmirrors -n 1 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist



# Installation des paquets de base :
#-----------------------------------

pacstrap /mnt base linux linux-firmware
