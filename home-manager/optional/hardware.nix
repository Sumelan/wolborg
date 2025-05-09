# hardware related options that are referenced within home-manager need to be defined here
# for home-manager to be able to access them
{
  lib,
  isLaptop,
  ...
}:
{
  options.custom = with lib; {
    backlight.enable = mkEnableOption "Backlight" // {
      default = isLaptop;
    };
    battery.enable = mkEnableOption "Battery" // {
      default = isLaptop;
    };
    wifi.enable = mkEnableOption "Wifi" // {
      default = isLaptop;
    };
  };
}
