{ config, ... }:
{
  programs.cava.enable = true;

  programs.niri.settings = {
    binds = with config.lib.niri.actions; {
      "Mod+C" = {
        action = spawn "kitty" "--app-id" "cava" "cava";
        hotkey-overlay.title = "Cava";
      };
    };
    window-rules = [
      {
        # Mod+C launch cava with app-id
        matches = [ { app-id = "^(cava)$"; } ];
        default-column-width.proportion = 0.4;
        default-window-height.proportion = 0.4;
        open-floating = true;
      }
    ];
  };

  stylix.targets.cava = {
    enable = true;
    rainbow.enable = true;
  };
}
