#!/bin/bash
set -euxo pipefail

# download.
# see https://github.com/firecracker-microvm/firectl/releases
# renovate: datasource=github-releases depName=firecracker-microvm/firectl
firectl_version='0.2.0'
firectl_url="https://github.com/firecracker-microvm/firectl/releases/download/v${firectl_version}/firectl-v${firectl_version}"
t="$(mktemp -q -d --suffix=.firectl)"
wget -qO "$t/firectl" "$firectl_url"

# install.
install -m 755 "$t/firectl" /usr/local/bin/firectl
rm -rf "$t"
