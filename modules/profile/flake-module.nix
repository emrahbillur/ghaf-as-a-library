# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{inputs, ...}: {
  flake.nixosModules = {
    fog-personalize.imports = [
      inputs.ghaf.nixosModules.reference-personalize
      ./personalize.nix
      {
        ghaf.reference.personalize.keys.enable = true;
      }
    ];
  };
}
