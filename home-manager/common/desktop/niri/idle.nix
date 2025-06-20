{
  lib,
  config,
  isLaptop,
  ...
}:
{
  options.custom = with lib; {
    hypridle.enable = mkEnableOption "Enable hypridle" // {
      default = true;
    };
  };

  config = lib.mkIf config.custom.hypridle.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general =
          let
            concatCommands = l: lib.concatStringsSep "; " l;
          in
          {
            ignore_dbus_inhibit = false;
            # exec hyprlock unless already running
            lock_cmd = "pidof hyprlock || hyprlock";
            # kill hyprlock
            unlock_cmd = "pkill -SIGUSR1 hyprlock";
            # stop playing when lock-session
            before_sleep_cmd = concatCommands [
              "loginctl lock-session"
              "playerctl pause"
            ];
            # to avoid having to press a key twice to run on the display.
            after_sleep_cmd = "niri msg action power-on-monitors";
          };

        listener = [
          {
            timeout = 60 * 5;
            # set monitor backlight to minomum, avoid 0 on OLED monitor.
            on-timeout = "brightnessctl -s set 5";
            on-resume = "brightnessctl -r"; # monitor backlight restor.
          }

          {
            timeout = 60 * 8;
            # lock screen when timeout has passed.
            on-timeout = "loginctl lock-session";
          }

          {
            timeout = 60 * 10;
            # screen off when timeout has passed.
            on-timeout = "niri msg action power-off-monitors";
            # screen on when activity is detected after timeout has fired.
            on-resume = "niri msg action power-on-monitors";
          }
          (lib.mkIf isLaptop {
            timeout = 60 * 15;
            on-timeout = "systemctl suspend"; # suspend pc.
          })
        ];
      };
    };
    systemd.user.services.hypridle = {
      Unit.After = lib.mkForce "graphical-session.target";
    };
  };
}
