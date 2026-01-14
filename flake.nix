{
  description = "NixOS for Android Terminal (Android Virtualization Framework)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      nixosModules = {
        avf = import ./avf;
        avfDebug = import ./avf/debug.nix;
        avfInitial = import ./initial;
      };

      packages = forAllSystems (system: let
        nixos = lib.nixosSystem {
          inherit system;
          modules = with self.nixosModules; [
            avf
            avfInitial
            avfDebug
          ];
        };
      in {
        initialImage = nixos.config.system.build.avfImage;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
