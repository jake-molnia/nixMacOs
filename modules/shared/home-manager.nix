{ config, pkgs, lib, ... }:

let name = "Jacob Molnia";
    user = "jake";
    email = "jrmolnia@wpi.edu"; in
{
  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = false;
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "starship";
        src = pkgs.starship;
      }
    ];

    initExtraFirst = ''
      # Path Configuration
      export PATH="$PATH:/Users/jake/.local/bin"
      export ZSH="$HOME/.oh-my-zsh"

      # Theme Configuration
      ZSH_THEME="" # Disabled to use Starship instead

      # Oh My Zsh Configuration
      ENABLE_CORRECTION="true"
      source $ZSH/oh-my-zsh.sh

      # Custom Aliases
      alias zshconfig="nvim ~/.zshrc"
      alias code="code -n"
      alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"

      # FZF Configuration
      source <(fzf --zsh)

      # Bat Theme Configuration
      export BAT_THEME="gruvbox-dark"

      # Initialize Starship
      eval "$(starship init zsh)"
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
	    editor = "vim";
        autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  alacritty = {
    enable = true;
    settings = {
      cursor = {
        style = "Line";
      };

      window = {
        opacity = 1.0;
        padding = {
          x = 48;
          y = 48;
        };
      };

      font = {
        normal = {
          family = "Hack Nerd Font";
          style = "Regular";
        };
        size = lib.mkMerge [
          (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 10)
          (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 4)
        ];
      };

      dynamic_padding = true;
      decorations = "full";
      title = "Terminal";
      class = {
        instance = "Alacritty";
        general = "Alacritty";
      };

      colors = {
        primary = {
          background = "0x1f2528";
          foreground = "0xc0c5ce";
        };

        normal = {
          black = "0x1f2528";
          red = "0xec5f67";
          green = "0x99c794";
          yellow = "0xfac863";
          blue = "0x6699cc";
          magenta = "0xc594c5";
          cyan = "0x5fb3b3";
          white = "0xc0c5ce";
        };

        bright = {
          black = "0x65737e";
          red = "0xec5f67";
          green = "0x99c794";
          yellow = "0xfac863";
          blue = "0x6699cc";
          magenta = "0xc594c5";
          cyan = "0x5fb3b3";
          white = "0xd8dee9";
        };
      };
    };
  };

  ssh = {
    enable = true;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
    matchBlocks = {
      "github.com" = {
        identitiesOnly = true;
        identityFile = [
          (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
            "/home/${user}/.ssh/id_github"
          )
          (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
            "/Users/${user}/.ssh/id_github"
          )
        ];
      };
    };
  };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
      yank
      prefix-highlight
      {
        plugin = power-theme;
        extraConfig = ''
           set -g @tmux_power_theme 'gold'
        '';
      }
      {
        plugin = resurrect; # Used by tmux-continuum

        # Use XDG data directory
        # https://github.com/tmux-plugins/tmux-resurrect/issues/348
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-pane-contents-area 'visible'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
    ];
    terminal = "screen-256color";
    prefix = "C-x";
    escapeTime = 10;
    historyLimit = 50000;
    extraConfig = ''
      # Remove Vim mode delays
      set -g focus-events on

      # Enable full mouse support
      set -g mouse on

      # -----------------------------------------------------------------------------
      # Key bindings
      # -----------------------------------------------------------------------------

      # Unbind default keys
      unbind C-b
      unbind '"'
      unbind %

      # Split panes, vertical or horizontal
      bind-key x split-window -v
      bind-key v split-window -h

      # Move around panes with vim-like bindings (h,j,k,l)
      bind-key -n M-k select-pane -U
      bind-key -n M-h select-pane -L
      bind-key -n M-j select-pane -D
      bind-key -n M-l select-pane -R

      # Smart pane switching with awareness of Vim splits.
      # This is copy paste from https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
      '';
    };
}
