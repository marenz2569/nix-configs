{ pkgs, config, secrets, ... }: {
  users.groups.csi-collector = { };
  users.users.csi-collector = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/csi-collector";
    homeMode = "700";
    group = "csi-collector";
  };

  systemd.services."csi-collector" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${pkgs.csi-collector}/bin/csi-collector --host 10.65.90.1 --port 8000 &
    '';

    environment = {
      "RUST_LOG" = "debug";
      "CSI_COLLECTOR_DATADIR" = config.users.users.csi-collector.home;
    };

    serviceConfig = {
      Type = "forking";
      User = config.users.users.csi-collector.name;
      Restart = "always";
    };
  };
}
