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
  version ? "4.0.3",
}:
let
  system = stdenv.hostPlatform.system;

  releaseMapping = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-UKbtBHTJWOHOP7opj0X8HNMRfbXF3yU8wMfYyCfoE6g=";
    };
    x86_64-darwin = {
      target = "x86_64-apple-darwin";
      hash = "sha256-7+XtRmZg800VdJot6T/Csv0/TWSFNr6GV9Udp/ZLd1s=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-QVuX+s/USf7QajNwJzHLdVQ/BJHqd4E7AHpMS4+CXmE=";
    };
  };

  release =
    releaseMapping.${system}
      or (throw "solana-cli ${version} has no upstream Agave binary release for ${system}");

  sbfTools = "${solana-platform-tools}/bin/platform-tools-sdk/sbf/dependencies/platform-tools";
  sbfRust = "${sbfTools}/rust/bin";
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
    wrapProgram "$out/bin/cargo-build-sbf" \
      --prefix PATH : "${sbfRust}" \
      --add-flags "--tools-version v${solana-platform-tools.version}" \
      --add-flags --no-rustup-override \
      --add-flags --skip-tools-install

    wrapProgram "$out/bin/cargo-test-sbf" \
      --prefix PATH : "$out/bin"
  '';

  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/solana";
  versionCheckProgramArg = "--version";

  # Compile offline to verify that the packaged toolchain is discoverable.
  postInstallCheck = ''
    export HOME="$TMPDIR/sbf-check"
    export CARGO_HOME="$HOME/cargo"
    mkdir -p "$HOME/.cache/solana/v${solana-platform-tools.version}" "$HOME/project/src"
    ln -s ${sbfTools} "$HOME/.cache/solana/v${solana-platform-tools.version}/platform-tools"

    cat > "$HOME/project/Cargo.toml" <<'EOF'
    [package]
    name = "nix-sbf-check"
    version = "0.1.0"
    edition = "2021"
    [lib]
    crate-type = ["cdylib"]
    [profile.release]
    panic = "abort"
    EOF

    cat > "$HOME/project/src/lib.rs" <<'EOF'
    #![no_std]
    #[no_mangle]
    pub extern "C" fn entrypoint(_input: *mut u8) -> u64 {
        0
    }
    #[panic_handler]
    fn panic(_info: &core::panic::PanicInfo<'_>) -> ! {
        loop {}
    }
    EOF

    "$out/bin/cargo-build-sbf" --offline \
      --manifest-path "$HOME/project/Cargo.toml" \
      --sbf-out-dir "$HOME/deploy"
    test -s "$HOME/deploy/nix_sbf_check.so"
  '';

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
