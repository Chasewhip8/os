{
  addDriverRunpath,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  bash,
  bubblewrap,
  cairo,
  coreutils,
  cups,
  curl,
  dbus,
  dpkg,
  expat,
  fetchurl,
  findutils,
  fontconfig,
  gawk,
  gdk-pixbuf,
  git,
  glib,
  gnugrep,
  gnused,
  graphite2,
  gsettings-desktop-schemas,
  gtk3,
  lib,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libusb1,
  libxcrypt-legacy,
  libxkbcommon,
  libX11,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXScrnSaver,
  libXtst,
  libxcb,
  makeWrapper,
  mesa,
  nix-ld,
  nodejs,
  nspr,
  nss,
  openssl,
  pango,
  pipewire,
  procps,
  python3,
  stdenv,
  systemd,
  util-linux,
  wayland,
  xdg-utils,
  xz,
  zlib,
  zstd,
}:

let
  pname = "chatgpt";
  version = "26.908.40834";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_amd64.deb";
    hash = "sha256-2je457zvquoBnEeMrL5sc+4d3RXg4euzx+8KQt2BisI=";
  };

  # Ubuntu workspace binaries can request libcurl-gnutls.so.4 and its
  # CURL_GNUTLS_3 symbol version rather than Nixpkgs' OpenSSL-flavoured curl.
  curlWithGnuTlsCompat =
    (curl.override {
      gnutlsSupport = true;
      http3Support = false;
      opensslSupport = false;
    }).overrideAttrs
      (previousAttrs: {
        postPatch = (previousAttrs.postPatch or "") + ''
          substituteInPlace lib/libcurl.vers.in \
            --replace-fail \
              'CURL_@CURL_LIBCURL_VERSIONED_SYMBOLS_PREFIX@@CURL_LIBCURL_VERSIONED_SYMBOLS_SONAME@' \
              'CURL_GNUTLS_3'
        '';
      });

  runtimeLibraries = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    curlWithGnuTlsCompat.out
    dbus
    expat
    fontconfig
    gdk-pixbuf
    glib
    graphite2
    gtk3
    libdrm
    libgbm
    libglvnd
    libnotify
    libusb1
    libxcrypt-legacy
    libxkbcommon
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXScrnSaver
    libXtst
    libxcb
    mesa
    nspr
    nss
    openssl
    pango
    pipewire
    stdenv.cc.cc.lib
    systemd
    wayland
    xz
    zlib
    zstd
  ];

  runtimeLibraryPath = lib.concatStringsSep ":" [
    "${addDriverRunpath.driverLink}/lib"
    (lib.makeLibraryPath runtimeLibraries)
  ];

  runtimePath = lib.makeBinPath [
    bash
    coreutils
    curl
    findutils
    gawk
    git
    gnugrep
    gnused
    libnotify
    nodejs
    procps
    python3
    systemd
    util-linux
    xdg-utils
  ];

  dynamicLinker = stdenv.cc.bintools.dynamicLinker;

  # ChatGPT's workspace sandbox starts distribution-built tools whose ELF
  # interpreter resolves through nix-ld. Keep that loader and its closure
  # visible inside the app's bubblewrap sandbox.
  sandboxBubblewrap = stdenv.mkDerivation {
    pname = "chatgpt-bubblewrap";
    inherit version;
    dontUnpack = true;
    nativeBuildInputs = [ makeWrapper ];
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      cat > "$out/bin/bwrap" <<'EOF'
      #!${bash}/bin/bash
      set -euo pipefail

      args=()
      injected=0
      for argument in "$@"; do
        if [[ "$argument" == "--" && "$injected" == 0 ]]; then
          loader_target="$(${coreutils}/bin/readlink -f /lib64/ld-linux-x86-64.so.2)"
          args+=(
            --ro-bind ${nix-ld}/libexec/nix-ld "$loader_target"
            --setenv NIX_LD ${dynamicLinker}
            --setenv NIX_LD_LIBRARY_PATH ${runtimeLibraryPath}
          )
          injected=1
        fi
        args+=("$argument")
      done

      exec ${bubblewrap}/bin/bwrap "''${args[@]}"
      EOF
      chmod +x "$out/bin/bwrap"
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  inherit pname src version;

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/share"
    cp -R usr/lib/chatgpt "$out/lib/"
    cp -R usr/share/applications usr/share/pixmaps "$out/share/"

    makeWrapper "$out/lib/chatgpt/ChatGPT" "$out/bin/chatgpt" \
      --prefix PATH : "${sandboxBubblewrap}/bin:${runtimePath}" \
      --set-default ALSA_PLUGIN_DIR "${pipewire}/lib/alsa-lib" \
      --set-default CODEX_CLI_PATH "$out/lib/chatgpt/resources/codex" \
      --set-default NIX_LD "${dynamicLinker}" \
      --prefix NIX_LD_LIBRARY_PATH : "$out/lib/chatgpt:${runtimeLibraryPath}" \
      --prefix XDG_DATA_DIRS : "${glib.getSchemaPath gsettings-desktop-schemas}:${glib.getSchemaPath gtk3}"

    runHook postInstall
  '';

  passthru = {
    inherit runtimeLibraries runtimeLibraryPath;
  };

  meta = {
    description = "Official ChatGPT desktop application for Linux";
    homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
