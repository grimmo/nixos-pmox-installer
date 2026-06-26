nixos-pmox-installer
=====================

This repository contains a minimal flake and cloud-init snippet to automate installing NixOS in a Proxmox VM (miniman ISO / cloud-init installer). It declaratively imports a separate nfs-shares.nix file that lists NFS shares to be mounted inside the VM.

Files:
- flake.nix — flake that exposes nixosConfigurations.proxmox-vm
- configuration.nix — NixOS system configuration; imports nfs-shares.nix and generates fileSystems
- nfs-shares.nix — list of NFS shares (edit this and run nixos-rebuild to change mounts)
- cloud-init-user-data.yaml — cloud-init snippet to attach to the installer ISO; replace the SSH key and adjust as needed

Next steps on the Proxmox host:
1. Upload the miniman ISO to your ISO storage.
2. Create a VM, add a disk (scsi0), attach the miniman ISO to the CDROM and add a cloud-init drive (ide2).
3. Place cloud-init-user-data.yaml as a snippet on the Proxmox host (e.g. /var/lib/vz/snippets/nixos-user-data) and set the VM to use it: qm set <VMID> --cicustom user=local:snippets/nixos-user-data
4. Start the VM. The installer will run cloud-init, clone this repo, and run nixos-install --flake .#proxmox-vm

Important:
- Replace the SSH public key in cloud-init-user-data.yaml before using.
- Edit nfs-shares.nix to match your Proxmox host IP/exports and desired mountpoints.
- After installation, edits to nfs-shares.nix require running nixos-rebuild switch on the VM (or your flake CI) to apply changes.
