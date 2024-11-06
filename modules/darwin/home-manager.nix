{ config, pkgs, lib, home-manager, ... }:

let
  user = "jake";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
    masApps = {
      "Bitwarden" = 1352778147;                 	# Password manager
      "Commander One" = 1035236694;            		# Dual-pane file manager
      "Hidden Bar" = 1452453066;                	# Hide menu bar items
      "Microsoft Remote Desktop" = 1295203466;   	# Remote access to Windows PCs
      "Omnivore" = 1564031042;                  	# Read-it-later and web content saving
      "TickTick" = 966085870;                   	# Task management and to-do lists
      "XCode" = 497799835;                     		# Apple's IDE for iOS/macOS development
      "Goodnotes" = 1444383602;                 	# Digital note-taking app
    };

    brews = [
      "zsh-syntax-highlighting"
      "zsh-autosuggestions"
    ];
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];
        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    
  ];

}
