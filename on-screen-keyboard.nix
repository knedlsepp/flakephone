{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    onboard
  ];
  environment.etc."xdg/autostart/onboard-boottime-configuration.desktop" = {
    text = let script = pkgs.writeShellScript "onboard-boottime-configuration" ''
      set -u
      set -e

      # A bit rude, but this ensures the keyboard always starts at a quarter
      # of the resolution.
      # onboard will not accept -s to set size with a docked keyboard.
      height=$(( $( ${pkgs.xlibs.xwininfo}/bin/xwininfo -root | grep '^\s\+Height:' | cut -d':' -f2 ) / 4 ))

      ${pkgs.gnome3.dconf}/bin/dconf write /org/onboard/window/landscape/dock-height "$height" || :
      ${pkgs.gnome3.dconf}/bin/dconf write /org/onboard/window/portrait/dock-height "$height"  || :
    '';
    in ''
      [Desktop Entry]
      Name=Onboard boot time configuration
      Exec=${script}
      X-XFCE-Autostart-Override=true
    '';
  };
  environment.etc."xdg/autostart/onboard-autostart.desktop" = {
    source = pkgs.runCommandNoCC "onboard-autostart.desktop" {} ''
      cat "${pkgs.onboard}/etc/xdg/autostart/onboard-autostart.desktop" > $out
      echo "X-XFCE-Autostart-Override=true" >> $out
      substituteInPlace $out \
        --replace "Icon=onboard" "Icon=input-keyboard"
    '';
  };
}
