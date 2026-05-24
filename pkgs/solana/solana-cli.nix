{
  stdenv,
  autoPatchelfHook,
  bzip2,
  fetchurl,
  gnutar,
  lib,
  makeWrapper,
  ocl-icd,
  openssl,
  sgx-psw,
  solana-platform-tools,
  udev,
  zlib,
  versionCheckHook,
  version ? "4.0.0",
}:
let
  system = stdenv.hostPlatform.system;

  releaseMapping = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-yDm6Yp0Q7dX5mvaIB9wllI/OYs1RdrVq0T4j91Yu9PI=";
    };
    x86_64-darwin = {
      target = "x86_64-apple-darwin";
      hash = "sha256-THsS0arYSmksetN0yKN+ViVc6CvMq2iwKl5AvDstQSE=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-eRln77dFyV+PaHaJIy6JV40rVAGJveLJnemHlPBoT/U=";
    };
  };

  release =
    releaseMapping.${system}
      or (throw "solana-cli ${version} has no upstream Agave binary release for ${system}");

  sbfSdk = "${solana-platform-tools}/bin/platform-tools-sdk/sbf";
  sbfRust = "${sbfSdk}/dependencies/platform-tools/rust/bin";
in
stdenv.mkDerivation rec {
  pname = "solana-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/anza-xyz/agave/releases/download/v${version}/solana-release-${release.target}.tar.bz2";
    name = "solana-release-${release.target}-${version}.tar.bz2";
    hash = release.hash;
  };

  dontUnpack = true;
  doCheck = false;

  nativeBuildInputs = [
    bzip2
    gnutar
    makeWrapper
  ] ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.isLinux [
    ocl-icd
    openssl
    sgx-psw
    stdenv.cc.cc.lib
    udev
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p release $out
    tar -xjf $src -C release

    if [ -d release/solana-release ]; then
      cp -R release/solana-release/. $out/
    elif [ -d release/bin ]; then
      cp -R release/. $out/
    else
      echo "Unsupported solana-release tarball layout for ${release.target}" >&2
      exit 1
    fi

    runHook postInstall
  '';

  postFixup = ''
    for bin in cargo-build-sbf cargo-test-sbf; do
      if [ -x "$out/bin/$bin" ]; then
        wrapProgram "$out/bin/$bin" \
          --prefix PATH : "${sbfRust}" \
          --set SBF_SDK_PATH "${sbfSdk}" \
          --append-flags --no-rustup-override \
          --append-flags --skip-tools-install
      fi
    done
  '';

  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/solana";
  versionCheckProgramArg = "--version";

  passthru = {
    platform-tools = solana-platform-tools;
  };

  meta = with lib; {
    mainProgram = "solana";
    description = "Agave/Solana CLI binary release with Nix-managed SBF platform tools";
    homepage = "https://github.com/anza-xyz/agave";
    license = licenses.asl20;
    platforms = builtins.attrNames releaseMapping;
  };
}
