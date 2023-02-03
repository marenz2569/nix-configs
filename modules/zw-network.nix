{ zentralwerk, config, lib, ... }:

let
  inherit (config.networking) hostName;

  nets = builtins.attrNames (
    lib.filterAttrs (_: { hosts4, hosts6, ... }:
      hosts4 ? ${hostName} ||
      lib.filterAttrs (_: hosts6:
        hosts6 ? ${hostName}
      ) hosts6 != {}
    ) zentralwerk.lib.config.site.net
  );

  defaultGateways = {
    # services
    serv = "serv-gw";
    # ZW public
    pub = "pub-gw";
    # public IPv4 addresses
    flpk = "flpk-gw";
    # Andreas Lippmann's Privatnetz
    priv45 = "priv45-gw";
  };

  generateMacAddress = net:
    let
      hash = builtins.hashString "md5" "1-${net}-${hostName}";
      c = off: builtins.substring off 2 hash;
    in
      "${builtins.substring 0 1 hash}2:${c 2}:${c 4}:${c 6}:${c 8}:${c 10}";

in
{
  systemd.network = {
    links = builtins.trace (lib.concatStringsSep ", " nets) builtins.foldl' (links: net: links // {
      "30-${net}" = {
        # enable = true;
        matchConfig.MACAddress = generateMacAddress net;
        # rename interface to net name
        linkConfig.Name = net;
      };
    }) {} nets;

    networks = builtins.foldl' (networks: net: networks // {
      "30-${net}" =
        let
          zwNet = zentralwerk.lib.config.site.net.${net};
          addresses =
            lib.optional (zwNet.hosts4 ? ${hostName}) "${zwNet.hosts4.${hostName}}/${toString zwNet.subnet4Len}"
            ++
            map (hosts6: "${hosts6.${hostName}}/64") (
              builtins.filter (hosts6: hosts6 ? ${hostName}) (
                builtins.attrValues zwNet.hosts6
              )
            );
        in {
          matchConfig.MACAddress = generateMacAddress net;
          addresses = map (Address: {
            addressConfig = { inherit Address; };
          }) addresses;
          gateway = lib.mkIf (defaultGateways ? ${net}) (
            let
              gw = defaultGateways.${net};
            in
              [ zwNet.hosts4.${gw} ]
              ++ map (hosts6: hosts6.${gw}) (
                builtins.filter (hosts6: hosts6 ? ${gw}) (
                  builtins.attrValues zwNet.hosts6
                )
              )
          );
        };
    }) {} nets;
  };
}
