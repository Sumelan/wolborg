{
  lib,
  config,
  ...
}:
lib.mkIf config.custom.niri.enable
{
  programs.niri = {
    settings = {
      environment = {
        CLUTTER_BACKEND = "wayland";
        DISPLAY = ":0";
        GDK_BACKEND = "wayland,x11";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        SDL_VIDEODRIVER = "wayland";
      };

      input = {
        keyboard.xkb.layout = "us";
        touchpad = {
          click-method = "button-areas";
          dwt = true;
          dwtp = true;
          natural-scroll = true;
          scroll-method = "two-finger";
          tap = true;
          tap-button-map = "left-right-middle";
          accel-profile = "adaptive";
          # scroll-factor = 0.1;
        };
        focus-follows-mouse.enable = true;
        warp-mouse-to-focus = true;
        workspace-auto-back-and-forth = true;
      };

      # NOTE outputs setting is in hosts specific home

      cursor = {
        size = 20;
        theme = "${config.home.pointerCursor.name}";
      };

      layout = {
        focus-ring.enable = false;
        border = with config.lib.stylix.colors.withHashtag; {
          enable = true;
          width = 1;
          active.color = "${base0D}";
          inactive.color = "${base00}";
        };

        preset-column-widths = [
          {proportion = 1.0 / 3.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 2.0 / 3.0;}
          {proportion = 1.0;}
        ];
        default-column-width = {proportion = 1.0 / 2.0;};

        gaps = 8;
        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };
      };
      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;
    };
  };
}
