{ pkgs, ... }:
{
  monitors = {
    "HDMI-A-1" = {
      isMain = true;
      scale = 1.00;
      mode = {
        width = 2560;
        height = 1440;
        refresh = 59.951;
      };
      position = {
        x = 0;
        y = 0;
      };
      rotation = 0;
    };
    "DP-1" = {
      scale = 1.0;
      mode = {
        width = 2560;
        height = 1440;
        refresh = 59.951;
      };
      position = {
        x = 0;
        y = 1440;
      };
      rotation = 0;
    };
  };

  custom = {
    # theme
    stylix = {
      icon = {
        package = pkgs.catppuccin-papirus-folders.override {
          flavor = "frappe";
          accent = "peach";
        };
        darkName = "Papirus-Dark";
        lightName = "Papirus-Light";
      };
    };

    brave.enable = false;
    cyanrip.enable = true;
    ebook.enable = true;
    inkscape.enable = true;
    krita.enable = true;
    thunderbird.enable = false;
  };
}
