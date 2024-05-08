{
  lib,
  config,
  options,
  pkgs,
  ...
}:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    mkPackageOption
    types
    optionalAttrs
  ;

  cfg = config.services.go2rtc;
  opt = options.services.go2rtc;

  format = pkgs.formats.yaml { };
  configFile = format.generate "go2rtc.yaml" cfg.settings;
in

{
  meta.buildDocsInSandbox = false;

  options.services.go2rtc = with types; {
    enable = mkEnableOption "go2rtc streaming server";

    package = mkPackageOption pkgs "go2rtc" { };

    passwordsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = mdDoc ''
        File with environment variables which will be substituted in configuration file beforre starting.

        Could be used to replace passwords in stream urls.
      '';
    };

    settings = mkOption {
      default = { };
      description = ''
        go2rtc configuration as a Nix attribute set.

        See the [wiki](https://github.com/AlexxIT/go2rtc/wiki/Configuration) for possible configuration options.
      '';
      type = submodule {
        freeformType = format.type;
        options = {
          # https://github.com/AlexxIT/go2rtc/blob/v1.5.0/README.md#module-api
          api = {
            listen = mkOption {
              type = str;
              default = ":1984";
              example = "127.0.0.1:1984";
              description = ''
                API listen address, conforming to a Go address string.
              '';
            };
          };

          # https://github.com/AlexxIT/go2rtc/blob/v1.5.0/README.md#source-ffmpeg
          ffmpeg = {
            bin = mkOption {
              type = path;
              default = lib.getExe pkgs.ffmpeg-headless;
              defaultText = literalExpression "lib.getExe pkgs.ffmpeg-headless";
              description = ''
                The ffmpeg package to use for transcoding.
              '';
            };
          };

          # TODO: https://github.com/AlexxIT/go2rtc/blob/v1.5.0/README.md#module-rtsp
          rtsp = {
          };

          streams = mkOption {
            type = attrsOf (either str (listOf str));
            default = { };
            example = literalExpression ''
              {
                cam1 = "onvif://admin:password@192.168.1.123:2020";
                cam2 = "tcp://192.168.1.123:12345";
              }
            '';
            description = ''
              Stream source configuration. Multiple source types are supported.

              Check the [configuration reference](https://github.com/AlexxIT/go2rtc/blob/v${cfg.package.version}/README.md#module-streams) for possible options.
            '';
          };

          # TODO: https://github.com/AlexxIT/go2rtc/blob/v1.5.0/README.md#module-webrtc
          webrtc = {
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.go2rtc = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        User = "go2rtc";
        SupplementaryGroups = [
          # for v4l2 devices
          "video"
        ];
        RuntimeDirectory = "go2rtc";
        StateDirectory = "go2rtc";
        ExecStartPre = "${pkgs.envsubst}/bin/envsubst -no-digit -no-unset -no-empty -i ${configFile} -o /run/go2rtc/go2rtc.yaml";
        ExecStart = "${cfg.package}/bin/go2rtc -config /run/go2rtc/go2rtc.yaml";
      } // optionalAttrs (cfg.passwordsFile != null) {
        EnvironmentFile = cfg.passwordsFile;
      };
    };
  };
}
