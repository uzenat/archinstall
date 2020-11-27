#!/bin/bash



# Set variables :
#----------------

export hostname='p4nd3m1k'


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
mkdir /mnt/boot && mount /dev/sda3 /mnt/boot



# Selection du mirror :
#----------------------

# Installation de pacman-contrib
yes | pacman -S pacman-contrib

# Création d'un fichier de backup des mirroirs
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Decommenter tout les mirroirs du backup
sed -s 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Choisir le meilleur mirroir
rankmirrors -n 1 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist



# Installation des paquets de base :
#-----------------------------------

pacstrap /mnt base linux linux-firmware



# Configuration du system :
#--------------------------

# printer
echo "######################################"
echo "#       CONFIGURATION DU SYSTEME     #"
echo "######################################"

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

# Configurez /etc/mkinitcpio.conf et créez les RAMdisks initiaux
mkinitcpio -p linux



