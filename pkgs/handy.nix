{
  appimageTools,
  desktop-file-utils,
  fetchurl,
  lib,
  wtype,
  xdotool,
}:

let
  pname = "handy";
  version = "0.9.6";

  src = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_${version}_amd64.AppImage";
    hash = "sha256-xlL2lXLMhGMC12B2GYoHtNYrX3tUgoWTNSdYSjxi9P0=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [ desktop-file-utils ];

  extraPkgs = _pkgs: [
    wtype
    xdotool
  ];

  extraInstallCommands = ''
    desktop-file-install --dir $out/share/applications \
      --set-key Exec --set-value handy \
      --set-key Categories --set-value "Utility;Accessibility;" \
      ${appimageContents}/Handy.desktop

    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Free, offline speech-to-text desktop application";
    homepage = "https://handy.computer/";
    license = lib.licenses.mit;
    mainProgram = "handy";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
