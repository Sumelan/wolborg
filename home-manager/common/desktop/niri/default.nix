{
  config,
  ...
}:
{
  imports = [
    ./animations.nix
    ./autostart.nix
    ./idle.nix
    ./keybinds.nix
    ./lock.nix
    ./monitors.nix
    ./rules.nix
  ];

  # start niri-session
  custom.autologinCommand = "niri-session";

  programs.niri = {
    settings =
      with config.lib.stylix.colors.withHashtag;
      let
        shadowConfig = {
          enable = true;
          spread = 0;
          softness = 10;
          color = "#000000dd";
        };
      in
      {
        hotkey-overlay.skip-at-startup = true;
        prefer-no-csd = true;

        input = {
          focus-follows-mouse.enable = true;
          touchpad.natural-scroll = true;
          # niri will take over the power button to make it sleep by default
          power-key-handling.enable = false;
        };

        cursor = {
          theme = config.stylix.cursor.name;
          size = config.stylix.cursor.size;
        };

        outputs = builtins.mapAttrs (name: value: {
          inherit (value) scale mode position;
          transform.rotation = value.rotation;
          background-color = base01;
        }) config.monitors;

        gestures = {
          dnd-edge-view-scroll = {
            trigger-width = 60;
            delay-ms = 100;
            max-speed = 1500;
          };
        };

        layout = {
          gaps = 12;
          border = {
            enable = true;
            width = 3;
            active = {
              gradient = {
                from = base08;
                to = base09;
                angle = 45;
                in' = "oklab";
                # relative-to = "workspace-view";
              };
            };
            # inactive.color = "#585b70";
            inactive.color = base02;
          };

          focus-ring.enable = false;

          struts = {
            left = 2;
            right = 2;
            top = 0;
            bottom = 2;
          };

          insert-hint = {
            enable = true;
            display = {
              gradient = {
                # from = "#f9e2af";
                from = base0A;
                # to = "#eba0ac";
                to = base09;
                angle = 45;
              };
            };
          };

          shadow = shadowConfig;

          tab-indicator = {
            hide-when-single-tab = true;
            gap = 5;
            width = 6;
            length.total-proportion = 0.5;
            position = "right";
            gaps-between-tabs = 2;
          };
        };

        environment = {
          QT_QPA_PLATFORM = "wayland";
          DISPLAY = ":0";
        };
      };
  };
}
