#!/bin/bash

setup-hyprland.sh — Fully automated Hyprland setup for Arch Linux Cyberpunk themed, MLFW-style, Wayland-native environment 

set -e

Update system 

sudo pacman -Syu --noconfirm

Install base packages 

sudo pacman -S --noconfirm base-devel git curl wget unzip

Install AUR helper (paru) 

if ! command -v paru &>/dev/null; then git clone https://aur.archlinux.org/paru.git ~/paru cd ~/paru && makepkg -si --noconfirm cd ~ && rm -rf ~/paru fi

Core packages for Hyprland + tools 

paru -S --noconfirm hyprland-git waybar rofi wofi kitty 
swaybg grim slurp wl-clipboard mako playerctl 
brightnessctl network-manager-applet sddm pavucontrol 
ttf-jetbrains-mono ttf-nerd-fonts-symbols dunst pipewire pipewire-pulse wireplumber

Enable login manager 

sudo systemctl enable sddm

Wallpaper setup 

mkdir -p ~/Pictures curl -Lo ~/Pictures/cyberpunk.jpg "https://wallpaperaccess.com/full/19885.jpg"

Hyprland config setup 

mkdir -p ~/.config/hypr cat > ~/.config/hypr/hyprland.conf <<EOF exec-once = waybar exec-once = nm-applet exec-once = dunst exec-once = ~/.config/hypr/wallpaper.sh

$mod = SUPER

bind = $mod, RETURN, exec, kitty bind = $mod, Q, killactive bind = $mod, D, exec, wofi --show drun bind = $mod, E, exec, nautilus bind = $mod, F, togglefloating bind = $mod, V, exec, pavucontrol

general { gaps_in = 5 gaps_out = 10 border_size = 2 col.active_border = rgba(ff00ffaa) col.inactive_border = rgba(111111aa) layout = dwindle }

decoration { rounding = 10 blur { enabled = true size = 6 passes = 2 ignore_opacity = false new_optimizations = true } drop_shadow = true shadow_range = 20 shadow_render_power = 3 col.shadow = rgba(00000088) } EOF

Wallpaper script 

mkdir -p ~/.config/hypr cat > ~/.config/hypr/wallpaper.sh <<EOF #!/bin/bash swaybg -i ~/Pictures/cyberpunk.jpg --mode fill EOF chmod +x ~/.config/hypr/wallpaper.sh

Waybar config 

mkdir -p ~/.config/waybar cat > ~/.config/waybar/config.jsonc <<EOF { "layer": "top", "position": "top", "modules-left": ["clock", "pulseaudio", "network", "tray"], "modules-center": [], "modules-right": ["battery", "cpu", "memory"] } EOF

Auto start Hyprland session 

echo "exec Hyprland" > ~/.xinitrc

echo "[✓] Hyprland cyberpunk setup complete. Reboot and select 'Hyprland' from SDDM."

