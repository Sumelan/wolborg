{
  lib,
  config,
  pkgs,
  user,
  ...
}:
let
  cfg = config.custom.usb-audio;
in
{
  options.custom = with lib; {
    usb-audio = {
      enable = mkEnableOption "usb-dac and speaker";
      ifi-uno = mkEnableOption "ifi-uno";
    };
  };

  config = lib.mkIf cfg.enable {
    # ALSA settings
    environment.systemPackages = with pkgs; [
      alsa-utils
    ];
    users.users.${user}.extraGroups = [ "audio" ];

    # device specific pipewire config
    # services.pipewire.extraConfig = lib.mkIf cfg.ifi-uno {
    # pipewire = {
    # NOTE:spotify refuse to play when above 192 kHz\

    # "10-clock-rate" = {
    #  "context.properties" = {
    #     "default.clock.allowed-rates" = [
    #       44100
    #       48000
    #       88200
    #       96000
    #       176400
    #       192000
    #       352800
    #       384000
    #     ];
    #   };
    # };
    # "98-ifi-audio-uno" = {
    #   "device.rules" = [
    #     {
    #        matches = [
    #         { "device.name" = "alsa_card.usb-SXW_iFi_USB_Audio_SE_iFi_USB_Audio_SE-00"; }
    #       ];
    #       actions = {
    #         update-props = {
    #           "alsa.format" = "S32_LE";
    #           "audio.format" = "SE32LE";
    #         };
    #       };
    #     }
    #   ];
    # };
    #};
    # # disbale resampling
    # client = {
    # "10-no-resampling" = {
    #   "stream.properties" = {
    #     "resample.disable" = true;
    #   };
    # };
    # };
    # client-rt = {
    # "10-no-resampling" = {
    #   "stream.properties" = {
    #     "resample.disable" = true;
    #   };
    # };
    # };
    # pipewire-pulse = {
    # "10-no-resampling" = {
    #   "stream.properties" = {
    #     "resample.disable" = true;
    #   };
    # };
    #  };
    #  };

    #  custom.persist = {
    # root.directories = [
    #   "/var/lib/alsa"
    #  ];
    # };
  };
}
