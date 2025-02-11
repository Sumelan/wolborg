{
  lib,
  config,
  pkgs,
  user,
  ...
}:
{
  home.packages = [
    pkgs.custom.rofi-wifi-menu
    pkgs.rofi-power-menu
  ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font =
      config.stylix.fonts.sansSerif.name + " " + builtins.toString config.stylix.fonts.sizes.applications;

    extraConfig = {
      modi = "run,drun,window,filebrowser";
      show-icons = true;
      hover-select = true;
      run-command = "{cmd}";
      display-run = "  Run ";
      display-drun = "  Apps ";
      display-window = "  Windows ";
      display-recursivebrowser = "  Files ";
      display-powermenu = "  Power ";
      display-filebrowser = "  Files ";
      display-clipboard = "  Clipboard ";
      sidebar-mode = true;
      click-to-exit = true;

      "// lol" = config.lib.formats.rasi.mkLiteral ''

          filebrowser {
            directory: "/home/${user}";
          }
        // '';
    };

    theme = with config.lib.stylix.colors.withHashtag; let
      # Use `mkLiteral` for string-like values that should show without
      # quotes
      inherit (config.lib.formats.rasi) mkLiteral;
      opacity = lib.toHexString (builtins.floor ((config.stylix.opacity.popups - 0.0) * 255));
      border-radius = mkLiteral (builtins.toString 7 + "px");
    in {
      "*" = {
        margin = mkLiteral "0";
        padding = mkLiteral "0";

        text-color = mkLiteral base05;
        background-color = mkLiteral "transparent";
      };

      "window" = {
        width = mkLiteral "36em";

        transparency = "real";

        background-color = mkLiteral (base00 + opacity);
        border-color = mkLiteral base0D;
        inherit border-radius;
      };

      "mainbox" = {
        padding = mkLiteral "10px";

        # background-color = mkLiteral (base00 + opacity);

        border = mkLiteral "3px";
        border-color = mkLiteral base0D;
        inherit border-radius;
      };

      "inputbar" = {
        margin = mkLiteral "2.5px";
        padding = mkLiteral "10px";

        children = map mkLiteral [
          # "prompt"
          "entry"
        ];

        background-color = mkLiteral (base01 + opacity);
        inherit border-radius;
      };

      "prompt" = {
        padding = mkLiteral "5px";

        vertical-align = mkLiteral "0.5";

        text-color = mkLiteral base00;
        background-color = mkLiteral (base0B + opacity);

        inherit border-radius;
      };

      "entry" = {
        margin = mkLiteral "3px";

        vertical-align = mkLiteral "0.5";
      };

      "message" = {
        margin = mkLiteral "2.5px";
        padding = mkLiteral "10px";

        background-color = mkLiteral (base01 + opacity);
        inherit border-radius;
      };

      "listview" = {
        margin = mkLiteral "2.5px";
        padding = mkLiteral "10px";

        dynamic = false;
        fixed-height = false;
        lines = 5;

        background-color = mkLiteral (base01 + opacity);

        inherit border-radius;
      };

      "element" = {
        margin = mkLiteral "2.5px";
        padding = mkLiteral "1px";

        # children = map mkLiteral [
        #   # "element-icon"
        #   "element-text"
        #   # "element-index"
        # ];

        inherit border-radius;
      };

      "element-text" = {
        padding = mkLiteral "10px";
        vertical-align = mkLiteral "0.5";
      };

      "element-icon" = {
        padding = mkLiteral "5px";

        size = mkLiteral "1.5em";
      };

      "element selected" = {
        background-color = mkLiteral (base02 + opacity);
      };

      "element selected.active active" = {
        text-color = mkLiteral base0B;
      };

      "element selected.urgent urgent" = {
        text-color = mkLiteral base08;
      };

      "mode-switcher" = {
        # margin = mkLiteral "2.5px";
        padding = mkLiteral "10px 120px 0 120px";

        inherit border-radius;
      };

      "button" = {
        padding = mkLiteral "5px";

        inherit border-radius;
      };

      "button selected" = {
        text-color = mkLiteral base01;
        background-color = mkLiteral (base0B + opacity);

        inherit border-radius;
      };
    };
  };
}

