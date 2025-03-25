{
  description = "NixOS for Android Terminal (Android Virtualization Framework) ";

  outputs =
    { self }:
    {
      nixosModules = {
        avf = import ./avf;
        avfDebug = import ./avf/debug.nix;
        avfInitial = import ./initial;
      };
    };
}
