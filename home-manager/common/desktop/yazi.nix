{ config, pkgs, ... }:
let
  plugins-repo = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "63f9650e522336e0010261dcd0ffb0bf114cf912";
    hash = "sha256-ZCLJ6BjMAj64/zM606qxnmzl2la4dvO/F5QFicBEYfU=";
  };
in
{
  home.packages = with pkgs; [
    ripdrag
    unar
    exiftool
  ];

  home.shellAliases = {
    lf = "yazi";
    y = "yazi";
  };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

    settings = {
      manager = {
        show_hidden = true;
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
      # for git plugin
      plugin.prepend_fetches = [
        {
          id = "git";
          name = "*";
          run = "git";
        }
        {
          id = "git";
          name = "*/";
          run = "git";
        }
      ];
    };

    plugins = {
      chmod = "${plugins-repo}/chmod.yazi";
      full-border = "${plugins-repo}/full-border.yazi";
      git = "${plugins-repo}/git.yazi";
      toggle-pane = "${plugins-repo}/toggle-pane.yazi";
      mount = "${plugins-repo}/mount.yazi";
      starship = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "starship.yazi";
        rev = "6fde3b2d9dc9a12c14588eb85cf4964e619842e6";
        hash = "sha256-+CSdghcIl50z0MXmFwbJ0koIkWIksm3XxYvTAwoRlDY=";
      };
    };

    initLua = ''
      require("full-border"):setup()
      require("git"):setup()
      require("starship"):setup()
    '';

    keymap = {
      manager.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "Open mount";
        }
        {
          on = "T";
          run = "plugin toggle-pane max-preview";
          desc = "Maximize or restore the preview pane";
        }
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
        {
          on = "<C-n>";
          run = "shell --confirm 'ripdrag \"$@\" -x 2>/dev/null &'";
        }
      ];
    };
  };

  programs.niri.settings = {
    binds = with config.lib.niri.actions; {
      "Mod+Shift+E" = {
        action = spawn "${config.custom.terminal.exec}" "--app-id" "yazi" "yazi";
        hotkey-overlay.title = "Yazi";
      };
    };
    window-rules = [
      {
        matches = [ { app-id = "^(yazi)"; } ];
        default-column-width.proportion = 0.5;
        default-window-height.proportion = 0.5;
        open-floating = true;
      }
    ];
  };

  stylix.targets.yazi.enable = true;
}
