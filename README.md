# Notes (incomplete)

To bootstrap, I used a Raspberry Pi and renamed the configuration.nix to local.nix, moved it into the mobile-nixos repo
removed the lines:

  imports = [
    (import <mobile-nixos/lib/configuration.nix> { device = "pine64-pinephone-braveheart"; })
  ];


Then built the following:

nix-build --argstr device pine64-pinephone-braveheart -A build.disk-image


Then flashed the resulting image to an SD card.

# TODO

Flash the thing to the internal MMC.
