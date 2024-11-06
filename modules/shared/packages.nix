{ pkgs }:

with pkgs; [
  # General packages for development and system management
  alacritty
  bat
  btop
  wget
  zip

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Text and terminal utilities
  htop
  ripgrep
  tree
  tmux
  unrar
  unzip
  ranger
  oh-my-zsh

  # Python packages
  python3
  pipx

  # To be sorted
  devenv
  vscode
  starship
  tlrc
  #neovim ### Dont know why its still installed but it works 
  eza
  micromamba
  direnv
]
