{ config, pkgs, ... }:
{
  imports = [
    (import <mobile-nixos/lib/configuration.nix> { device = "pine64-pinephone-braveheart"; })
  ];
  users.users."sepp" = {
    isNormalUser = true;
    initialPassword = "";
    extraGroups = [ "wheel" "networkmanager" "input" ];
  };

  networking.hostName = "flakephone";
  networking.wireless = {
    enable = true;
    networks = {
      bananaNet = {
        # Generated using `wpa_passphrase bananaNet`. A slight security issue, but I don't have wired networking yet...
        pskRaw = "8932ea09b8f3b13d65a770a6f49c1ed84383bd5d7bc0c9b2cd3d5d5ea883863c";
      };
    };
  };
  systemd.services.wpa_supplicant.serviceConfig = {
    # First login attempt doesn't work for whatever reason
    Restart = "always";
    RestartSec = 8;
    StartLimitIntervalSec = 0; # Don't stop trying after a couple of restarts
  };
  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;
  networking.enableIPv6 = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  time.timeZone = "Europe/Vienna";

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/Z8395cyaul/PIgLDCSgHWrg3h1xiALouLu8gAOYb9CtN05VTSOINuI95rcdPFIQC+2vconZ/sW2j+mUmsrIP6b2eFm1XRg6Nicu9tPK+fqksSqL2TjPijwmeptljDwUN/F5YfCRCFCixAtRq5wTARbEzC8hDvnfaoimiRD4JyMCnRJvEAZxh5AsY5vD42sQVmS1xh7lx80gd7ARdeKh5xBV/ccnFzON0U9HTM4DNSa2URV+QCJec1ORYHAfo+DdmR+q7J96lVp5UbLki1Ym4KEW6eCUeOZ6bAq8aaFlWmlwFIMNOzfEc/kZRDurRj8IJx5BWzI1RPRg9Z+ChqbZh josef.kemetmueller@PC-18801"
    ];
  };
}

