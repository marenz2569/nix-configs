{ ... }: {
  sops.secrets."openconnect-tud.pass" = {
    format = "binary";
    sopsFile = ../secrets/openconnect-tud.pass;
  };

  networking.openconnect.interfaces.tud = {
    user = "s2599166@tu-dresden.de";
    protocol = "anyconnect";
    gateway = "vpn2.zih.tu-dresden.de";
    passwordFile = "/run/secrets/openconnect-tud.pass";
    extraOptions = {
      authgroup = "B-Tunnel-Public-TU-Networks";
      compression = "stateless";
      no-dtls = true;
      no-http-keepalive = true;
      pfs = true;
    };
    autoStart = false;
  };
}
