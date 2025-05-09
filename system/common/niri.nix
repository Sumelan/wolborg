{
  pkgs,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };
  niri-flake.cache.enable = true;

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # use gnome-polkit instead
  systemd.user.services.niri-flake-polkit.enable = false;
}
