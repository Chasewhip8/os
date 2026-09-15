{
  appimageTools,
  desktop-file-utils,
  fetchurl,
  lib,
}:

let
  pname = "t3code";
  version = "0.0.40";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-i/X9RMt/rQxDGR1U/v35dKgifVBQXsuKvPdjJiCfJko=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [ desktop-file-utils ];

  extraInstallCommands = ''
    desktop-file-install --dir $out/share/applications \
      --set-key Exec --set-value "t3code %U" \
      ${appimageContents}/t3code.desktop

    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Desktop control surface for local coding agents";
    homepage = "https://t3.codes";
    changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "t3code";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
