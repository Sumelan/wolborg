{ pkgs, ... }:
{
  programs.niri.settings = {
    spawn-at-startup = [
      {
        command = [
          "dbus-update-activation-environment"
          "--all"
          "--systemd"
        ];
      }
      {
        command = [
          "nm-applet"
        ];
      }
      {
        command = [
          "blueman-applet"
        ];
      }
      {
        command = [
          "xwayland-satellite"
        ];
      }
      {
        command = [
          "fcitx5"
          "-d"
        ];
      }
      {
        command = [
          "swww-daemon"
        ];
      }
      {
        command = [
          "wallsetter"
        ];
      }
      {
        command = [
          "brightnessctl"
          "set"
          "5%"
        ];
      }
      {
        command = [
          "wl-paste"
          "-t"
          "text"
          "--watch"
          "clipman"
          "store"
        ];
      }
      {
        command = [
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        ];
      }
    ];
  };
}
