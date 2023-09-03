{ config, pkgs, lib, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/raspberry-pi/4"
  ];

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
    enableRedistributableFirmware = true;
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;

    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking.hostName = "nixos-pi";

  environment.systemPackages = with pkgs; 
    [ vim git tailscale libraspberrypi raspberrypi-eeprom ];

  services.tailscale.enable = true;

  services.openssh = {
      enable = true;
      permitRootLogin = "yes";
  };

  system.stateVersion = "23.05";

  users.extraUsers.root.openssh.authorizedKeys.keys = [
     "${{ secrets.NIXOS_PUB_SSH_KEY }}"
  ];
}