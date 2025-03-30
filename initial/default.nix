{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  envWithDefault = var: def:
    let
      varName = "INITIAL_${var}";
    in
    if builtins.getEnv varName == "" then def else builtins.getEnv varName;

  defaultConfig = pkgs.writeText "default-configuration.nix" ''
    # Edit this configuration file to define what should be installed on
    # your system. Help is available in the configuration.nix(5) man page, on
    # https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

    # NixOS-WSL specific options are documented on the NixOS-WSL repository:
    # https://github.com/nix-community/NixOS-WSL

    { config, lib, pkgs, ... }:

    {
      imports = [
        # include nixos-avf modules
        <nixos-avf/avf>
      ];

      # Change default user
      # avf.defaultUser = "droid";

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It's perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "${config.system.nixos.release}"; # Did you read the comment?
    }
  '';

  cfg = config.avf.initial;
in
{
  options = {
    avf.initial = {
      urlAVF = mkOption {
        type = types.str;
        default = envWithDefault "URL_AVF" "https://github.com/nix-community/nixos-avf/archive/refs/heads/trunk.tar.gz";
      };
      urlOS = mkOption {
        type = types.str;
        default = envWithDefault "URL_OS" "https://nixos.org/channels/nixos-unstable";
      };
      archId = mkOption {
        type = types.str;
        default = envWithDefault "ARCH" builtins.currentSystem;
      };
      release = mkOption {
        type = types.str;
        default = envWithDefault "RELEASE" "unstable";
      };
    };
  };

  config = {
    system.activationScripts.setup_files = {
      text = ''
        if [ ! -e /_setup ]; then
          cp -rv ${./etc}/* /etc/
          mkdir -vp /mnt/{shared,internal,backup}
          chown -v 1000:100 /mnt/{shared,internal,backup}
          mkdir -vp /etc/nixos
          cp -v ${defaultConfig} /etc/nixos/configuration.nix

          HOME=/root ${config.nix.package}/bin/nix-channel --add ${cfg.urlAVF} nixos-avf
          HOME=/root ${config.nix.package}/bin/nix-channel --add ${cfg.urlOS} nixos

          touch /_setup
        fi
      '';
    };

    systemd.tmpfiles.rules =
      let
        channels = pkgs.runCommand "default-channels" { } ''
          mkdir -p $out
          ln -s ${pkgs.path} $out/nixos
          ln -s ${./../.} $out/nixos-avf
        '';
      in
      [
        "L /nix/var/nix/profiles/per-user/root/channels-1-link - - - - ${channels}"
        "L /nix/var/nix/profiles/per-user/root/channels - - - - channels-1-link"
      ];

    system.stateVersion = config.system.nixos.release;
  };
}
