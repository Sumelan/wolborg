{
  lib,
  pkgs,
  inputs,
  specialArgs,
  user,
}:
let
  mkNixosConfiguration = 
    host:
    lib.nixosSystem {
      inherit pkgs;
    specialArgs = specialArgs // {
      inherit host user;
      isNixos = true;
      isLaptop = host == "acer";
      dotfiles = "/persist/home/${user}/projects/wolborg";
    };
    modules = [
      ./${host} # host specific configuration
      ./${host}/hardware.nix  # host specific hardware configuration
      ../system # system modules
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = specialArgs // {
            inherit host user;
            isNixos = true;
            isLaptop = host == "acer";
            dotfiles = "/persist/home/${user}/projects/wolborg";
          };
          users.${user} = {
            imports = [
              ./${host}/home.nix  # host specific home-manager configuration
              ../home-manager # home-manager modules
              inputs.nix-index-database.hmModules.nix-index
              inputs.nixcord.homeManagerModules.nixcord
              inputs.nvf.homeManagerModules.default
            ];
          };
        };
      }
      # alias for home-manager
      (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" user ])
      inputs.niri.nixosModules.niri
      inputs.stylix.nixosModules.stylix
      inputs.impermanence.nixosModules.impermanence
      inputs.agenix.nixosModules.default
    ];
  };
in
{
  acer = mkNixosConfiguration "acer" { };
  sakura = mkNixosConfiguration "sakura"{ };
}
