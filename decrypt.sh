#!/usr/bin/env bash

set -e

cd secrets

echo "Generating authorized keys from pass gpg ids"
$(cat .gpg-id | xargs -I{} gpg --export-ssh-key --with-key-data {} > authorized_keys)

cd configs

export PASSWORD_STORE_DIR=`pwd`

for f in $(find . -type f -name "*.gpg") ; do
    n=$(echo "$f"|sed -e 's/.gpg//')
    o="${n}.nix"
    echo "$o"
    rm -f "$o"
    $(pass show "$n" > $o)
done
