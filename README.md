# Deployment

## Mit NixOps

```shell
./decrypt.sh
nixops create arkom.nixops -d arkom
nixops deploy -d arkom --check --include=marenz-build
```
