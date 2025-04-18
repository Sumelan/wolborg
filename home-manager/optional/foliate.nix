{
  lib,
  config,
  pkgs,
  ...
}:
let
  foliate = "com.github.johnfactotum.Foliate";
in
{
  options.custom = with lib; {
    foliate.enable = mkEnableOption "foliate";
  };

  config = lib.mkIf config.custom.foliate.enable {
    home.packages = [ pkgs.foliate ];

    programs.niri.settings.window-rules = [
      {
        matches = [ { app-id = "^(${foliate})$"; } ];
        default-column-width = {
          proportion = 0.9;
        };
      }
    ];

    custom.persist = {
      home.directories = [
        ".cache/${foliate}"
      ];
    };
  };
}
