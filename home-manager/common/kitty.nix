_: {
  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = false;
      copy_on_select = "clipboard";
      cursor_trail = 1;
      cursor_trail_start_threshold = 10;
      scrollback_lines = 10000;
      update_check_interval = 0;
      tab_bar_edge = "top";
      confirm_os_window_close = 0;
      # for removing kitty padding when in neovim
      allow_remote_control = "password";
      remote_control_password = ''"" set-spacing''; # only allow setting of padding
      listen_on = "unix:/tmp/kitty-socket";
    };
  };

  home.shellAliases = {
    # change color on ssh
    ssh = "kitten ssh --kitten=color_scheme=Dracula";
  };

  programs.niri.settings.window-rules = [
    {
      matches = [ { app-id = "^(kitty)$"; } ];
      default-column-width = {
        proportion = 0.8;
      };
    }
  ];

  stylix.targets.kitty = {
    enable = true;
    variant256Colors = true;
  };
}
