# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{inputs, ...}: {
  flake.nixosModules = {
    gal-profile.imports = [
      (import ./gal.nix { inherit inputs; })
    ];
    gal-personalize.imports = [
      inputs.ghaf.nixosModules.reference-personalize
      ./personalize.nix
      {
        gal.personalize.debug.enable = true;
        ghaf.reference.personalize.keys.enable = true;
      }
    ];
  };
}
