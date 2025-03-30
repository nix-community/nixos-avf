with (import <nixpkgs> {}); stdenv.mkDerivation {
  name = "avf-channel-avf.tar.xz";

  dontFixup = true;
  dontBuild = true;
  dontConfigure = true;

  src = ./../.;

  installPhase = ''
    tar cvfJ $out -C . .
  '';
}
