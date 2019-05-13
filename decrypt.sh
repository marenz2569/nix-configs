#!/usr/bin/env bash

set -e

cd secrets

echo "Generating authorized keys from pass gpg ids"
$(cat .gpg-id | xargs -I{} gpg --export-ssh-key --with-key-data {} > authorized_keys)

cd configs

$(git clean -f)
export PASSWORD_STORE_DIR=`pwd`

for f in $(find . -type f -name "*.gpg" | sed -r 's/(.*).gpg/\1/') ; do
		echo "$f"
    $(pass show "$f" > $f)
done
