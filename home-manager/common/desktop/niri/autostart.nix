{ lib, pkgs, ... }:
{
  programs.niri.settings.spawn-at-startup =
    let
      ush = program: [
        "sh"
        "-c"
        "uwsm app -- ${program}"
      ];
    in
    [
      {
        command = ush "nm-applet";
      }
      {
        command = ush "fcitx5 -d -r";
      }
      {
        command = ush "${lib.getExe pkgs.brightnessctl} set 5%";
      }
      {
        command = ush "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --watch ${lib.getExe pkgs.cliphist} store";
      }
    ];

  systemd.user.services = {
    "polkit-gnome-authentication-agent-1" = {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
