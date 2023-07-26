{ config, secrets, pkgs, ... }: {
  sops.secrets."bitwarden-secrets" = {
    format = "binary";
    sopsFile = "${secrets}/cal-marenz/bitwarden-secrets";
    owner = config.users.users.vaultwarden.name;
  };

  services.nginx.virtualHosts."bitwarden.marenz.ee" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${
          toString config.services.vaultwarden.config.ROCKET_PORT
        }";
      recommendedProxySettings = true;
    };
  };

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://bitwarden.marenz.ee";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      ROCKET_LOG = "critical";

      SIGNUPS_ALLOWED = "false";
      INVITATIONS_ALLOWED = "false";
    };
    environmentFile = "${config.sops.secrets."bitwarden-secrets".path}";
    dbBackend = "sqlite";
  };
}
