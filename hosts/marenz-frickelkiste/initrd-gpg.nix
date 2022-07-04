{ ... }: {
  boot.initrd.luks.gpgSupport = true;
  boot.initrd.luks.devices."root-crypt".gpgCard = {
    encryptedPass = /run/secrets/cryptkey.gpg.asc;
    publicKey = lib.singleton /run/secrets/pubkey.asc;
  };
  boot.initrd.luks.devices."home-crypt".gpgCard = {
    encryptedPass = /run/secrets/cryptkey.gpg.asc;
    publicKey = lib.singleton /run/secrets/pubkey.asc;
  };
}
