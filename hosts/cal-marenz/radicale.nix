{ config, secrets, pkgs, ... }: {
  sops.secrets."radicale-htpasswd" = {
    format = "binary";
    sopsFile = "${secrets}/cal-marenz/radicale-htpasswd";
    owner = config.users.users.radicale.name;
  };

  services.nginx.virtualHosts."cal.marenz.ee" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://0.0.0.0:5232";
      recommendedProxySettings = true;
    };
  };

  services.radicale = {
    enable = true;
    settings = {
      server = { hosts = [ "127.0.0.1:5232" ]; };
      auth = {
        type = "htpasswd";
        htpasswd_filename = "${config.sops.secrets."radicale-htpasswd".path}";
        htpasswd_encryption = "bcrypt";
      };
      storage = { filesystem_folder = "/var/lib/radicale/collections"; };
    };
    rights = {
      root = {
        user = ".+";
        collection = "";
        permissions = "R";
      };
      principal = {
        user = ".+";
        collection = "{user}";
        permissions = "RW";
      };
      calendars = {
        user = ".+";
        collection = "{user}/[^/]+";
        permissions = "rw";
      };
    };
  };
}
