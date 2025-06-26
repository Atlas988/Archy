#!/bin/bash
set -e

echo "[*] Updating system..."
sudo pacman -Syu --noconfirm

echo "[*] Installing KDE Plasma desktop and apps..."
sudo pacman -S --noconfirm plasma-meta kde-applications sddm konsole dolphin ark \
  spectacle neofetch vlc gwenview pipewire pipewire-pulse wireplumber \
  firefox ttf-jetbrains-mono ttf-nerd-fonts-symbols unzip git curl

echo "[*] Enabling GUI login (sddm)..."
sudo systemctl enable sddm

echo "[*] Installing theme and icons..."
# Install sweet theme and Tela icons
paru -S --noconfirm sweet-gtk-theme-git sweet-kde-theme-git tela-icon-theme dracula-cursors-git

echo "[*] Applying theme configuration..."
mkdir -p ~/.local/share/plasma/desktoptheme
mkdir -p ~/.icons
mkdir -p ~/.themes

# Set KDE global themes (requires logged-in KDE session)
cat > ~/.config/kdeglobals <<EOF
[Icons]
Theme=Tela

[General]
ColorScheme=Sweet

[PlasmaTheme]
name=Sweet
EOF

cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Sweet-Dark
gtk-icon-theme-name=Tela
EOF

echo "[*] Setting cursor..."
cat > ~/.icons/default/index.theme <<EOF
[Icon Theme]
Name=Dracula
Inherits=Dracula
EOF

echo "[*] Downloading cyberpunk wallpaper..."
mkdir -p ~/Pictures
curl -L -o ~/Pictures/cyberpunk.jpg "https://wallpaperaccess.com/full/19885.jpg"

echo "[*] Configuring autostart wallpaper..."
mkdir -p ~/.config/plasma-workspace/env
cat > ~/.config/plasma-workspace/env/set-wallpaper.sh <<EOF
#!/bin/sh
plasma-apply-wallpaperimage ~/Pictures/cyberpunk.jpg
EOF
chmod +x ~/.config/plasma-workspace/env/set-wallpaper.sh

echo "[*] KDE Plasma setup complete."
echo "[+] Reboot your system, log into KDE, then:"
echo "    - Right-click the Start Menu icon > Show Alternatives > Select Application Dashboard"
echo "    - Go to System Settings > Appearance to confirm Cyberpunk theme applied"
