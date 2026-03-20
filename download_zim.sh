#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${1:-${script_dir}/data}"
links_file="${2:-${script_dir}/zim_links.txt}"

mkdir -p "$target_dir"

if [[ ! -f "$links_file" ]]; then
  echo "Links file not found: $links_file" >&2
  exit 1
fi

download_with_curl() {
  local url="$1"
  local file_name="$2"
  curl -L --fail --continue-at - -o "${target_dir}/${file_name}" "$url"
}

download_with_wget() {
  local url="$1"
  local file_name="$2"
  wget -c -O "${target_dir}/${file_name}" "$url"
}

if command -v curl >/dev/null 2>&1; then
  downloader="curl"
elif command -v wget >/dev/null 2>&1; then
  downloader="wget"
else
  echo "Neither curl nor wget is installed." >&2
  exit 1
fi

while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  # Ignore comments and empty lines.
  line="${raw_line#${raw_line%%[![:space:]]*}}"
  line="${line%${line##*[![:space:]]}}"
  [[ -z "$line" || "${line:0:1}" == "#" ]] && continue

  file_name="$(basename "${line%%\?*}")"
  if [[ -z "$file_name" || "$file_name" == "/" ]]; then
    echo "Skipping invalid URL: $line" >&2
    continue
  fi

  echo "Downloading: $file_name"
  if [[ "$downloader" == "curl" ]]; then
    download_with_curl "$line" "$file_name"
  else
    download_with_wget "$line" "$file_name"
  fi
done < "$links_file"

exec "${script_dir}/update_library.sh" "$target_dir"

