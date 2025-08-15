#!/bin/bash

set -euxo pipefail

NIXOS="$1"
ARCH="$2"
TAG="nixos-$NIXOS"

if [ -v CACHIX_AUTH_TOKEN ]; then
  CACHIX=(cachix watch-exec nix-community --)
else
  CACHIX=()
fi

F_CHANNEL="nixos-channel-$NIXOS-$ARCH.tar.xz"
F_AVF="avf-channel-$NIXOS-$ARCH.tar.xz"
F_IMAGE="image-$NIXOS-$ARCH.tar.gz"

nix-channel --add "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-$NIXOS.tar.gz" nixpkgs
nix-channel --update

nix-build channel/nixpkgs.nix -o "$F_CHANNEL"
nix-build channel/avf.nix -o "$F_AVF"

nix-channel --add "file://$PWD/$F_CHANNEL" nixpkgs
nix-channel --update

export INITIAL_RELEASE="$NIXOS"
export INITIAL_ARCH="$ARCH"
export INITIAL_URL_OS="https://github.com/nix-community/nixos-avf/releases/download/nixos-$NIXOS/$F_CHANNEL"
export INITIAL_URL_AVF="https://github.com/nix-community/nixos-avf/releases/download/nixos-$NIXOS/$F_AVF"

"${CACHIX[@]}" nix-build initial.nix -A config.system.build.initialRamdisk -A config.system.build.kernel
"${CACHIX[@]}" nix-build initial.nix -A config.system.build.toplevel
nix-build initial.nix -A config.system.build.avfImage -o "$F_IMAGE"

if [ -v GITHUB_TOKEN ]; then
  if ! gh release view "$TAG"; then
    gh release create --title "Images for NixOS $NIXOS" --target empty "$TAG"
  fi

  gh release edit --notes-file ./.github/notes.md "$TAG"

  gh release upload --clobber "$TAG" "$F_IMAGE" "$F_CHANNEL" "$F_AVF"
else
  echo "Skip uploading, no GITHUB_TOKEN"
fi
