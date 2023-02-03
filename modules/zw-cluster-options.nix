{ lib, ... }:

{
  options.deployment = with lib; {
    vcpu = mkOption {
      default = 4;
    };
    mem = mkOption {
      default = 512;
    };
    hypervisor = mkOption {
      default = "cloud-hypervisor";
    };
    networks = mkOption {
      default = [];
    };
    persistedShares = mkOption {
      default = [ "/etc" "/home" "/var" ];
    };
    extraShares = mkOption {
      default = [];
      description = ''
        Extra shares. THESE MUST BE AVAILABLE ON ALL MICROVM HOSTS!
      '';
    };
    needForSpeed = mkOption {
      default = false;
      description = ''
        Prefer deployment on Nomad clients with a higher c3d2.cpuSpeed
      '';
    };
  };
  config = {
    deployment = {
      hypervisor = "qemu";
      # 1G RAM per core
      mem = 16384;
      vcpu = 16;

      networks = [ "serv" ];
      persistedShares = [ "/etc" "/var" ];
      extraShares = [];
      needForSpeed = true;
    };
  };
}
