{ pkgs, config, lib, ... }:

let
  tableplusAppImage = pkgs.fetchurl {
    url = "https://tableplus.com/release/linux/x64/TablePlus-x64.AppImage";
    sha256 = "sha256-4HIPkWqpIcyycpqs3ELcQZUlgmcXeHxdsJ6gS8YmIAg=";
  };

  tableplus = pkgs.appimageTools.wrapType2 {
    name = "tableplus";
    src = tableplusAppImage;
    version = "1.0";
    pname = "tableplus";
    extraInstallCommands = ''
      mkdir -p $out/bin
      ln -s $src $out/bin/tableplus
    '';
  };

  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

in
{
  imports = [./home-overrides.nix];

  home = {
    stateVersion = "25.05";
    packages = [
      pkgs.wget
      pkgs.curl
      pkgs.git
      pkgs.jq
      pkgs.nixd
      pkgs.nil
      pkgs.oh-my-zsh
      pkgs.tmux
      pkgs.starship
      pkgs.awscli2
      pkgs.typescript
      pkgs.rustc
      pkgs.rust-analyzer
      pkgs.cargo
      pkgs.binutils
      pkgs.esbuild
      pkgs.nodePackages.ts-node
      pkgs.nerd-fonts.hack
      pkgs.pnpm
      pkgs.docker
      pkgs.nodejs_22
      pkgs.appimage-run
      pkgs.google-chrome
      unstable.zed-editor
      pkgs.package-version-server
      pkgs.ghostty
      pkgs.neovim
      pkgs.caligula
      tableplus
      pkgs.stremio
      pkgs.yaru-theme
      pkgs.gnomeExtensions.dash-to-dock
      pkgs.gnomeExtensions.no-overview
      pkgs.fw-ectool
    ];
    sessionVariables = {
      EDITOR = "zeditor";
      NO_BUN = "true";
      NIXOS_OZONE_WL = "1";
    };
    file = {
      ".config/zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink ../zed/settings.json;
      ".config/zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink ../zed/keymap.json;
      ".config/google-chrome/First Run".text = "";
      ".npmrc".text = ''
        prefix = ~/.cache/npm
      '';
    };
    activation = {
      setPowerMode = lib.hm.dag.entryAfter ["installPackages"] ''
        /run/current-system/sw/bin/powerprofilesctl set performance
      '';
    };
  };

  xdg = {
    desktopEntries = {
      tableplus = {
        name = "Tableplus";
        genericName = "Tableplus";
        exec = "tableplus %U";
        terminal = false;
        icon = "${config.home.homeDirectory}/Pictures/tableplus.png";
      };
    };
  };

  fonts = {
    fontconfig = { enable = true; };
  };

  programs = {
    home-manager = { enable = true; };
    gpg = { enable = true; };
    git = {
      enable = true;
      extraConfig = {
        pull = { rebase = false; };
        push = { default = "current"; };
        commit = { gpgsign = true; };
        core = { editor = "nvim"; };
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = { enable = true; };

      oh-my-zsh = {
        enable = true;
        plugins = ["git"];
        theme = "robbyrussell";
      };

      shellAliases = {
        ww = "cd ~/Projects";
      };
      initContent = ''
        awsswitch() {
          export AWS_PROFILE=$1;
          echo $1 > ~/.aws/current_sso_profile;
        }

        awsswitch $(cat ~/.aws/current_sso_profile)
      '';
    };
    tmux = {
      enable = true;
      mouse = true;
      extraConfig = ''
      set -g default-terminal "screen-256color"
      set -ag terminal-overrides ",xterm-256color:Tc"
      '';
    };
    starship = {
      enable = true;
    };
    ghostty = {
      enable = true;
      settings = {
        cursor-style = "bar";
        background-opacity = 0.9;
        link-url = true;
        command = "tmux";
      };
    };
    google-chrome = {
      enable = true;
    };
  };

  dconf = {
    settings = {
      "org/gnome/control-center" = {
        last-panel = "power";
        window-state = "(980, 640, false)";
      };
      "org/gnome/desktop/app-folders" = {
        folder-children = [ "Utilities" "YaST" "Pardus" ];
      };
      "org/gnome/desktop/app-folders/folders/Pardus" = {
        categories = [ "X-Pardus-Apps" ];
        name = "X-Pardus-Apps.directory";
        translate = true;
      };
      "org/gnome/desktop/app-folders/folders/Utilities" = {
        apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" ];
        categories = [ "X-GNOME-Utilities" ];
        name = "X-GNOME-Utilities.directory";
        translate = true;
      };
      "org/gnome/desktop/app-folders/folders/YaST" = {
        categories = [ "X-SuSE-YaST" ];
        name = "suse-yast.directory";
        translate = true;
      };
      "org/gnome/desktop/applications/terminal" = {
        exec = "ghostty";
      };
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "";
        picture-uri-dark = "";
        primary-color = "#000000";
        secondary-color = "#000000";
      };
      "org/gnome/desktop/input-sources" = {
        sources = "[('xkb', 'us')]";
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "orange";
        show-battery-percentage = true;
        icon-theme = "Yaru";
        gtk-theme = "Yaru";
        cursor-theme = "Yaru";
      };
      "org/gnome/desktop/peripherals/keyboard" = {
        delay = 300;
        repeat-interval = 14;
      };
      "org/gnome/desktop/peripherals/mouse" = {
        speed = -0.3;
      };
      "org/gnome/desktop/screensaver" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "";
        primary-color = "#000000";
        secondary-color = "#000000";
      };
      "org/gnome/desktop/session" = {
        idle-delay = 0;
      };
      "org/gnome/evolution-data-server" = {
        migrated = true;
      };
      "org/gnome/mutter" = {
        edge-tiling = false;
      };
      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left = "@as []";
        toggle-tiled-right = "@as []";
      };
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "icon-view";
        migrated-gtk-settings = true;
        search-filter-time-type = "last_modified";
        show-hidden-files = true;
      };
      "org/gnome/nautilus/window-state" = {
        initial-size = "(890, 550)";
      };
      "org/gnome/settings-daemon/plugins/power" = {
        ambient-enabled = false;
        idle-dim = false;
        sleep-inactive-ac-timeout = 0;
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "nothing";
      };
      "org/gnome/shell" = {
        favorite-apps = ["org.gnome.Nautilus.desktop" "google-chrome.desktop" "dev.zed.Zed.desktop" "com.mitchellh.ghostty.desktop" "tableplus.desktop"];
        welcome-dialog-last-shown-version = "47.0";
        enabled-extensions = ["dash-to-dock@micxgx.gmail.com" "no-overview@fthx"];
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "LEFT";
        intellihide = false;
        dash-max-icon-size = 50;
        show-apps-always-in-the-edge = true;
        show-mounts = false;
        show-show-apps-button = false;
        show-trash = false;
      };
      "org/gnome/shell/extensions/ding" = {
        check-x11wayland = true;
        show-home = false;
      };
      "org/gnome/shell/extensions/tiling-assistant" = {
        active-window-hint-color = "rgb(211,70,21)";
        last-version-installed = 48;
        overridden-settings = "{'org.gnome.mutter.edge-tiling': <@mb nothing>, 'org.gnome.mutter.keybindings.toggle-tiled-left': <@mb nothing>, 'org.gnome.mutter.keybindings.toggle-tiled-right': <@mb nothing>}";
        tiling-popup-all-workspace = true;
      };
      "org/gnome/shell/ubuntu" = {
        startup-sound = "";
      };
      "org/gnome/shell/world-clocks" = {
        locations = "@av []";
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = false;
        sort-directories-first = true;
      };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };
}
