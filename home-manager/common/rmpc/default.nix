{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./config.nix
    ./theme.nix
  ];

  home.packages = with pkgs; [ rmpc ];

  services = {
    mpd = {
      enable = true;
      musicDirectory = "/home/${user}/Music";
      dataDir = "/home/${user}/.config/mpd";
      dbFile = "/home/${user}/.config/mpd/tag_cache";
      extraConfig = ''
        audio_output {
          type  "pipewire"
          name  "PipeWire Sound Server"
        }
        bind_to_address "/home/${user}/.config/mpd/mpd_socket"
      '';
    };
    # mpd to mpris2 bridge
    mpdris2 = {
      enable = true;
      # enable song change notifications
      notifications = true;
    };
  };

  programs.niri.settings.window-rules = [
    {
      matches = [
        {
          # Mod+R launch rmpc with app-id
          app-id = "^(rmpc)$";
        }
      ];
      default-column-width.proportion = 0.4;
      default-window-height.proportion = 0.35;
      open-floating = true;
      default-floating-position = {
        x = 8;
        y = 8;
        relative-to = "bottom-right";
      };
    }
  ];

  custom.persist = {
    home = {
      directories = [
        ".config/mpd"
      ];
      cache.directories = [
        # yt-dlp cache
        ".cache/rmpc"
      ];
    };
  };
}
