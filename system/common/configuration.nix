{
  pkgs,
  host,
  ...
}:
{
  # Define your hostname
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    firewall.enable = true;
  };
  environment.systemPackages = with pkgs; [ networkmanagerapplet ];

  # Set your time zone
  time.timeZone = "Asia/Tokyo";

  i18n = {
    # Select internationalisation properties
    defaultLocale = "ja_JP.UTF-8";
    # Select internationalisation properties
    extraLocaleSettings = {
      LC_ADDRESS = "ja_JP.UTF-8";
      LC_IDENTIFICATION = "ja_JP.UTF-8";
      LC_MEASUREMENT = "ja_JP.UTF-8";
      LC_MONETARY = "ja_JP.UTF-8";
      LC_NAME = "ja_JP.UTF-8";
      LC_NUMERIC = "ja_JP.UTF-8";
      LC_PAPER = "ja_JP.UTF-8";
      LC_TELEPHONE = "ja_JP.UTF-8";
      LC_TIME = "ja_JP.UTF-8";
    };
    # Japanese Input
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-mozc ];
      fcitx5.waylandFrontend = true;
    };
  };

  console = {
    # seems to break virtual-console service because it can't find the font
    # https://github.com/NixOS/nixpkgs/issues/257904
    # font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services = {
    # Configure keymap in X11
    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
      # remove xterm
      excludePackages = [ pkgs.xterm ];
    };

    # use dbus broker as default implementation
    dbus.implementation = "broker";

    # Enable fwupd (firmware updater)
    fwupd.enable = true;

    # Enable disk monitoring
    smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        wall.enable = true;
      };
    };
  };

  # enable opengl
  hardware.graphics.enable = true;

  # zram
  zramSwap = {
    enable = true;
    priority = 32767; # Use as the primary swap device
  };

  # do not change this value
  system.stateVersion = "24.05";
}
