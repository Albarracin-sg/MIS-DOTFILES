# Portable Arch (M.2) blueprint

This folder defines the portable profile for an external M.2 Arch Linux setup.

Goals:
- Boot on most UEFI x86_64 machines.
- Keep desktop behavior predictable across 1-3+ monitors.
- Avoid hardcoded host details in dotfiles.

Structure:
- `packages/`: package manifests for official repos and AUR.
- `profiles/`: optional per-mode overlays (generic, desktop, laptop).
- `scripts/`: helper scripts for base bootstrap and profile switching.
- `bootloader/grub/`: portable GRUB templates and install helper.

Quick flow:
1. Install base Arch on M.2 using UEFI + GPT + Btrfs.
2. Clone this repo and run `./install.sh`.
3. Run `portable/scripts/setup-portable-base.sh`.
4. Log into Hyprland; monitor and GPU config is generated at startup.

Important:
- Keep secrets out of this repo (`.ssh`, `.gnupg`, API keys).
- Keep host-specific tweaks in `~/.config/hypr/autostart.conf`.
- `nmtui` is included through `networkmanager`; no extra package required.
