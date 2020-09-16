# Notes (incomplete)

To bootstrap, I used a Raspberry Pi and renamed the configuration.nix to local.nix, moved it into the mobile-nixos repo
removed the lines:

  imports = [
    (import <mobile-nixos/lib/configuration.nix> { device = "pine64-pinephone-braveheart"; })
  ];


Then built the following:

nix-build --argstr device pine64-pinephone-braveheart -A build.disk-image

The key to making this work was that I set:

`openssh.authorizedKeys.keys` for the `root` user to my ssh key and configured `networking.wireles.networks` to automatically connect to my WiFi hotspot.

Then flashed the resulting image to an SD card. The system booted up fine and
the phone did connect to my local Wifi. This enabled me to WiFi into the box.
After ssh-ing into the box I copied over the same image and flashed it onto
/dev/mmcblk2. This seemed like a bad idea after that, because it resulted in
both the SD and the eMMC being labeled `NIXOS_SYSTEM` and the running system
thought it hat mounted the eMMC on / and the SD card on /nix/store.  I still
could growpart the SD. resize2fs failed, but it seemed fine on the next boot.
I have no idea if this was the best option. But it worked.

