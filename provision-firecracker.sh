#!/bin/bash
set -euxo pipefail

# see https://github.com/firecracker-microvm/firecracker/releases
firecracker_version="${1:-1.3.1}"

# download.
firecracker_url="https://github.com/firecracker-microvm/firecracker/releases/download/v${firecracker_version}/firecracker-v${firecracker_version}-x86_64.tgz"
t="$(mktemp -q -d --suffix=.firecracker)"
wget -qO- "$firecracker_url" | tar xzf - --strip-components 1 -C "$t"

# install.
install -m 755 "$t/firecracker-v${firecracker_version}-x86_64" /usr/local/bin/firecracker
install -m 755 "$t/jailer-v${firecracker_version}-x86_64" /usr/local/bin/firecracker-jailer
rm -rf "$t"
