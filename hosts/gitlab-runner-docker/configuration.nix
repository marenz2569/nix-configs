{ secrets, config, ... }: {
  system.stateVersion = "22.05";
  networking.hostName = "gitlab-runner-docker";

  microvm = {
    hypervisor = "cloud-hypervisor";
    mem = 8192;
    vcpu = 16;
    interfaces = [{
      type = "tap";
      id = "serv-marenz-gitlab-runner-docker";
      mac = "02:f0:35:5d:65:82";
    }];
    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "store";
        proto = "virtiofs";
        socket = "store.socket";
      }
      {
        source = "/var/lib/microvms/marenz-gitlab-docker-runner/etc";
        mountPoint = "/etc";
        tag = "etc";
        proto = "virtiofs";
        socket = "etc.socket";
      }
      {
        source = "/var/lib/microvms/marenz-gitlab-docker-runner/var";
        mountPoint = "/var";
        tag = "var";
        proto = "virtiofs";
        socket = "var.socket";
      }
    ];
  };

  sops.defaultSopsFile = "${secrets}/gitlab-runner-docker/secrets.yaml";

  sops.secrets.gitlab-runner-registration = { };

  # let gitlab-runner run as root
  systemd.services.gitlab-runner.serviceConfig.DynamicUser = lib.mkForce false;

  services.gitlab-runner = {
    enable = true;
    concurrent = 2;
    gracefulTimeout = "1h";
    services = {
      docker-images = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = config.sops.secrets.gitlab-runner-registration.path;
        dockerImage = "docker:stable";
        dockerVolumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
        tagList = [ "docker-images" ];
      };
    };
  };
}
