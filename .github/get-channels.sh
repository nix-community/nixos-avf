#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnugrep gnused jq

matrix=$(curl -L -s https://github.com/NixOS/infra/raw/refs/heads/main/channels.nix | grep -o '"nixos-[0-9.a-z]*"' | sed 's|"||g' | sed "s|nixos-||g" | jq -s -R -c 'split("\n") | map(select(length > 0))')
echo "matrix=$matrix" >> $GITHUB_OUTPUT
