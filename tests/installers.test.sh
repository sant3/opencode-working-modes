#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
temp_root=$(mktemp -d)
trap 'rm -rf "$temp_root"' EXIT
project_root="$temp_root/project"
global_config="$temp_root/global-config"
mkdir -p "$project_root"

XDG_CONFIG_HOME="$global_config" "$repo_root/install.sh" --project --project-dir "$project_root"
cmp "$repo_root/skills/working-modes/SKILL.md" "$project_root/.opencode/skills/working-modes/SKILL.md"
for command in auto manual plan; do
  cmp "$repo_root/commands/$command.md" "$project_root/.opencode/commands/$command.md"
done

printf 'preserve-existing\n' > "$project_root/.opencode/commands/auto.md"
if "$repo_root/install.sh" --project --project-dir "$project_root"; then
  echo 'Installer unexpectedly overwrote existing files without --force.' >&2
  exit 1
fi
[[ $(cat "$project_root/.opencode/commands/auto.md") == 'preserve-existing' ]]
cmp "$repo_root/commands/manual.md" "$project_root/.opencode/commands/manual.md"

XDG_CONFIG_HOME="$global_config" "$repo_root/install.sh" --project --project-dir "$project_root" --force
cmp "$repo_root/commands/auto.md" "$project_root/.opencode/commands/auto.md"

XDG_CONFIG_HOME="$global_config" "$repo_root/install.sh" --global
cmp "$repo_root/skills/working-modes/SKILL.md" "$global_config/opencode/skills/working-modes/SKILL.md"

echo 'Bash installer tests passed.'
