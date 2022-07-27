{ config, secrets, ... }: {
  sops.secrets."marenz-frickelkiste/bad5.ovpn" = {
    format = "binary";
    sopsFile = "${secrets}/marenz-frickelkiste/bad5.ovpn";
  };

  sops.secrets."marenz-frickelkiste/ca.cert.pem" = {
    format = "binary";
    sopsFile = "${secrets}/marenz-frickelkiste/ca.cert.pem";
  };

  sops.secrets."marenz-frickelkiste/ca-chain.cert.pem" = {
    format = "binary";
    sopsFile = "${secrets}/marenz-frickelkiste/ca-chain.cert.pem";
  };

  sops.secrets."marenz-frickelkiste/client-marenz-frickelkiste.cert.pem" = {
    format = "binary";
    sopsFile =
      "${secrets}/marenz-frickelkiste/client-marenz-frickelkiste.cert.pem";
  };

  sops.secrets."marenz-frickelkiste/client-marenz-frickelkiste.key.pem" = {
    format = "binary";
    sopsFile =
      "${secrets}/marenz-frickelkiste/client-marenz-frickelkiste.key.pem";
  };

  services.openvpn.servers.bad5 = {
    config = ''
      config ${config.sops.secrets."marenz-frickelkiste/bad5.ovpn".path}
      ca ${config.sops.secrets."marenz-frickelkiste/ca-chain.cert.pem".path}
      cert ${
        config.sops.secrets."marenz-frickelkiste/client-marenz-frickelkiste.cert.pem".path
      }
      key ${
        config.sops.secrets."marenz-frickelkiste/client-marenz-frickelkiste.key.pem".path
      }
    '';
    autoStart = false;
  };
}
