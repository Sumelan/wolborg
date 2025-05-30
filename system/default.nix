{
  lib,
  pkgs,
  config,
  isLaptop,
  ...
}:
{
  imports = [
    ./common
    ./optional
    ./style.nix
  ];

  options.custom = with lib; {
    symlinks = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Symlinks to create in the format { dest = src;}";
    };
  };

  config = {
    services = {
      # automount disks
      gvfs.enable = true;
      # disable accidentary push powerkey
      logind.powerKey = lib.mkIf isLaptop "ignore";
    };

    programs = {
      dconf.enable = true;
      seahorse.enable = true;
    };

    environment = {
      etc = {
        # universal git settings
        "gitconfig".text = config.hm.xdg.configFile."git/config".text;
      };

      # install fish completions for fish
      # https://github.com/nix-community/home-manager/pull/2408
      pathsToLink = [ "/share/fish" ];

      variables = {
        TERMINAL = lib.getExe config.hm.custom.terminal.package;
        EDITOR = "nvim";
        VISUAL = "nvim";
        NIXPKGS_ALLOW_UNFREE = "1";
        STARSHIP_CONFIG = "${config.hm.xdg.configHome}/starship.toml";
      };

      # use some shell aliases from home manager
      shellAliases =
        {
          inherit (config.hm.programs.bash.shellAliases)
            eza
            ls
            ll
            la
            lla
            ;
        }
        // {
          inherit (config.hm.home.shellAliases)
            t # eza related
            y # yazi
            ;
        };
      systemPackages =
        with pkgs;
        [
          curl
          eza
          killall
          (lib.hiPrio procps) # for uptime
          neovim
          ripgrep
          yazi
          zoxide
        ]
        ++ (lib.optional config.hm.custom.helix.enable helix);
    };

    # create symlink to dotfiles from default /etc/nixos
    custom.symlinks = {
      "/etc/nixos" = "/persist${config.hm.home.homeDirectory}/projects/wolborg";
    };

    # create symlinks
    systemd.tmpfiles.rules = [
      # cleanup systemd coredumps once a week
      "D! /var/lib/systemd/coredump root root 7d"
    ] ++ (lib.mapAttrsToList (dest: src: "L+ ${dest} - - - - ${src}") config.custom.symlinks);

    programs = {
      # use same config as home-manager
      bash.interactiveShellInit = config.hm.programs.bash.initExtra;

      file-roller.enable = true;
      git.enable = true;

      # remove nano
      nano.enable = lib.mkForce false;
    };

    xdg = {
      # use mimetypes defined from home-manager
      mime =
        let
          hmMime = config.hm.xdg.mimeApps;
        in
        {
          enable = true;
          inherit (hmMime) defaultApplications;
          addedAssociations = hmMime.associations.added;
          removedAssociations = hmMime.associations.removed;
        };

      # fix opening terminal for nemo / thunar by using xdg-terminal-exec spec
      terminal-exec = {
        enable = true;
        settings = {
          default = [ "${config.hm.custom.terminal.package.pname}.desktop" ];
        };
      };
    };

    custom.persist = {
      root.directories = lib.optionals config.hm.custom.wifi.enable [ "/etc/NetworkManager" ];
      root.cache.directories = [
        "/var/lib/systemd/coredump"
      ];

      home.directories = [ ".local/state/wireplumber" ];
    };
  };
}
