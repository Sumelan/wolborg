{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.custom = with lib; {
    terminal = {
      package = mkOption {
        type = types.package;
        default = pkgs.kitty;
        description = "Terminal package to use.";
      };
      exec = mkOption {
        type = types.str;
        default = lib.getExe config.custom.terminal.package;
        description = "Terminal command to execute other programs.";
      };
    };
  };

  config = {
    home.packages = with pkgs; [
      dysk # better disk info
      ets # add timestamp to beginning of each line
      fd # better find
      fx # terminal json viewer and processor
      htop
      jq
      just
      sd # better sed
      # grep, with boolean query patterns, e.g. ug --files -e "A" --and "B"
      ugrep
    ];

    programs = {
      bat = {
        enable = true;
        extraPackages = [
          (pkgs.symlinkJoin {
            name = "batman";
            paths = [ pkgs.bat-extras.batman ];
            postBuild = ''
              mkdir -p $out/share/bash-completion/completions
              echo 'complete -F _comp_cmd_man batman' > $out/share/bash-completion/completions/batman

              mkdir -p $out/share/fish/vendor_completions.d
              echo 'complete batman --wraps man' > $out/share/fish/vendor_completions.d/batman.fish

              mkdir -p $out/share/zsh/site-functions
              cat << EOF > $out/share/zsh/site-functions/_batman
              #compdef batman
              _man "$@"
              EOF
            '';
            meta.mainProgram = "batman";
          })
        ];
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
      };

      niri.settings.binds =
        with config.lib.niri.actions;
        let
          ush = program: spawn "sh" "-c" "uwsm app -- ${program}";
        in
        {
          "Mod+Return" = {
            action = ush "${lib.getExe config.custom.terminal.package}";
            hotkey-overlay.title = "Terminal";
          };
        };
    };
    custom.persist = {
      home = {
        cache.directories = [ ".local/share/zoxide" ];
      };
    };
  };
}
