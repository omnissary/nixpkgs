{
  lib,
  stdenv,
  fetchFromGitHub,
  telegram-desktop,
  withWebkit ? true,
}:

telegram-desktop.override {
  pname = "64gram";
  inherit withWebkit;
  unwrapped = telegram-desktop.unwrapped.overrideAttrs (old: rec {
    pname = "64gram-unwrapped";
    version = "1.2.12";

    src = fetchFromGitHub {
      owner = "TDesktop-x64";
      repo = "tdesktop";
      tag = "v${version}";
      hash = "sha256-dsk+Dy4Vm8d3l+JHiBeoUWlrTZ15O/aEOk4+pNrhAy4=";
      fetchSubmodules = true;
    };

    # Find the Swift SDK overlays needed by the translation provider.
    # Remove after next release
    env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-L/usr/lib/swift";

    meta = {
      description = "Unofficial Telegram Desktop providing Windows 64bit build and extra features";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.all;
      homepage = "https://github.com/TDesktop-x64/tdesktop";
      changelog = "https://github.com/TDesktop-x64/tdesktop/releases/tag/v${version}";
      maintainers = with lib.maintainers; [ clot27 ];
      mainProgram = "Telegram";
    };
  });
}
