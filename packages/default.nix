{ pkgs, ... }:
{
  fuzzel-scripts = pkgs.callPackage ./fuzzel-scripts { };
  hypr-scripts = pkgs.callPackage ./hypr-scripts { };
  screencast = pkgs.callPackage ./screencast { };
}
