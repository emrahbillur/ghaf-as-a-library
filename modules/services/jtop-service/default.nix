{ lib, config, pkgs, ... }:

let
  cfg = config.services.jtop-service;
  jtopDrv = cfg.package;
in
{
  ##### Options #####
  options.services.jtop-service = {
    enable = lib.mkEnableOption "Jetson Stats (jtop) server";

    # The jetson-stats package that provides the `jtop` binary.
    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        Derivation providing the `jtop` binary (jetson-stats). Must be a derivation,
        not a function. Example:
        services.jtop.package = pkgs.callPackage ../packages/jetson-stats/jetson-stats.nix {};
      '';
      example = lib.literalExpression "pkgs.callPackage ../packages/jetson-stats/jetson-stats.nix {}";
    };

    # Put the CLI in PATH for users (optional).
    exposeClient = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Add the jtop client to systemPackages.";
    };

    # Name of the state directory managed by systemd => /var/lib/${stateDirName}
    stateDirName = lib.mkOption {
      type = lib.types.str;
      default = "jtop";
      description = "State directory name under /var/lib managed by systemd (StateDirectory=).";
    };

    # Name of the runtime directory => /run/${runtimeDirName}
    runtimeDirName = lib.mkOption {
      type = lib.types.str;
      default = "jtop";
      description = "Runtime directory name under /run managed by systemd (RuntimeDirectory=).";
    };

    socketPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/jtop.sock";
      description = "UNIX socket path for the jtop server.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "jtop";
      description = "System group that owns the jtop socket (for non-root access).";
    };

    members = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "ghaf" ];
      description = "Users to add to the jtop group.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      example = lib.literalExpression "[ pkgs.coreutils ]";
      description = "Additional packages in the service PATH (e.g., tegrastats if you package it).";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = [ "--no-warnings" ];
      description = "Extra CLI args appended to `jtop` when run as a service.";
    };

    extraEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = { JTOP_COLOR_FILTER = "dark"; };
      description = "Extra environment variables for the service.";
    };

    wantedBy = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "multi-user.target" ];
      description = "Targets that should want this service.";
    };
  };

  ##### Config #####
  config = lib.mkIf cfg.enable (
    let
      # Fail early with a clear message if the package isn't a derivation.
      _check = assert lib.isDerivation jtopDrv;
        true;

      stateDir = cfg.stateDirName;
      runtimeDir = cfg.runtimeDirName;

      envList =
        [
          "JTOP_SERVICE=1"                           # service mode (as upstream expects)
          "JTOP_SOCKET=${cfg.socketPath}"            # runtime socket
          "JTOP_STATE_DIR=/var/lib/${stateDir}"      # where jtop writes persistent state
        ]
        ++ (lib.mapAttrsToList (k: v: "${k}=${v}") cfg.extraEnv);
    in
    {
      # Make the client available to users if requested
      environment.systemPackages = lib.mkIf cfg.exposeClient [ jtopDrv ];

      # Create group and manage members for socket access
      users.groups.${cfg.group}.members = cfg.members;

      # The service itself
      systemd.services.jtop = {
        description = "Jetson Stats Monitoring Service (jtop)";
        wantedBy    = cfg.wantedBy;
        after       = [ "local-fs.target" "network.target" ];

        # Keep boot resilient; avoid thrashing
        unitConfig = {
          StartLimitIntervalSec = 60;
          StartLimitBurst       = 3;
          IgnoreOnIsolate       = true;
        };

        # Ensure the jtop binary and optional helpers are in PATH
        path = [ jtopDrv ] ++ cfg.extraPackages;

        serviceConfig = {
          Type = "simple";
          Environment = envList;

          # systemd-managed dirs (correct perms and ordering)
          StateDirectory       = stateDir;               # -> /var/lib/${stateDir}
          RuntimeDirectory     = runtimeDir;             # -> /run/${runtimeDir}
          RuntimeDirectoryMode = "0775";

          Group = cfg.group;

          # Use mainProgram from the package (safer than manual string interp)
          ExecStart = "${lib.getExe jtopDrv} ${lib.escapeShellArgs cfg.extraArgs}";

          Restart        = "on-failure";
          RestartSec     = 2;
          TimeoutStartSec = 10;
        };
      };
    }
  );
}
