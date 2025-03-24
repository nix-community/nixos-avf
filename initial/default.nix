{ config, pkgs, lib, ... }:

let
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
in
{
  system.activationScripts.setup_files = {
    text = ''
      if [ ! -e /_setup ]; then
        cp -rv ${./etc}/* /etc/
        mkdir -vp /mnt/{shared,internal,backup}
        chown -v 1000:100 /mnt/{shared,internal,backup}
        mkdir -vp /etc/nixos
        cp -v ${defaultConfig} /etc/nixos/configuration.nix

        HOME=/root ${config.nix.package}/bin/nix-channel --add https://github.com/nix-community/nixos-avf/archive/refs/heads/trunk.tar.gz nixos-avf

        touch /_setup
      fi
    '';
  };
}
