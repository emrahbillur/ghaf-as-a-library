# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.prune-docker-containers-host;
in {
  options.services.prune-docker-containers-host = {
    enable = mkEnableOption "prune-docker-containers-host";
  };

  config = mkIf cfg.enable {
    systemd.services.prune-docker-containers = {
      description = "Prune docker containers in case of power loss";
      after = [ "nvidia-cdi-generate.service" "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.writeShellScript "prune-docker-containers.sh" ''
          set -eu

          if [[ $EUID -ne 0 ]]; then
            echo "This script must be run as root"
            exit 1
          fi

          # If the device loses power suddenly some containers will be left in a state which
          # cannot be recovered on the next boot. Doing a container clean upi helps to resolve this issue.
          echo "Pruning docker containers"
          docker container prune -f
          echo "Exiting script"

          exit 0
        ''}";
        Environment = "PATH=/run/wrappers/bin:/root/.nix-profile/bin:/etc/profiles/per-user/root/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        Type = "oneshot";
      };
    };
  };
}
