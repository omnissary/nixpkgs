{
  distroName,
  lib,
  pkgs,
}:

let
  inherit (lib) escapeShellArg makeBinPath;
in

pkgs.replaceVarsWith {
  src = ./extlinux-conf-builder.sh;
  isExecutable = true;
  replacements = {
    distroName = escapeShellArg distroName;
    path = makeBinPath [
      pkgs.coreutils
      pkgs.gnused
      pkgs.gnugrep
    ];
    inherit (pkgs) bash;
  };
}
