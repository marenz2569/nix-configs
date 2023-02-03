{ lib, config, secrets, ... }:
{
  system.stateVersion = "22.05";
  networking.hostName = "marenz";
  # TODO fix zw network flake
  # "gitlab-runner-docker";

  sops.defaultSopsFile = "${secrets}/gitlab-runner-docker/secrets.yaml";

  sops.secrets.gitlab-runner-registration = { };

  # let gitlab-runner run as root
  systemd.services.gitlab-runner.serviceConfig.DynamicUser = lib.mkForce false;

  services.gitlab-runner = {
    enable = true;
    settings.concurrent = 1;
    gracefulTimeout = "1h";
    services = {
      docker-images = {
        limit = 1;
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile =
          config.sops.secrets.gitlab-runner-registration.path;
        # 100 MB
        registrationFlags = [ "--output-limit 102400" ];
        dockerImage = "docker:stable";
        dockerVolumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
        tagList = [ "docker-images" ];
      };
    };
  };

  security.apparmor.enable = lib.mkForce false;

  virtualisation.docker.storageDriver = "devicemapper";
  virtualisation.docker.extraOptions = "--storage-opt dm.basesize=40G --storage-opt dm.fs=xfs";
  systemd.enableUnifiedCgroupHierarchy = false;
}
