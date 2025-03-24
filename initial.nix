(import <nixpkgs/nixos/lib/eval-config.nix> {
  system = builtins.currentSystem;
  modules = [
    (
      { modulesPath, ... }:
      {
        imports = [
          ./avf
        ];
      }
    )
  ];
}).config.system.build.avfImage
