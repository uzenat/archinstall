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



# Configuration du system :
#--------------------------

# générer le fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# Chrooter dans le nouveau system
arch-chroot /mnt

# Renseigner le nom de la machine dans /etc/hostname & /etc/hosts
echo p4nd3m1k > /etc/hostname
echo '127.0.1.1 p4nd3m1k.localdomain p4nd3m1k' >> /etc/hosts

# Choix du fuseau horaire
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime


