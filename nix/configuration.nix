{ ... }:

{
  imports = [/etc/nixos/hardware-configuration.nix ./configuration-overrides.nix];

  boot = {
    loader = {
      systemd-boot = { enable = true; };
      efi = { canTouchEfiVariables = true; };
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager = { enable = true; };
  };

  time = { timeZone = "Europe/Amsterdam"; };

  programs = {
    zsh = { enable = true; };
  };

  services = {
    xserver = {
      enable = true;
      displayManager = {
        gdm = { enable = true; };
      };
      desktopManager = {
        gnome = { enable = true; };
      };
      xkb = { layout = "us"; };
      xautolock = { time = 0; };
    };
    printing = { enable = true; };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse = { enable = true; };
    };
    mullvad-vpn = {
      enable = true;
    };
  };

  security = {
    rtkit = { enable = true; };
  };

  virtualisation = {
    docker = { enable = true; };
  };

  system.stateVersion = "25.05";
}
