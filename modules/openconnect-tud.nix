{ pkgs, ... }:
let
  openconnect-client-script = pkgs.writeScriptBin "openconnect-client-script" ''
    #!/usr/bin/env bash

    for (( ; ; ))
    do
      openconnect vpn2.zih.tu-dresden.de --user=s2599166@tu-dresden.de --authgroup=B-Tunnel-Public-TU-Networks --pfs --no-http-keepalive --no-dtls --passwd-on-stdin < /run/secrets/openconnect-tud.pass
      sleep 1
    done
  '';

  openconnect-monitor-script = pkgs.writeScriptBin "openconnect-monitor-script" ''
    #!/usr/bin/env bash

    for (( ; ; ))
    do
      ROUTE_STATUS="$(ip r g 141.30.3.108 2> /dev/null | head -n1 | grep tun | wc -l)"

      if [ $ROUTE_STATUS -eq 1 ]; then
        echo "Restarting openconnect-client.service as its routes are fucked up"
        systemctl restart openconnect-client.service
      fi
      sleep 1
    done
  '';
in
{
  sops.secrets."openconnect-tud.pass" = {
    format = "binary";
    sopsFile = ../secrets/openconnect-tud.pass;
  };

  systemd.services.openconnect-client = {
    enable = true;
    description = "Connect openconnect client";
    requires = [ "network-online.target" ];
    requiredBy = [ "openconnect-monitor.service" ];
    after = [ "network.target" "network-online.target" ];
#		wantedBy = [ "network-online.target" ];
    path = with pkgs; [ bash openconnect-client-script openconnect unixtools.netstat unixtools.ifconfig unixtools.route gawk ];
    script = "exec openconnect-client-script &";
    serviceConfig.Type = "forking";
  };

  systemd.services.openconnect-monitor = {
    enable = true;
    description = "Kills openconnect if it deleted the route to the server on reconnect";
    requires = [ "openconnect-client.service" ];
    requiredBy = [ "openconnect-client.service" ];
    after = [ "openconnect-client.service" ];
    path = with pkgs; [ bash openconnect-monitor-script iproute ];
    script = "exec openconnect-monitor-script &";
    serviceConfig.Type = "forking";
  };
}
