\
#!/usr/bin/env bash
set -euo pipefail

AMP_INSTANCE_ROOT="${AMP_INSTANCE_ROOT:-${PWD}}"
WRITE_DIR_NAME="${WRITE_DIR_NAME:-DCS.server}"
PAGE_URL="https://www.digitalcombatsimulator.com/en/downloads/world/server/"
MANUAL_DIR="${AMP_INSTANCE_ROOT}/_manual_steps"
GENERATED_DIR="${AMP_INSTANCE_ROOT}/_amp_generated"
WINEPREFIX_PATH="${WINEPREFIX:-${AMP_INSTANCE_ROOT}.wine}"

usage() {
  cat <<'EOF'
Usage:
  install-dcs-server-for-amp.sh download-installer
  install-dcs-server-for-amp.sh update-existing
  install-dcs-server-for-amp.sh apply-config [WriteDirName]

Environment:
  AMP_INSTANCE_ROOT   Root of the AMP instance (default: current directory)
  WINEPREFIX          Wine prefix for the instance (default: <instance-root>.wine)

Notes:
- The first DCS install is still manual. This script only downloads the modular installer.
- For headless Linux use, Wine/Xvfb must already be available (or use the AMP wine-stable image).
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }
}

download_installer() {
  require_cmd curl
  mkdir -p "${MANUAL_DIR}"

  local html rel installer_url out
  html="$(curl -fsSL "${PAGE_URL}")"
  rel="$(printf '%s' "${html}" | grep -oE '/upload/[^"'\'' <>]+/DCS_World_Server_modular\.exe' | head -n1 || true)"

  if [[ -z "${rel}" ]]; then
    echo "Unable to find installer URL on the official DCS download page." >&2
    exit 1
  fi

  installer_url="https://www.digitalcombatsimulator.com${rel}"
  out="${MANUAL_DIR}/DCS_World_Server_modular.exe"

  echo "Downloading: ${installer_url}"
  curl -fL "${installer_url}" -o "${out}"
  echo "Saved to: ${out}"
  echo
  echo "Next step:"
  echo "  Run the installer once under Wine and install DCS into:"
  echo "  ${AMP_INSTANCE_ROOT}"
}

update_existing() {
  local updater="${AMP_INSTANCE_ROOT}/bin/DCS_updater.exe"
  if [[ ! -f "${updater}" ]]; then
    echo "Could not find ${updater}" >&2
    exit 1
  fi

  require_cmd wine
  require_cmd xvfb-run
  export WINEPREFIX="${WINEPREFIX_PATH}"

  echo "Running silent update with Wine:"
  echo "  ${updater} --quiet update"
  xvfb-run -a wine "${updater}" --quiet update
}

find_saved_games_dir() {
  local target="${1}"
  local users_root="${WINEPREFIX_PATH}/drive_c/users"

  if [[ ! -d "${users_root}" ]]; then
    echo "" ; return 0
  fi

  local match
  match="$(find "${users_root}" -maxdepth 4 -type d -path "*/Saved Games/${target}" 2>/dev/null | head -n1 || true)"
  printf '%s' "${match}"
}

apply_config() {
  local target="${1:-${WRITE_DIR_NAME}}"
  local saved_games_dir
  saved_games_dir="$(find_saved_games_dir "${target}")"

  if [[ -z "${saved_games_dir}" ]]; then
    echo "Could not find Saved Games/${target} inside ${WINEPREFIX_PATH}." >&2
    echo "Start DCS once first so it creates the write directory, then rerun this command." >&2
    exit 1
  fi

  mkdir -p "${saved_games_dir}/Config"

  if [[ -f "${GENERATED_DIR}/autoexec.cfg" ]]; then
    cp -f "${GENERATED_DIR}/autoexec.cfg" "${saved_games_dir}/Config/autoexec.cfg"
    echo "Copied autoexec.cfg -> ${saved_games_dir}/Config/autoexec.cfg"
  fi

  if [[ -f "${GENERATED_DIR}/serverSettings.lua" ]]; then
    cp -f "${GENERATED_DIR}/serverSettings.lua" "${saved_games_dir}/Config/serverSettings.lua"
    echo "Copied serverSettings.lua -> ${saved_games_dir}/Config/serverSettings.lua"
  fi
}

main() {
  local cmd="${1:-}"
  case "${cmd}" in
    download-installer)
      download_installer
      ;;
    update-existing)
      update_existing
      ;;
    apply-config)
      apply_config "${2:-${WRITE_DIR_NAME}}"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
