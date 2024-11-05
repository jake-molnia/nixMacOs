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

  # Python packages
  python3

  # To be sorted
  devenv
  vscode
  zsh-syntax-highlighting
  zsh-autosuggestions
  starship
  tlrc
  neovim
  eza
]
