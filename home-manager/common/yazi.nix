{ pkgs, ... }:
let
  plugins-repo = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "4b027c79371af963d4ae3a8b69e42177aa3fa6ee";
    sha256 = "sha256-auGNSn6tX72go7kYaH16hxRng+iZWw99dKTTUN91Cow=";
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
      max-preview = "${plugins-repo}/max-preview.yazi";
      mount = "${plugins-repo}/mount.yazi";
      starship = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "starship.yazi";
        rev = "f6939fbdbc3fdfcdc2a80251841e429e0cd5cf3c";
        sha256 = "sha256-5QQsFozbulgLY/Gl6QuKSOTtygULveoRD49V00e0WOw=";
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
          run = "plugin --sync max-preview";
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

  programs.niri.settings.window-rules = [
    {
      matches = [ { app-id = "^(yazi)"; } ];
      default-column-width.proportion = 0.5;
      default-window-height.proportion = 0.5;
      open-floating = true;
    }
  ];

  stylix.targets.yazi.enable = true;
}
