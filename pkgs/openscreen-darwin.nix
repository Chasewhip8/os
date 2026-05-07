{
  fetchurl,
  lib,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation rec {
  pname = "openscreen";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/siddharthvaddem/openscreen/releases/download/v${version}/Openscreen-mac-installer.dmg";
    hash = "sha256-dYL2C/s5TvgdjhXKnMNAIbGM4FaZbuogGNEsONir430=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R ./*.app "$out/Applications/"

    runHook postInstall
  '';

  meta = {
    description = "Desktop screen recorder with built-in editor";
    homepage = "https://github.com/siddharthvaddem/openscreen";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
