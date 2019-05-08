{ config, lib, pkgs, ... }:

{
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../secrets/authorized_keys ]; 
}
