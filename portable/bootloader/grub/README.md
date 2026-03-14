# GRUB portable

Use this folder as the single source for portable boot settings.

Files:
- `grub.default`: template to copy into `/etc/default/grub`.
- `install-portable-grub.sh`: installs GRUB in removable mode for UEFI.
- `install-crossgrub-theme.sh`: installs Crossgrub and sets it as theme.

Notes:
- For maximum portability on external M.2, use `--removable`.
- `install-portable-grub.sh` installs Crossgrub as the main GRUB theme.
- `grub.default` sets Linux Zen as top-level default kernel.
- This script does not run automatically from `install.sh` to avoid risky boot changes.
