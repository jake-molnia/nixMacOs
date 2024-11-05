{ config, pkgs, ... }:

let user = "jake"; in

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
  ];

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.checks.verifyNixPath = false;

  environment.systemPackages = with pkgs; [
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  system = {
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;         # Show hidden files
        ApplePressAndHoldEnabled = false;
        AppleTemperatureUnit = "Celsius";
        NSAutomaticWindowAnimationsEnabled = false; # disables animations
        NSTableViewDefaultSizeMode = 1;   # finder sidebar icons size
        PMPrintingExpandedStateForPrint = true; # expanded print pannel by default

        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
        AppleICUForce24HourTime = true;     # Enables 24-hour clock format
        AppleInterfaceStyle = "Dark";
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "left";
        tilesize = 1;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
        FXDefaultSearchScope = "SCcf";   # sets mac search scope to current folder
        FXEnableExtensionChangeWarning = false; # no warning when changing extension of file
        FXPreferredViewStyle = "clmv";      # default view to column view
        NewWindowTarget = "Home";
        ShowPathbar = true; 
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };

      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 2;
        ShowDayOfMonth = false; 
        ShowDayOfWeek = false; 
        ShowSeconds = false; 
      };

      #universalaccess = {
      #  reduceMotion = true;
      #};

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      WindowManager.EnableStandardClickToShowDesktop = false;

    };
    startup.chime = false; # becuase fuck that
  };

  # Font Configuration
  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })  # Install Hack Nerd Font for terminal use
  ];

  security.pam.enableSudoTouchIdAuth = true;    # enable fingerprint for sudo
}
