{ config, pkgs, lib, ... }:

let
  shares = import ./nfs-shares.nix;
  mkFs = share: {
    device = "${share.server}:${share.export}";
    fsType = "nfs";
    options = (share.options or "_netdev,defaults") + ",x-systemd.automount,x-systemd.requires=network-online.target";
  };
  fsAttrs = lib.listToAttrs (map (share: {
    name = share.mountPoint;
    value = mkFs share;
  }) shares);
  tmpRules = map (s: "d ${s.mountPoint} 0755 root root - -") shares;
in {
  imports = [ ];

  networking.hostName = "proxmox-nixos-vm";

  services.nfs.client.enable = true;

  fileSystems = fsAttrs;

  systemd.tmpfiles.rules = tmpRules;

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [ vim ];
}
