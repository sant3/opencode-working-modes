#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [--global | --project] [--project-dir PATH] [--force]

  --global          Install for the current user in ~/.config/opencode (default)
  --project         Install in .opencode under the current project directory
  --project-dir     Project root to use with --project (default: current directory)
  --force           Replace existing files
  -h, --help        Show this help
EOF
}

mode=global
project_dir="$PWD"
force=false
while (($#)); do
  case "$1" in
    --global) mode=global ;;
    --project) mode=project ;;
    --project-dir)
      (($# >= 2)) || { echo "Missing value for --project-dir" >&2; exit 2; }
      project_dir=$2
      shift
      ;;
    --force) force=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
files=(
  "skills/working-modes/SKILL.md"
  "commands/auto.md"
  "commands/manual.md"
  "commands/plan.md"
)
source_dir=$script_dir
temp_dir=''
if [[ ! -f "$source_dir/${files[0]}" || ! -f "$source_dir/${files[1]}" ]]; then
  command -v curl >/dev/null 2>&1 || { echo 'curl is required for remote installation.' >&2; exit 1; }
  temp_dir=$(mktemp -d)
  source_dir=$temp_dir
  base_url="${OPENCODE_WORKING_MODES_BASE_URL:-https://raw.githubusercontent.com/sant3/opencode-working-modes/main}"
  for file in "${files[@]}"; do
    mkdir -p "$source_dir/$(dirname "$file")"
    curl --fail --silent --show-error --location "$base_url/$file" -o "$source_dir/$file"
  done
fi
trap '[[ -z "$temp_dir" ]] || rm -rf "$temp_dir"' EXIT

if [[ $mode == global ]]; then
  destination="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
else
  destination="$project_dir/.opencode"
fi

for file in "${files[@]}"; do
  target="$destination/$file"
  if [[ -e "$target" && $force != true ]]; then
    echo "Refusing to overwrite existing file: $target (use --force)" >&2
    exit 1
  fi
done

for file in "${files[@]}"; do
  target="$destination/$file"
  mkdir -p "$(dirname "$target")"
  cp "$source_dir/$file" "$target"
done

echo "Installed working modes in $destination"
