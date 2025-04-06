with (import <nixpkgs> { });
stdenv.mkDerivation {
  name = "avf-channel-avf.tar.xz";

  dontFixup = true;
  dontBuild = true;
  dontConfigure = true;

  src = ./../.;

  nativeBuildInputs = [
    git
  ];

  installPhase = ''
    git clean -dxf
    rm -rfv .git
    BASE=$(basename "$PWD")
    cd ..
    tar cvfJ $out "$BASE"
  '';
}
