{ lib, pkgs, config, ... }:
let
  default-pipewire-pulse = lib.importJSON (pkgs.path
    + "/nixos/modules/services/desktops/pipewire/daemon/pipewire-pulse.conf.json");
  libpipewire-module-zeroconf-discover = {
    "name" = "libpipewire-module-zeroconf-discover";
  };
  # https://wiki.archlinux.org/title/PipeWire#Sound_does_not_automatically_switch_to_Bluetooth_headphones
  switch-on-connect = [
    { "cmd" = "load-module"; "args" = "module-always-sink"; "flags" = [ ]; }
    { "cmd" = "load-module"; "args" = "module-switch-on-connect"; }
  ];
  pipewire-pulse = default-pipewire-pulse // {
    "context.modules" = default-pipewire-pulse."context.modules"
      ++ lib.singleton libpipewire-module-zeroconf-discover;
    "pulse.cmd" = default-pipewire-pulse."pulse.cmd"
      ++ switch-on-connect;
  };
in {
  # https://nixos.wiki/wiki/PipeWire
  # https://nixos.wiki/wiki/Bluetooth

  security.rtkit.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;
  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    config.pipewire-pulse = pipewire-pulse;
    wireplumber.enable = false;
    media-session.enable = true;
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [{ "device.name" = "~bluez_card.*"; }];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          {
            "node.name" = "~bluez_input.*";
          }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
      }
    ];
  };

  systemd.user.services.mpris-proxy = {
    unitConfig = {
      Description = "Mpris proxy";
      After = [ "network.target" "sound.target" ];
    };
    serviceConfig.ExecStart =
      "${config.hardware.bluetooth.package}/bin/mpris-proxy";
    wantedBy = [ "default.target" ];
  };
}
