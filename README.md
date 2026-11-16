# OpenCode Working Modes

Three OpenCode commands for switching the current conversation between **auto**, **manual**, and **plan** mode. The commands work with the `working-modes` skill, which defines how each mode should be applied.

## Modes

- **`/auto [task]`** — carry out the task end to end, making routine decisions autonomously and running appropriate checks.
- **`/manual [task]`** — show a concise proposed diff and wait for approval before each set of file changes.
- **`/plan [task]`** — inspect the relevant context and produce an actionable plan without implementing it.

A selected mode remains active for the conversation until another mode is selected or the user gives a conflicting instruction.

## Quick install

The remote installers download the skill and command files from this repository. Review the script before running it if you prefer to inspect installation behavior first.

### Linux and macOS

Install globally:

```sh
curl -fsSL https://raw.githubusercontent.com/sant3/opencode-working-modes/main/install.sh | bash
```

Install into the current project:

```sh
curl -fsSL https://raw.githubusercontent.com/sant3/opencode-working-modes/main/install.sh | bash -s -- --project
```

### Windows PowerShell

Install globally:

```powershell
$script = (Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/sant3/opencode-working-modes/main/install.ps1).Content
& ([scriptblock]::Create($script))
```

Install into the current project:

```powershell
$script = (Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/sant3/opencode-working-modes/main/install.ps1).Content
& ([scriptblock]::Create($script)) -Project
```

### Install options

Both installers default to a global installation under `~/.config/opencode/`. Use `--project` / `-Project` to install into `.opencode/` in the current directory. For another project root, use `--project-dir PATH` / `-ProjectDir PATH`. Existing files are preserved and cause the installer to stop unless `--force` / `-Force` is supplied.

You can also clone this repository and run the installer locally:

```sh
git clone https://github.com/sant3/opencode-working-modes.git
cd opencode-working-modes
./install.sh --project
```

```powershell
git clone https://github.com/sant3/opencode-working-modes.git
Set-Location opencode-working-modes
.\install.ps1 -Project
```

To install manually, copy `skills/working-modes/` and `commands/` into your OpenCode configuration directory. For project-local installation, that directory is `.opencode/`; for a global installation, it is `~/.config/opencode/`.

## Usage

Use a command with an optional task, for example:

```text
/auto Add input validation to the signup form
/manual Update the API client error messages
/plan Find where user preferences are loaded
```

The skill is installed at `skills/working-modes/SKILL.md`, and commands are installed under `commands/`.

## License

MIT. See [LICENSE](LICENSE).
