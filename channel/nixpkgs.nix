with (import <nixpkgs> {}); stdenv.mkDerivation {
  name = "avf-channel-nixpkgs.tar.xz";

  dontFixup = true;
  dontBuild = true;
  dontConfigure = true;

  src = pkgs.path;

  patches = [
    ./sysb.patch
  ];

  installPhase = ''
    tar cfJ $out -C . .
  '';
}
