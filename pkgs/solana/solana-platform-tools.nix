{
  stdenv,
  autoPatchelfHook,
  bzip2,
  criterion,
  fetchurl,
  gnutar,
  lib,
  libclang,
  libedit,
  libxml2,
  openssl,
  python3,
  udev,
  xz,
  zlib,
  solanaVersion ? "4.0.0",
  version ? "1.54",
}:
let
  system = stdenv.hostPlatform.system;

  systemMapping = {
    x86_64-linux = "linux-x86_64";
    aarch64-linux = "linux-aarch64";
    x86_64-darwin = "osx-x86_64";
    aarch64-darwin = "osx-aarch64";
  };

  versionMapping = {
    "1.54" = {
      x86_64-linux = "sha256-/MQWMcf3dWG/VBIhi/KXUB3M8DBeooDzOPCs4qq58x4=";
      aarch64-linux = "sha256-9igS3Za2scjg4s9ncUaRLFjIPpXXYsMOiSMNZp+cLmo=";
      x86_64-darwin = "sha256-0ctxZYkgB9Ea1y/e0Wx2km5d+p/yhv49mZRAwa80p1g=";
      aarch64-darwin = "sha256-HIs69ehhThxFk5OpXFsZv7zI7ROCKhy1OfrmhHH5v7s=";
    };
    "1.52" = {
      x86_64-linux = "sha256-fAEd7Bva2S6gW4+2xyp0TurkO1ygDQbGNvDOXMbNHAI=";
      aarch64-linux = "sha256-ApZHbpU76ASEWo5JEmIoGV8v+iZmVM7txPVTiEC7Eug=";
      x86_64-darwin = "sha256-iZ4qjW1emhuwHv13EuZ79I+UZClMtLRvoZA5/iqvbgA=";
      aarch64-darwin = "sha256-+seEpShbkN87ECsL7XeMF8oixqqLtO9aR2lmc+qssSY=";
    };
    "1.48" = {
      x86_64-linux = "sha256-vHeOPs7B7WptUJ/mVvyt7ue+MqfqAsbwAHM+xlN/tgQ=";
      aarch64-linux = "sha256-i3I9pwa+DyMJINFr+IucwytzEHdiRZU6r7xWHzppuR4=";
      x86_64-darwin = "sha256-bXV4S8JeM4RJ7D9u+ruwtNFJ9aq01cFw80sprxB+Xng=";
      aarch64-darwin = "sha256-ViXRoGlfn0aduNaZgsiXTcSIZO560DmFF5+kh3kYNIA=";
    };
  };

  releaseSystem = systemMapping."${system}";
  releaseHash = versionMapping."${version}"."${system}";
  sbfSdk = fetchurl {
    url = "https://github.com/anza-xyz/agave/releases/download/v${solanaVersion}/sbf-sdk.tar.bz2";
    hash = "sha256-DkcFrczFsWdT+6YtoTSwdY+tK1Yv6jtgRt0/6dn/rwU=";
  };
in
stdenv.mkDerivation rec {
  pname = "solana-platform-tools";
  inherit version;

  src = fetchurl {
    url = "https://github.com/anza-xyz/platform-tools/releases/download/v${version}/platform-tools-${releaseSystem}.tar.bz2";
    name = "platform-tools-${releaseSystem}-${version}.tar.bz2";
    hash = releaseHash;
  };

  dontUnpack = true;
  doCheck = false;

  # https://github.com/NixOS/nixpkgs/issues/380196#issuecomment-2646189651
  dontCheckForBrokenSymlinks = true;

  nativeBuildInputs = [
    bzip2
    gnutar
  ] ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  # liblldb wants libpython3.10 which is gone from nixpkgs-unstable.
  # It's only the LLVM debugger — not needed for SBF compilation.
  # liblldb (LLVM debugger) wants libpython3.10 + libxml2 — neither needed for SBF compilation.
  # python310 is gone from nixpkgs-unstable; ignore both rather than pull in stale deps.
  autoPatchelfIgnoreMissingDeps = [ "libpython3.*" "libxml2.*" ];

  buildInputs = [
    libedit
    libxml2
    zlib
    stdenv.cc.cc
    libclang.lib
    xz
    python3
  ] ++ lib.optionals stdenv.isLinux [ openssl udev ];

  installPhase = ''
    runHook preInstall

    mkdir -p platform-tools sbf-sdk
    tar -xjf $src -C platform-tools
    tar -xjf ${sbfSdk} -C sbf-sdk

    platformtools=$out/bin/platform-tools-sdk/sbf/dependencies/platform-tools
    mkdir -p $platformtools
    cp -r platform-tools/llvm $platformtools
    cp -r platform-tools/rust $platformtools
    chmod 0755 -R $out
    touch $platformtools-${version}.md

    # Criterion is also needed
    criterion=$out/bin/platform-tools-sdk/sbf/dependencies/criterion
    mkdir $criterion
    ln -s ${criterion.dev}/include $criterion/include
    ln -s ${criterion}/lib $criterion/lib
    ln -s ${criterion}/share $criterion/share
    touch $criterion-v${criterion.version}.md

    if [ -d sbf-sdk/platform-tools-sdk/sbf ]; then
      cp -ar sbf-sdk/platform-tools-sdk/sbf/. $out/bin/platform-tools-sdk/sbf/
    elif [ -d sbf-sdk/sbf ]; then
      cp -ar sbf-sdk/sbf/. $out/bin/platform-tools-sdk/sbf/
    elif [ -d sbf-sdk/sbf-sdk ]; then
      cp -ar sbf-sdk/sbf-sdk/. $out/bin/platform-tools-sdk/sbf/
    else
      echo "Unsupported sbf-sdk.tar.bz2 layout for Agave ${solanaVersion}" >&2
      exit 1
    fi

    runHook postInstall
  '';

  # Patch libedit reference — find the actual liblldb dynamically
  postFixup = lib.optionalString stdenv.isLinux ''
    for f in $out/bin/platform-tools-sdk/sbf/dependencies/platform-tools/llvm/lib/liblldb.so.*; do
      patchelf --replace-needed libedit.so.2 libedit.so "$f" 2>/dev/null || true
    done
  '';

  # Preserve metadata in .rlib (macOS strip issue)
  # https://github.com/NixOS/nixpkgs/issues/218712
  stripExclude = [ "*.rlib" ];

  meta = with lib; {
    description = "Solana Platform Tools";
    homepage = "https://solana.com";
    platforms = platforms.aarch64 ++ platforms.unix;
  };

  passthru = {
    otherVersions = builtins.attrNames versionMapping;
  };
}
