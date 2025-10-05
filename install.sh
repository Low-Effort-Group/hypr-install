#!/usr/bin/env bash

cyan="\e[36m"
default="\e[0m"

echo -e "Install some ${cyan}dependencies ${default}to the script, and ${cyan}update the systems packages and repositories${default}"
yes | sudo pacman -Syu gum git --needed

clear -x

dot_packages=(
  rofi-wayland
  hyprland
  swww
  qt5-wayland
  qt6-wayland
  xdg-desktop-portal
  xdg-desktop-portal-hyprland
  hyprpolkitagent
  waybar
  pavucontrol
  kitty
  noto-fonts
  noto-fonts-cjk
  ttf-jetbrains-mono-nerd
  brightnessctl
  bc
  swaync
  notify-send
  pipewire
  wireplumber
  pipewire-pulse
)

filemanager="nautilus gvfs gvfs-smb"

fish="fish fisher"

nvim="neovim ripgrep fzf gcc lazygit"

selection=$(gum choose --no-limit "Hyprland Dotfiles (recommended)" "Waybar configuration (recommended)" "Friendly interactive shell with pure (recommended)" "Arch User Repository helper (package manager, recommended)" "powerlevel10k shell" "File manager" "LazyVim text editor")
echo $selection

dotfiles_cfg() {
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Configuring hyprland dotfiles"
  rm -rf "$HOME/.config/hypr/"
  git clone https://github.com/low-effort-group/hypr/ "$HOME/.config/hypr/"
  clear -x
}

waybar_cfg() {
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Configuring waybar configuration"
  rm -rf "$HOME/.config/waybar/"
  git clone https://github.com/low-effort-group/waybar/ "$HOME/.config/waybar/"
  clear -x
}

fish_cfg() {
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Installing fish pure"
  fish -c "fisher install pure-fish/pure"
  clear -x
}

aur_helper() {
  gum confirm "Paru or yay command as your package manager (AUR helper)?" --default=true --affirmative="paru" --negative="yay" && aur="paru" || aur="yay"
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Installing $aur"
  git clone https://aur.archlinux.org/$aur-bin.git "/tmp/$aur.git"
  cd /tmp/$aur/
  makepkg -si || echo -e installing aur helper might have failed.
  clear -x
}

p10k_cfg() {
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Configuring and installing powerlevel10k with zsh"
  sudo pacman -S zsh
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
  clear -x
}

nvim_cfg() {
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Configuring neovim with lazyvim"
  rm -rf $HOME/.config/nvim
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  clear -x
}

if [[ $selection != *"Hyprland Dotfiles (recommended)"* ]]; then
  dot_packages=()
fi

if [[ $selection != *"Friendly interactive shell with pure (recommended)"* ]]; then
  fish=""
fi

if [[ $selection != *"File manager"* ]]; then
  filemanager=""
fi

if [[ $selection != *"LazyVim text editor"* ]]; then
  nvim=""
fi

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "This is the install script for $(gum style --foreground 212 'Low Effort Groups dotfiles').
This script has no mercy to existing configuration, 
if you have conflicting configuration, we kindly advise you to back it up, $(gum style --foreground 212 'as it will be destroyed'). 
After all this has no effort put into it. We will also remove pulseaudio if installed.
These are the configuration files that might get overwritten, depending on options:"

gum confirm "Do you wish to continue?" || return 1

sudo pacman -S "${dot_packages[@]}" ${fish} ${filemanager} ${nvim} --needed

while IFS= read -r selection; do
  case "$selection" in
  "Hyprland Dotfiles (recommended)")
    dotfiles_cfg
    ;;
  "Waybar configuration (recommended)")
    waybar_cfg
    ;;
  "Friendly interactive shell with pure (recommended)")
    fish_cfg
    ;;
  "Arch User Repository helper (package manager, recommended)")
    aur_helper
    ;;
  "powerlevel10k shell")
    p10k_cfg
    ;;
  "LazyVim text editor")
    nvim_cfg
    ;;
  *)
    echo "Unknown selection: $selection"
    ;;
  esac
done <<<"$selection"

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "$(gum style --foreground 212 'Installation completed!') If you installed any shells
we recommend that you $(gum style --foreground 212 'chsh -s /usr/bin/fish'), or $(gum style --foreground 212 'chsh -s /usr/bin/zsh')."
