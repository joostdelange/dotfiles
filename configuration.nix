{ config, pkgs, ... }:

{
  imports =
    [
      # It is recommend to import your hardware-configuration.nix here
      # ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure networking.
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.joostdelange = {
    isNormalUser = true;
    description = "Joost de Lange";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    firefox
    gnome.gnome-tweaks

    # Nerd Fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Home Manager configuration
  home-manager.users.joostdelange = {
    home.stateVersion = "23.11"; # Please change this to your version of NixOS

    programs.home-manager.enable = true;

    # Git configuration
    programs.git = {
      enable = true;
      userName = "Joost de Lange";
      userEmail = "";
      extraConfig = {
        core = {
          editor = "nvim";
        };
        init = {
          defaultBranch = "main";
        };
      };
    };

    # Zsh configuration
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      shellAliases = {
        v = "nvim";
        svim = "sudo nvim";
      };
      oh-my-zsh = {
        enable = true;
        theme = "dieter";
        plugins = [ "git" ];
      };
      initExtra = ''
        export EDITOR='nvim'
      '';
    };

    # Tmux configuration
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      plugins = with pkgs.tmuxPlugins; [
        tpm
        sensible
        vim-tmux-navigator
        catppuccin
        yank
      ];
      extraConfig = ''
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
      '';
    };

    # Ghostty terminal emulator configuration
    programs.ghostty = {
      enable = true;
      settings = {
        "font-size" = 14;
        "font-family" = "JetBrainsMono Nerd Font";
        theme = "dark";
      };
    };

    # Zed editor configuration
    programs.zed = {
      enable = true;
      settings = {
        theme = "Catppuccin Mocha";
        vim_mode = true;
        ui_font_size = 16;
        buffer_font_size = 16;
        ui_font_family = "JetBrainsMono Nerd Font";
        buffer_font_family = "JetBrainsMono Nerd Font";
      };
      keymap = pkgs.lib.fromJson '''
      [
        {
          "context": "Editor && vim_mode == normal",
          "bindings": {
            "space": "file_finder::Toggle"
          }
        },
        {
          "context": "Editor && vim_mode == visual",
          "bindings": {
            "space": "file_finder::Toggle"
          }
        }
      ]
      ''';
    };

    # Dconf (Gnome) settings
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Yaru-dark";
        icon-theme = "Yaru-plus-dark";
      };
      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-1 = ["<Super>1"];
        switch-to-workspace-2 = ["<Super>2"];
        switch-to-workspace-3 = ["<Super>3"];
        switch-to-workspace-4 = ["<Super>4"];
        switch-to-workspace-5 = ["<Super>5"];
        move-to-workspace-1 = ["<Super><Shift>1"];
        move-to-workspace-2 = ["<Super><Shift>2"];
        move-to-workspace-3 = ["<Super><Shift>3"];
        move-to-workspace-4 = ["<Super><Shift>4"];
        move-to-workspace-5 = ["<Super><Shift>5"];
      };
      "org/gnome/shell/keybindings" = {
        switch-to-application-1 = [];
        switch-to-application-2 = [];
        switch-to-application-3 = [];
        switch-to-application-4 = [];
        switch-to-application-5 = [];
        switch-to-application-6 = [];
        switch-to-application-7 = [];
        switch-to-application-8 = [];
        switch-to-application-9 = [];
      };
      "org/gnome/mutter/keybindings" = {
        switch-monitor = ["<Super>u"];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/",
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
        www = [];
        email = [];
        calculator = [];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Open terminal";
        command = "ghostty";
        binding = "<Super>Return";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "Open browser";
        command = "firefox";
        binding = "<Super>b";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
