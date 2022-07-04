{ pkgs, ... }:
{
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
		wireplumber.enable = false;
		media-session.enable = true;
		media-session.config.bluez-monitor.rules = [
			{
				# Matches all cards
				matches = [ { "device.name" = "~bluez_card.*"; } ];
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
					{ "node.name" = "~bluez_input.*"; }
					# Matches all outputs
					{ "node.name" = "~bluez_output.*"; }
				];
			}
		];
	};
}
