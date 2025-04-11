{
  lib,
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    libnotify
  ];

  services.dunst = {
    enable = true;
    settings =
      with config.lib.stylix.colors.withHashtag;
      let
        inherit (config.stylix) fonts;
        dunstOpacity = lib.toHexString (
          ((builtins.floor (config.stylix.opacity.popups * 100 + 0.5)) * 255) / 100
        );
      in
      {
        global = {
          origin = "top-center";
          separator_color = base02;
          font = "${fonts.sansSerif.name} ${toString fonts.sizes.popups}";
          offset = "(20, 20)";
          alignment = "center";
          browser = "librewolf -new-tab";
          corner_radius = 8;
          dmenu = "rofi -dmenu -p dunst";
          enable_recursive_icon_lookup = true;
          ellipsize = "end";
          follow = "mouse";
          frame_width = 2;
          max_icon_size = 72;
          mouse_left_click = "do_action";
          mouse_middle_click = "do_action";
          mouse_right_click = "close_current";
          separator_height = 1;
          show_indicators = "no";
        };

        urgency_normal = {
          background = base01 + dunstOpacity;
          foreground = base05;
          frame_color = base0E;
          timeout = 10;
        };
        urgency_critical = {
          background = base01 + dunstOpacity;
          foreground = base05;
          frame_color = base08;
          timeout = 0;
        };
        urgency_low = {
          background = base01 + dunstOpacity;
          foreground = base05;
          frame_color = base0B;
          timeout = 10;
        };

      };
  };
}
