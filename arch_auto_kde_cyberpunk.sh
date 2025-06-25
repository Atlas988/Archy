#!/bin/bash
set -e

echo "[*] Updating system..."
sudo pacman -Syu --noconfirm

echo "[*] Installing core packages..."
sudo pacman -S --noconfirm xorg xorg-xinit i3-gaps alacritty zsh picom rofi feh dunst lxappearance \
  network-manager-applet polybar neovim git curl unzip wget pipewire pipewire-pulse wireplumber \
  ttf-jetbrains-mono ttf-nerd-fonts-symbols pavucontrol

echo "[*] Enabling networking..."
sudo systemctl enable NetworkManager

echo "[*] Installing Oh My Zsh + Powerlevel10k..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo "[*] Setting Zsh as default shell..."
chsh -s /bin/zsh

echo "[*] Configuring Alacritty..."
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.yml <<EOF
font:
  normal:
    family: "JetBrainsMono Nerd Font"
    size: 12.5

colors:
  primary:
    background: '0x0f111a'
    foreground: '0xf8f8f2'
  normal:
    black:   '0x212337'
    red:     '0xff5555'
    green:   '0x50fa7b'
    yellow:  '0xf1fa8c'
    blue:    '0xbd93f9'
    magenta: '0xff79c6'
    cyan:    '0x8be9fd'
    white:   '0xbbbbbb'
EOF

echo "[*] Configuring Picom..."
mkdir -p ~/.config/picom
cat > ~/.config/picom/picom.conf <<EOF
backend = "glx";
vsync = true;
blur:
  method = "dual_kawase";
  strength = 7;
opacity-rule = [
  "90:class_g = 'Alacritty'",
  "95:class_g = 'Rofi'"
];
shadow = true;
corner-radius = 8;
EOF

echo "[*] Downloading Cyberpunk Rofi theme..."
mkdir -p ~/.config/rofi/themes
curl -o ~/.config/rofi/themes/cyberpunk.rasi \
  https://raw.githubusercontent.com/adi1090x/rofi-themes/master/colors/cyberpunk.rasi

echo "[*] Setting up i3 config..."
mkdir -p ~/.config/i3
cat > ~/.config/i3/config <<EOF
set \$mod Mod4
font pango:JetBrainsMono Nerd Font 10

exec_always --no-startup-id feh --bg-scale ~/Pictures/wallpaper.jpg
exec_always --no-startup-id picom --config ~/.config/picom/picom.conf
exec_always --no-startup-id nm-applet
exec_always --no-startup-id dunst

bindsym \$mod+Return exec alacritty
bindsym \$mod+d exec rofi -show drun -theme cyberpunk

bindsym \$mod+Shift+e exec "i3-nagbar -t warning -m 'Exit?' -b 'Yes' 'i3-msg exit'"

# Default i3 keybindings
bindsym \$mod+Shift+r restart
EOF

echo "[*] Setting wallpaper..."
mkdir -p ~/Pictures
curl -L -o ~/Pictures/wallpaper.jpg "https://wallpaperaccess.com/full/19885.jpg"

echo "[*] Creating .xinitrc for i3..."
echo "exec i3" > ~/.xinitrc

echo "[*] Installation complete. Reboot or run 'startx' to enter Cyberpunk i3."
