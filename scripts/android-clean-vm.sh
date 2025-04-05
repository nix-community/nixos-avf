#!/bin/sh

# Deletes all data created by previous VMs

set -euo pipefail

SELF=$(dirname "$(readlink -f "$0")")
. "$SELF/_common.sh"

with_root rm -rfv /data/data/com.android.virtualization.terminal/{files/nixos.log,files/debian.log,files/linux,vm/nixos,vm/debian}
