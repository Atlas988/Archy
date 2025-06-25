#!/bin/bash
set -e

# === Configuration ===
DISK="/dev/sdb"
HOSTNAME="archbox"
USERNAME="aiden"
PASSWORD="password" # Change after install
LOCALE="en_US.UTF-8"
TIMEZONE="America/New_York"
ROOT_PART="${DISK}2"
EFI_PART="${DISK}1"
SWAP_PART="${DISK}3"

# === Partition and format ===
sgdisk -Z ${DISK}
sgdisk -n1:0:+512M -t1:ef00 ${DISK}
sgdisk -n2:0:0 -t2:8300 ${DISK}
sgdisk -n3:0:+512M -t3:8200 ${DISK}

mkfs.fat -F32 ${EFI_PART}
mkfs.ext4 ${ROOT_PART}
mkswap ${SWAP_PART}

mount ${ROOT_PART} /mnt
mkdir -p /mnt/boot
mount ${EFI_PART} /mnt/boot
swapon ${SWAP_PART}

# === Install base system ===
reflector --latest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware sudo nano networkmanager grub efibootmgr git

# === Fstab ===
genfstab -U /mnt >> /mnt/etc/fstab

# === System Configuration ===
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
echo "${LOCALE} UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf
echo "${HOSTNAME}" > /etc/hostname
echo "127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}" >> /etc/hosts

# Set root password
echo root:${PASSWORD} | chpasswd

# Create user
useradd -m -G wheel -s /bin/bash ${USERNAME}
echo ${USERNAME}:${PASSWORD} | chpasswd
echo '%wheel ALL=(ALL:ALL) ALL' >> /etc/sudoers

# Install bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
systemctl enable NetworkManager
EOF

# === KDE and Cyberpunk Theme (Optional 2nd stage) ===
arch-chroot /mnt /bin/bash <<'EOF'
pacman -S --noconfirm plasma kde-applications sddm konsole firefox dolphin
systemctl enable sddm

# Cyberpunk style setup (placeholder)
mkdir -p /home/${USERNAME}/.config
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Sample theme placeholder
echo -e "[General]\ntheme=Sweet" > /home/${USERNAME}/.config/kdeglobals

EOF

echo "INSTALL COMPLETE. Reboot after unmounting."
