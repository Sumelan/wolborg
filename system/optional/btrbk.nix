{
  lib,
  config,
  pkgs,
  user,
  host,
  isLaptop,
  isServer,
  ...
}:
let
  btrbkRemote = name: {
    onCalendar = "daily";
    settings = {
      # ssh setup
      ssh_user = "btrbk";
      ssh_identity = "/var/lib/btrbk/.ssh/btrbk_key"; # must be readable by user/group btrbk
      volume."/" = {
        target = "ssh://sakura/media/${name}-backups";
        subvolume = "persist";
      };
      stream_compress = "lz4";
      # Retention policy
      snapshot_preserve_min = "3d";
      snapshot_preserve = "3d";
      target_preserve = "3d";
    };
  };

  backupMonitor =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    with lib;
    {
      key = "backupMonitor";
      _file = "backupMonitor";
      config.systemd.services =
        {
          "notify-problems@" = {
            enable = true;
            serviceConfig.User = "${user}";
            environment.SERVICE = "%i";
            script = ''
              export $(cat /proc/$(${pkgs.procps}/bin/pgrep "niri-session" -u "$USER")/environ |grep -z '^DBUS_SESSION_BUS_ADDRESS=')
              ${pkgs.libnotify}/bin/notify-send -u critical "$SERVICE FAILED!" "Run journalctl -u $SERVICE for details"
            '';
          };
        }
        // flip mapAttrs' config.services.btrbk.instances (
          name: value:
          nameValuePair "btrbk-${name}" {
            unitConfig.OnFailure = "notify-problems@%i.service";
            preStart = lib.mkBefore ''
              # waiting for internet after resume-from-suspend
              until ${pkgs.iputils.out}/bin/ping google.com -c1 -q >/dev/null; do :; done
            '';
          }
        );
      # optional, but this actually forces backup after boot in case laptop was powered off during scheduled event
      # for example, if you scheduled backups daily, your laptop should be powered on at 00:00
      config.systemd.timers = flip mapAttrs' config.services.btrbk.instances (
        name: value:
        nameValuePair "btrbk-${name}" {
          timerConfig.Persistent = lib.mkForce true;
        }
      );
    };
in
{
  imports = [ backupMonitor ];

  options.custom = with lib; {
    btrbk.enable = mkEnableOption "snapshots using btrbk";
  };

  config = lib.mkIf config.custom.btrbk.enable {
    services.btrbk = {
      # common setting
      extraPackages = [ pkgs.lz4 ];

      # set remote instance on client side
      instances = lib.mkIf isLaptop {
        "${host}_backup" = btrbkRemote "${host}";
      };

      # set ssh command on remote side
      sshAccess = lib.mkIf isServer [
        {
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGww+bXaeTXj6s10G4V8Kz2PqGfI6tU4rd8KfxxoQj9 btrbk";
          roles = [
            "target"
            "info"
            "receive"
          ];
        }
      ];
    };

    # only client side
    custom.persist = lib.mkIf isLaptop {
      root.directories = [
        "/var/lib/btrbk"
      ];
    };
  };
}
