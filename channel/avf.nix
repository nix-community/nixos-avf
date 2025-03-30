with (import <nixpkgs> {}); stdenv.mkDerivation {
  name = "avf-channel-avf.tar.xz";

  dontFixup = true;
  dontBuild = true;
  dontConfigure = true;

  src = ./../.;

  nativeBuildInputs = [
    git
  ];

  installPhase = ''
    tar cvfJ $out -C . .
    git clean -dxf
    rm -rfv .git
  '';
}
