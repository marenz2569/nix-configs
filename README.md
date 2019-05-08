# Deployment

## Mit NixOps

```shell
./decrypt.sh
nixops create  fsret.nixops -d fsret
nixops deploy -d fsret --check --include=display --force-reboot
```
