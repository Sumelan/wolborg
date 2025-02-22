{
  lib,
  config,
  pkgs,
  dotfiles,
  ...
}:
let
  mkYaziPlugin = name: text: {
    "${name}" = toString (pkgs.writeTextDir "${name}.yazi/main.lua" text) + "/${name}.yazi";
  };
in
lib.mkMerge [
  {
    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      plugins = {
        full-border = "${pkgs.custom.yazi-plugins.src}/full-border.yazi";
        git = "${pkgs.custom.yazi-plugins.src}/git.yazi";
        time-travel = pkgs.custom.yazi-time-travel.src;
      };

      initLua = ''
        require("full-border"):setup({ type = ui.Border.ROUNDED })
        require("git"):setup()
      '';

      settings = {
        log = {
          enabled = true;
        };
        manager = {
          ratio = [
            0
            1
            1
          ];
          sort_by = "alphabetical";
          sort_sensitive = false;
          sort_reverse = false;
          linemode = "size";
          show_hidden = true;
        };
        # settings for plugins
        plugin = {
          prepend_fetchers = [
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
      };

      theme = {
        manager = {
          preview_hovered = {
            underline = false;
          };
          folder_offset = [
            1
            0
            1
            0
          ];
          preview_offset = [
            1
            1
            1
            1
          ];
        };

        status.separator_style = {
          fg = "red";
          bg = "red";
        };
      };

      keymap =
        let
          homeDir = "${config.home.homeDirectory}";
          shortcuts = {
            h = homeDir;
            inherit dotfiles;
            cfg = "${homeDir}/.config";
            vd = "${homeDir}/Videos";
            pp = "${homeDir}/projects";
            pc = "${homeDir}/Pictures";
            ps = "${homeDir}/Pictures/Screenshots";
            pw = "${homeDir}/Pictures/Wallpapers";
            dd = "${homeDir}/Downloads";
          };
        in
        {
          # add keymaps for shortcuts
          manager.prepend_keymap =
            [
              # dropping to shell
              {
                on = "!";
                run = ''shell "$SHELL" --block --confirm'';
                desc = "Open shell here";
              }
              # close input by a single Escape press
              {
                on = "<Esc>";
                run = "close";
                desc = "Cancel input";
              }
              # cd back to root of current git repo
              {
                on = [
                  "g"
                  "r"
                ];
                run = ''shell 'ya pub dds-cd --str "$(git rev-parse --show-toplevel)"' --confirm'';
                desc = "Cd to root of current git repo";
              }
            ]
            ++ lib.flatten (
              lib.mapAttrsToList (keys: loc: [
                # cd
                {
                  on = [ "g" ] ++ lib.stringToCharacters keys;
                  run = "cd ${loc}";
                  desc = "cd to ${loc}";
                }
                # new tab
                {
                  on = [ "t" ] ++ lib.stringToCharacters keys;
                  run = "tab_create ${loc}";
                  desc = "open new tab to ${loc}";
                }
                # mv
                {
                  on = [ "m" ] ++ lib.stringToCharacters keys;
                  run = [
                    "yank --cut"
                    "escape --visual --select"
                    loc
                  ];
                  desc = "move selection to ${loc}";
                }
                # cp
                {
                  on = [ "Y" ] ++ lib.stringToCharacters keys;
                  run = [
                    "yank"
                    "escape --visual --select"
                    loc
                  ];
                  desc = "copy selection to ${loc}";
                }
              ]) shortcuts
            )
            ++ [
              {
                on = [
                  "z"
                  "h"
                ];
                run = "plugin time-travel --args=prev";
                desc = "Go to previous snapshot";
              }
              {
                on = [
                  "z"
                  "l"
                ];
                run = "plugin time-travel --args=next";
                desc = "Go to next snapshot";
              }
              {
                on = [
                  "z"
                  "e"
                ];
                run = "plugin time-travel --args=exit";
                desc = "Exit browsing snapshots";
              }
            ];
        };
    };

    home = {
      packages = with pkgs; [
        unar
        exiftool
      ];
      shellAliases = {
        lf = "yazi";
        y = "yazi";
      };
    };
  }

  # smart-enter: enter for directory, open for file
  # https://yazi-rs.github.io/docs/tips/#smart-enter
  {
    programs.yazi = {
      plugins = mkYaziPlugin "smart-enter" ''
        --- @sync entry
        return {
        	      entry = function()
            local h = cx.active.current.hovered
            ya.manager_emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
          end,
        }
      '';
      keymap.manager.prepend_keymap = [
        {
          on = "l";
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }
      ];
    };
  }

  # smart-paste: paste files without entering the directory
  # https://yazi-rs.github.io/docs/tips/#smart-enter
  {
    programs.yazi = {
      plugins = mkYaziPlugin "smart-paste" ''
        --- @sync entry
        return {
          entry = function()
            local h = cx.active.current.hovered
            if h and h.cha.is_dir then
              ya.manager_emit("enter", {})
              ya.manager_emit("paste", {})
              ya.manager_emit("leave", {})
            else
              ya.manager_emit("paste", {})
            end
          end,
        }
      '';
      keymap.manager.prepend_keymap = [
        {
          on = "p";
          run = "plugin smart-paste";
          desc = "Paste into the hovered directory or CWD";
        }
      ];
    };
  }

  # arrow: file navigation wraparound
  {
    programs.yazi = {
      plugins = mkYaziPlugin "arrow" ''
        --- @sync entry
        return {
          entry = function(_, job)
            local current = cx.active.current
            local new = (current.cursor + job.args[1]) % #current.files
            ya.manager_emit("arrow", { new - current.cursor })
          end,
        }
      '';
      keymap.manager.prepend_keymap = [
        {
          on = "k";
          run = "plugin arrow --args=-1";
        }
        {
          on = "j";
          run = "plugin arrow --args=1";
        }
      ];
    };
  }

  # folder specific rules?
  # https://yazi-rs.github.io/docs/tips/#folder-rules
]
