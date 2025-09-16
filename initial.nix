(import <nixpkgs/nixos/lib/eval-config.nix> {
  system =
    if builtins.getEnv "CROSS_SYSTEM" != "" then
      builtins.getEnv "CROSS_SYSTEM"
    else
      builtins.currentSystem;
  modules = [
    (
      { ... }:
      {
        imports = [
          ./avf
          ./initial
        ];
      }
    )
  ];
})
