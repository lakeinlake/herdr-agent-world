#!/bin/sh
# Install a prebuilt release without a language runtime or administrator access.
set -eu
umask 077
fail() { echo "Grove installation failed: $*" >&2; exit 1; }
grove_local=
grove_shortcuts=1
grove_open=1
grove_marketplace=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --local) [ "$#" -ge 2 ] && [ -n "$2" ] || fail '--local needs a directory'; grove_local=$2; shift 2 ;;
    --no-shortcuts) grove_shortcuts=0; shift ;;
    --no-open) grove_open=0; shift ;;
    --marketplace) grove_marketplace=1; shift ;;
    --help|-h) echo 'Usage: install.sh [--local DIR] [--no-shortcuts] [--no-open] [--marketplace]'; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done
# Herdr build commands have no runtime context and only install the service.
if [ "$grove_marketplace" = 1 ]; then
  grove_shortcuts=0
  grove_open=0
else
  [ "${HERDR_ENV:-}" = 1 ] || fail 'run this command in a shell pane inside Herdr'
fi
grove_os=$(uname -s)
case "$grove_os" in
  Darwin) grove_platform=apple-darwin; grove_tools='plutil launchctl' ;;
  Linux) grove_platform=unknown-linux-musl; grove_tools='timeout flock' ;;
  *) fail 'this installer supports macOS, Linux and WSL2; native Windows is unsupported' ;;
esac
case "$(uname -m)" in
  arm64|aarch64) grove_target=aarch64-$grove_platform ;;
  x86_64) grove_target=x86_64-$grove_platform ;;
  *) fail 'unsupported architecture: use an x86_64 or aarch64 system' ;;
esac
if command -v sha256sum >/dev/null 2>&1; then grove_sha=sha256sum
elif command -v shasum >/dev/null 2>&1; then grove_sha=shasum
else fail 'sha256sum or shasum is required'; fi
for grove_tool in tar awk sed mktemp $grove_tools; do
  command -v "$grove_tool" >/dev/null 2>&1 || fail "required command unavailable: $grove_tool"
done
if [ "$grove_marketplace" = 0 ]; then
  command -v herdr >/dev/null 2>&1 || fail 'required command unavailable: herdr'
  grove_version=$(herdr --version) || fail 'could not read the Herdr version'
  printf '%s\n' "$grove_version" | awk '
    { for (i=1; i<=NF; i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+$/) {
        split($i,v,"."); if (v[1]+0>0 || v[2]+0>=8) ok=1
      }} END { exit !ok }' || fail 'Herdr 0.8.0 or newer is required'
fi
[ -n "${HOME:-}" ] || fail 'HOME is required'
case "$HOME" in /*) ;; *) fail 'HOME must be absolute' ;; esac

if [ -n "$grove_local" ]; then
  [ -d "$grove_local" ] || fail 'local package directory is missing'
  grove_package=$(CDPATH= cd -- "$grove_local" && pwd -P)
else
  command -v curl >/dev/null 2>&1 || fail 'curl is required'
  grove_download=$(mktemp -d "${TMPDIR:-/tmp}/grove-download.XXXXXX")
  trap 'rm -rf "$grove_download"' EXIT
  trap 'exit 130' HUP INT TERM
  grove_name="herdr-grove-$grove_target"
  grove_release=v0.2.0
  grove_url="https://github.com/lakeinlake/herdr-agent-world/releases/download/$grove_release/$grove_name.tar.gz"
  echo "Downloading Herdr Agent World $grove_release for $grove_os..."
  curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' "$grove_url" -o "$grove_download/package.tar.gz" || fail 'release download unavailable; use --local for an already-built package'
  curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' "$grove_url.sha256" -o "$grove_download/package.sha256" || fail 'release checksum unavailable'
  grove_expected=$(awk 'NR==1 && NF>=1 {print tolower($1)} NR>1 {exit 1}' "$grove_download/package.sha256") || fail 'invalid release checksum'
  case "$grove_expected" in ''|*[!a-fA-F0-9]*) fail 'invalid release checksum' ;; esac
  [ "${#grove_expected}" -eq 64 ] || fail 'invalid release checksum'
  if [ "$grove_sha" = sha256sum ]; then
    grove_actual=$(sha256sum "$grove_download/package.tar.gz" | awk '{print $1}')
  else grove_actual=$(shasum -a 256 "$grove_download/package.tar.gz" | awk '{print $1}'); fi
  [ "$grove_actual" = "$grove_expected" ] || fail 'release checksum does not match; nothing installed'
  tar -tzf "$grove_download/package.tar.gz" > "$grove_download/names" || fail 'unreadable release archive'
  tar -tvzf "$grove_download/package.tar.gz" > "$grove_download/types" || fail 'unreadable release archive'
  # A closed list rejects traversal, escaped names, links and unexpected payloads.
  awk -v root="$grove_name" '
    { if ($0 !~ /^[-d]/) exit 1; n++ } END { if (!n) exit 1 }' "$grove_download/types" || fail 'archive contains links or special files'
  while IFS= read -r grove_entry; do
    case "$grove_entry" in
      "$grove_name"/|"$grove_name"/target/|"$grove_name"/target/release/|"$grove_name"/platform/|"$grove_name"/platform/macos/|"$grove_name"/platform/linux/|"$grove_name"/skills/|"$grove_name"/skills/grove/|"$grove_name"/docs/|\
      "$grove_name"/target/release/grove|"$grove_name"/herdr-plugin.toml|"$grove_name"/README.md|"$grove_name"/CONTRACT.md|"$grove_name"/install.sh|"$grove_name"/CREDITS.md|"$grove_name"/THIRD_PARTY_NOTICES.md|"$grove_name"/docs/service.md|\
      "$grove_name"/platform/open-grove|"$grove_name"/platform/grove.zsh|"$grove_name"/platform/install-grove|"$grove_name"/platform/macos/grove-service|"$grove_name"/platform/linux/grove-service|"$grove_name"/skills/grove/SKILL.md) ;;
      *) fail 'archive contains an unexpected or unsafe path' ;;
    esac
  done < "$grove_download/names"
  mkdir "$grove_download/unpacked"
  tar -xzf "$grove_download/package.tar.gz" -C "$grove_download/unpacked" --no-same-owner --no-same-permissions || fail 'release extraction failed'
  grove_package="$grove_download/unpacked/$grove_name"
fi
[ ! -L "$grove_package/platform" ] && [ -f "$grove_package/platform/install-grove" ] && [ ! -L "$grove_package/platform/install-grove" ] || fail 'package installation helper is missing or unsafe'
if [ "$grove_marketplace" = 1 ]; then
  sh "$grove_package/platform/install-grove" "$grove_package" 0 0 --service-only
else
  sh "$grove_package/platform/install-grove" "$grove_package" "$grove_shortcuts" "$grove_open"
fi
