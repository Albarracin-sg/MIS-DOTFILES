#!/usr/bin/env bash
set -euo pipefail

profile="${1:-portable}"

if [[ "$profile" == --* ]]; then
  set -- portable "$@"
  profile="portable"
fi

config_root="${OPENCODE_ROOT:-$HOME/.config/opencode}"
opencode_bin="${OPENCODE_BIN:-$HOME/.opencode/bin/opencode}"
profile_dir="$config_root/profiles/$profile"

load_env_file() {
  local file=$1

  if [ ! -f "$file" ]; then
    return
  fi

  set -a
  # shellcheck source=/dev/null
  . "$file"
  set +a
}

if [ ! -x "$opencode_bin" ]; then
  echo "ERROR: no se encontro OpenCode en $opencode_bin" >&2
  exit 1
fi

if [ ! -d "$profile_dir" ]; then
  echo "ERROR: no existe el perfil $profile en $profile_dir" >&2
  exit 1
fi

load_env_file "$config_root/.env"
load_env_file "$config_root/.env.local"
load_env_file "$profile_dir/.env"
load_env_file "${OPENCODE_ENV_FILE:-$HOME/.config/opencode.env}"
load_env_file "$HOME/.config/opencode.$profile.env"

shift || true

exec env OPENCODE_CONFIG_DIR="$profile_dir" "$opencode_bin" "$@"
