# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a [chezmoi](https://www.chezmoi.io) source directory: it stores dotfiles in their chezmoi-encoded form (renamed/templated), not as literal copies of the files that end up in `$HOME`. Editing a file here does not directly change anything on disk until `chezmoi apply` runs.

Non-default setup: chezmoi's source directory is pointed at this repo (`~/dotfiles`) via `sourceDir = "/home/hiukky/dotfiles"` in `~/.config/chezmoi/chezmoi.toml`, instead of chezmoi's default `~/.local/share/chezmoi`. Any `chezmoi` command run on this machine operates on this repo.

## Commands

```sh
chezmoi add ~/.zshrc      # import an existing dotfile into the source dir (encodes the name)
chezmoi edit ~/.zshrc     # edit the source-dir version of a managed file
chezmoi diff              # preview what `apply` would change on disk
chezmoi apply             # write changes from the source dir to $HOME
chezmoi apply -v          # same, but print each change
chezmoi status            # short status of pending changes
chezmoi cd                # open a subshell in the source dir (same as cd'ing here)
chezmoi managed           # list all files/dirs currently managed
bash .chezmoiscripts/run_once_before_XX-foo.sh   # run a single install script directly, without a full chezmoi apply
```

Bootstrap on a new machine (from `README.md`), same command whether chezmoi has run here before or not (see `setup.sh` below):

```sh
sh -c "$(curl -fsLS https://hiukky.com/setup.sh)"
```

## Source-file naming convention

chezmoi maps source filenames to target paths using prefixes/suffixes. This mapping is the main thing to get right when adding or renaming files here:

- `dot_foo` → `~/.foo`
- `private_dot_foo` → `~/.foo` applied with mode `0600`
- `executable_foo` → `foo` with the executable bit set
- `foo.tmpl` → rendered as a Go template before being written
- `.chezmoiignore` lists source-relative target paths to never apply (currently `README.md`, `LICENSE`, `CLAUDE.md`, so the repo's own docs aren't written into `$HOME`)
- `.chezmoiroot`, if added later, would rebase the source root to a subdirectory (not currently used; the repo root is the source root)

When adding a new dotfile, prefer `chezmoi add <path>` over manually creating the encoded filename, so the encoding matches what chezmoi expects.

## Making the repo forkable (`.chezmoi.toml.tmpl`)

Personal values that would otherwise be hardcoded (git name/email/GPG signing key) are parameterized via chezmoi's own data mechanism instead of a custom `.env` convention, so someone forking this repo gets prompted for their own values instead of inheriting the owner's:

- `.chezmoi.toml.tmpl` runs once, during `chezmoi init`, and uses `promptStringOnce` to ask for `name`, `email`, `signingKey` (each with the current owner's value shown as the suggested default). Offering a default is what makes forking friendly without forcing every field to be re-typed. The answers are saved to `~/.config/chezmoi/chezmoi.toml` under `[data]`, outside the repo.
- Any `.tmpl` file can then reference `{{ .name }}`, `{{ .email }}`, `{{ .signingKey }}` (see `dot_gitconfig.tmpl`, which also conditionally disables `commit.gpgsign` when `signingKey` is left blank, so a fork without GPG set up doesn't get broken commit signing).
- This machine's `~/.config/chezmoi/chezmoi.toml` already has `[data]` set manually (matching `.chezmoi.toml.tmpl`'s defaults), since it predates this file and was never re-initialized with `chezmoi init`. Only a fresh `chezmoi init` on a new machine actually triggers the prompts.
- Not every hardcoded personal value needs this treatment: scripts that already derive values at runtime (e.g. `run_once_after_95-account-setup.sh`'s SSH key comment uses `$(whoami)@$(hostname)`, not a fixed string) are already agnostic and don't need templating.

## Install scripts (`.chezmoiscripts/`)

Dotfiles alone are not enough: `.zshrc` assumes `zinit`, `eza`, `bat`, `fd`, `ripgrep`, `starship`, `mise`, `docker`, `nvim`, `claude` etc. already exist. These are installed by scripts under `.chezmoiscripts/`, a directory chezmoi treats specially: its contents are executed as scripts (per the usual `run_once_`/`run_onchange_`/`before_`/`after_` naming rules), not written to `$HOME`, and are kept out of `chezmoi managed`'s regular dotfile listing conceptually (organizational separation from the actual dotfiles at the repo root).

- `run_once_before_*` scripts run before any dotfile is written to `$HOME`, in numeric-prefix order.
- `run_once_after_*` scripts run after all dotfiles are applied. Required for anything that depends on an applied config file, e.g. `run_once_after_80-mise-setup.sh` runs `mise install` only after `dot_config/mise/config.toml` has actually been written to `~/.config/mise/config.toml`.
- Each `run_once_` script is tracked by content hash: it runs once, and editing it makes it eligible to run again on the next `chezmoi apply`. All scripts are idempotent (`command -v` checks before installing), so re-applying is always safe.

Rust, bun, glow and rtk are all installed via mise (`dot_config/mise/config.toml`) rather than dedicated scripts. mise has core/aqua/github backends for all four, so there's no need for a separate curl-based installer per tool.

`dot_fzf.zsh` is tracked because Ubuntu's apt `fzf` package doesn't ship the `~/.fzf.zsh` shim that `.zshrc` sources for Ctrl+T/Ctrl+R key bindings and completion. Without this file, `fzf` installs but its shell integration silently does nothing.

`run_once_before_16-llama-windows.sh` is also WSL-specific, for the same shell-out-to-`powershell.exe` reason: local inference needs to run natively on Windows to access the GPU (WSL's own GPU passthrough is not what you want for a long-running local inference server), so this installs two independent things on the Windows host: llama.cpp itself, via its official installer (`irm https://llama.app/install.ps1 | iex`), and [llmfit](https://github.com/AlexsJones/llmfit) via scoop (bootstrapping scoop itself first if missing). llmfit only scores model fit and benchmarks against whatever runtime provider is already present (Ollama, llama.cpp, MLX, Docker Model Runner, LM Studio) -- it does not install or manage llama.cpp itself, so both installs are required. Like the font script, its effects are host-wide, not per-distro. Replaced a plain Ollama install (`OllamaSetup.exe /VERYSILENT`) on 2026-08-12 after a disk-space audit found ~69GB of unused Ollama models on the Windows host and a llm-compressor test leftover eating 123GB in the WSL-side HF cache; llama.cpp + llmfit were already doing the same job with lower footprint.

`run_once_before_18-windows-apps.sh` installs personal desktop apps (Discord, Notion, Steam, dev tools, media apps, utilities; see README's table): Microsoft Store first, winget's community repo as fallback. Gotcha: its idempotency check (`winget list --id <id> --source <source> --exact`) only recognizes an app as "already installed" if winget itself installed it under that exact id/source, so an app installed some other way (e.g. Chrome, downloaded directly from the vendor's site) gets silently reinstalled/updated over the top. Harmless, but explains why a script here can appear to "reinstall" something already present. WhatsApp Desktop is a manual Store install; no id winget can resolve under either source.

`run_once_before_17-virtualbox-windows.sh` is also WSL-specific: VirtualBox belongs on the Windows host (a Hyper-V guest can't meaningfully host its own type-2 hypervisor), installed via `winget install Oracle.VirtualBox`. Gotcha: it installs a kernel driver, so unlike every other WSL-host script here, **this one triggers a real UAC prompt** and cannot be made fully silent.

`run_once_before_15-nerd-font.sh` is WSL-specific (no-ops outside WSL, detected via `/proc/version`): starship and `eza --icons` render glyphs that require a Nerd Font, but under WSL the font is rendered by the Windows Terminal process, not the Linux side, so this script shells out to `powershell.exe` to install FiraCode Nerd Font and set it as the Windows Terminal default font face. Unlike every other script here, its effects are **not** isolated per WSL distro: it touches the single shared Windows user font store and the single shared Windows Terminal `settings.json` (which it backs up to `settings.json.bak` before editing), regardless of which distro triggered it.

## Windows-side config (`.chezmoitemplates/`)

`.wslconfig` and Windows Terminal's `settings.json` live on the Windows filesystem, outside `$HOME` on the Linux side, so they can't be managed as normal chezmoi dotfiles (which always target `$HOME`). Instead:

- Their content is kept as plain reference copies in `.chezmoitemplates/wslconfig` and `.chezmoitemplates/windows-terminal-settings.json` (a directory chezmoi never applies to `$HOME`, same as `.chezmoiscripts/`).
- `run_onchange_before_05-wslconfig.sh.tmpl` and `run_onchange_before_06-windows-terminal-settings.sh.tmpl` are templated scripts that `{{ template "..." . }}`-embed that content and write it to the Windows-side path (resolved at runtime via `cmd.exe`/`wslpath`, since the Windows username isn't known in advance). Both no-op outside WSL.
- These are `run_onchange_`, not `run_once_`, on purpose: they only re-run when the *tracked template content* changes. Day-to-day tweaks made through the Windows Terminal UI are left alone and never silently overwritten by `chezmoi apply`. To pull a live change back into the repo, manually copy the real file's content over the one in `.chezmoitemplates/` and commit.
- Caveat: `defaultProfile` and per-profile `guid`s in the Windows Terminal settings are generated per-machine (e.g. per WSL distro instance) and will not match on a different machine. Restoring this file there may leave `defaultProfile` pointing at a nonexistent profile, which just needs picking again in Settings; nothing breaks.

`dot_config/herdr/config.toml` tracks only the user's keybindings. `~/.config/herdr/plugins.json` and `~/.config/herdr/plugins/` are deliberately left untracked (they're generated state: absolute paths baked in at install time, cloned plugin code). Since `config.toml` references a plugin action (`herdr-file-viewer.*`) that must actually be installed for the keybinding to do anything, `run_once_before_65-herdr.sh` also runs `herdr plugin install smarzban/herdr-file-viewer` after installing herdr itself.

`run_once_after_81-ccstatusline.sh` installs the `ccstatusline` npm package (Claude Code's HUD/statusline renderer) via `bun install -g`, resolving `bun` the same `command -v || fallback path` way as `mise`/`herdr`/`claude` elsewhere in this file — it must run `after` (numbered past `80-mise-install.sh`), since `bun` itself comes from `mise install` in that script. `dot_claude/settings.json` wires it up (`statusLine.command = "ccstatusline"`) and also carries the model default, enabled plugins, and TUI/theme prefs; `dot_config/ccstatusline/settings.json` is the HUD's own layout (which segments show, colors, separators) and is unrelated to `~/.claude/settings.json` beyond that one command reference.

`run_once_after_82-openspec.sh` installs `@fission-ai/openspec` (spec-driven planning CLI for AI coding assistants) via `npm install -g`, same `after`-80/`command -v || fallback` pattern as `ccstatusline`. Global npm packages resolve `npm` via the mise shim path (`~/.local/share/mise/shims/npm`), not the version-pinned `mise/installs/node/<version>/bin/npm`, so the fallback keeps working across node version bumps.

`run_once_after_83-claude-plugins.sh` closes a gap `dot_claude/settings.json`'s `enabledPlugins` block used to leave open: that block is only a *preference* (`"playwright@claude-plugins-official": true`), not an installer — Claude Code's actual plugin state (marketplace registration, downloaded plugin code) lives under `~/.claude/plugins/` (`known_marketplaces.json`, `installed_plugins.json`, `cache/`), which chezmoi never touches. Before this script existed, a fresh machine got the `true` flag written into `~/.claude/settings.json` but the plugins themselves were never installed or enabled, requiring a manual `claude plugin install`/`enable` per plugin. This script reads `enabledPlugins` from the already-applied `~/.claude/settings.json` (run_once_after scripts always run after dotfiles are written, so the file is guaranteed present) and, for each plugin declared `true`, installs it if `claude plugin list --json` doesn't know about it yet and enables it if it's installed-but-disabled. The marketplace itself (`claude-plugins-official`, hardcoded since it's the only one in use) is registered first via `claude plugin marketplace add anthropics/claude-plugins-official` if missing.

Two gotchas found via direct end-to-end testing (uninstalling a plugin, then re-running the script to simulate a fresh machine), not obvious from the CLI's `--help` output:
- `claude plugin install <id>` respects an existing `true` value for that plugin already in `enabledPlugins` and auto-enables it as part of install. Calling `claude plugin enable` again right after unconditionally fails (`"already enabled"`, non-zero exit, fatal under `set -e`). The script re-checks state after install instead of assuming still-disabled.
- Distinguishing "plugin not installed at all" from "installed but disabled" in the `claude plugin list --json` output needs an explicit `if (length==0) then "absent" ... end` in the `jq` filter — a bare `.enabled // "absent"` default only fires on `null`, and silently collapses "not in the list" and "installed with `enabled: false`" into the same falsy case in the opposite way (or worse, outputs empty string), because `select()` on no match produces no output for the fallback to attach to.

Depends on `jq` (added to `run_once_before_00-apt-packages.sh` for this).

`run_once_before_47-flutter.sh` clones the `stable` channel into `~/.flutter` (matches `dot_zshrc`'s existing `PATH` entry; kept as a plain git clone rather than switching to mise's `flutter`/`dart` plugins, to avoid touching an already-correct path).

`run_once_before_48-android-sdk.sh` is WSL-specific: provisions the Android SDK on the Windows host, matching `dot_zshrc`'s `ANDROID_HOME` (`/mnt/c/...`). Requires Android Studio already installed (`run_once_before_18-windows-apps.sh`, earlier by numeric order); uses its **bundled JBR** as `JAVA_HOME` to run `sdkmanager` instead of needing a separate Windows-side JDK. Downloads the SDK command-line tools from `dl.google.com` (version-pinned; Google has no stable "latest" URL, so bump the build number if it's ever pulled), accepts licenses non-interactively, installs `platform-tools`, `build-tools;36.1.0` (matches `dot_zshrc`'s `PATH`), `platforms;android-35`, and `emulator`. Skips NDK/CMake/system-images on purpose (large, specialized, add via Android Studio's own SDK Manager on demand).

Gotcha: `sdkmanager.bat` runs via `cmd.exe`, which always warns "UNC paths are not supported" on stderr (we're invoked from a `\\wsl.localhost\...` cwd). With `$ErrorActionPreference = "Stop"` (used elsewhere in this file) that warning becomes a script-terminating error before redirection can suppress it, so this script locally relaxes it to `"Continue"` around just the `sdkmanager` calls. Second gotcha (found via a real `chezmoi apply` failing with "exit status 1" even though the install had actually succeeded): the same cmd.exe wrapper can also return a non-zero process exit code on a cosmetically-successful run, which would otherwise kill the whole script under `set -e`. Since every real failure path already exits earlier via `"Stop"`, the script forces `exit 0` at the very end rather than trusting `sdkmanager.bat`'s own exit code.

Deliberately not scripted: a few personal/uncommon CLIs (kimi-code, opencode, craude, patrol_cli) whose install methods aren't well-known enough to script reliably. Install those manually if a new machine needs them.

## Account setup (`run_once_after_95-account-setup.sh`)

SSH keys, GitHub auth, and Claude Code auth are the one part of provisioning that can't be silently scripted. They need a human to click through browser OAuth / device-code flows. Rather than skip them, this script runs last (after everything else, so it reads as "you're basically done, now finish these") and does each step interactively against the real TTY running `chezmoi apply`:

1. Generates `~/.ssh/id_ed25519` if missing, with **no passphrase**, so it doesn't block automation on a prompt. This is a deliberate convenience/security trade-off (an unencrypted private key at rest); a fresh key per machine at least limits blast radius if one machine is compromised.
2. `gh auth login` if not already authenticated, then registers the new key with `gh ssh-key add`.
3. `glab auth login` if not already authenticated (no SSH key registration step for this one, not added yet). Gotcha: `glab auth status` always exits `0`, even when not authenticated at all (it only reports problems in its text output), so this step checks for the literal `"Logged in to"` success line instead of trusting the exit code, unlike `gh`'s check just above it. Found by actually observing `glab` silently skip login on a genuinely unauthenticated host.
4. `claude auth login` if not already authenticated.

`dot_local/bin/executable_wsl-browser` opens a URL on the Windows side via `powershell.exe Start-Process`, reusing whatever's already logged in there (e.g. Edge), instead of a Linux-side browser. `wslu`/`wslview` was considered for this and rejected: its GitHub repo is archived as of 2025, so it's a dead dependency to lean on.

Two ways this is wired up, and only one of them is reliable:

- `BROWSER="wsl-browser"` in `dot_zshrc` covers tools that respect `$BROWSER` **and** run in a real interactive shell. It does *not* help inside `run_once_*` scripts, since chezmoi runs those without sourcing `dot_zshrc` (same lesson as the `claude` PATH gotcha above). `$BROWSER` is simply unset in that context.
- `run_once_after_85-default-browser.sh` registers `dot_local/share/applications/wsl-browser.desktop` as the default `x-scheme-handler/http(s)` via `xdg-mime`/`xdg-settings`. This is what actually matters: it's a persistent, machine-level default that `xdg-open` (and libraries that call it directly, like `gh`/`glab`'s OAuth flow, regardless of `$BROWSER`) picks up no matter which process or script invokes it. Found necessary after `$BROWSER` alone didn't stop `glab auth login` from opening a Linux-side Chrome that happened to already be `xdg-open`'s configured default on this machine. Runs after files are applied (`85` < `95`) so it's in place before `run_once_after_95-account-setup.sh`'s login steps.

SSH itself otherwise stays entirely out of this repo; see Security below.

Gotcha (found via a real `chezmoi apply`, not just direct `bash script.sh` testing): `chezmoi` runs each script in its own shell without `dot_zshrc`/`dot_profile` sourced, so tools installed to `~/.local/bin` (like `claude`, installed by `run_once_before_70-claude-code.sh`) aren't necessarily on `PATH` here even though they work fine in a normal interactive shell. This script resolves `claude` via `command -v claude || echo "$HOME/.local/bin/claude"` rather than calling it bare, the same pattern already used for `mise`/`herdr` elsewhere in this file. If a new tool is added to this script, resolve its path the same way instead of assuming it is on `PATH`.

## Bootstrap entry points (`setup.sh`, `setup.ps1`)

One command per OS, both `.chezmoiignore`d (repo root, tooling, not dotfiles), each doing whatever the machine actually needs rather than making the user choose between "first time" and "update" variants:

- **`setup.sh`** (Linux/WSL): installs chezmoi if missing, then checks whether chezmoi's source dir already has a `.git` (via `chezmoi source-path`) to decide `chezmoi update` vs `chezmoi init --apply hiukky`. This is also what fixed a real bug: before this script existed, re-running the old raw `chezmoi init` one-liner on a machine that already had it initialized didn't reliably pull the latest commit.
- **`setup.ps1`** (Windows, works even with no WSL yet): self-elevates via `Start-Process -Verb RunAs` if not already admin, runs `wsl --install -d Ubuntu` if Ubuntu isn't already listed in `wsl -l -q` (idempotent), then chains into `wsl -d Ubuntu -- sh -c '$(curl -fsLS .../setup.sh)'`, i.e. it delegates to `setup.sh` rather than duplicating its logic.

Two things in `setup.ps1` are deliberately left as manual, unavoidable interruptions rather than something scripted around:

- **A possible restart.** If this is the machine's first time enabling WSL/virtualization Windows features, `wsl --install` may require a restart before the distro can actually run. There's no reliable way to survive a mandatory OS restart mid-script (a scheduled-task/RunOnce auto-resume was considered and rejected as unnecessary complexity/fragility for a one-time setup step). The script just tells the user to restart and re-run the same command, which then no-ops the already-done parts.
- **Linux username/password creation.** WSL requires this on a distro's first launch and provides no way to skip it. This is intentionally different from `dotfiles-test`'s throwaway `tester`/`tester` account (see below). A real environment's login shouldn't be auto-generated or hardcoded, so this step stays interactive on purpose.

Gotcha, same class as the `sdkmanager.bat` one above: `wsl.exe -l -q` writes to stderr when WSL isn't installed at all ("The Windows Subsystem for Linux is not installed..."). With `$ErrorActionPreference = "Stop"` that becomes a terminating error before `2>$null` can suppress it, so the WSL-detection line in `setup.ps1` locally relaxes it to `"Continue"` and restores `"Stop"` right after. Found by actually running this script against a genuinely fresh Windows 11 Pro VM with no WSL yet.

**Real incident worth knowing about:** running `chezmoi init` on this machine (via an earlier, non-smart version of this bootstrap flow) silently rewrote `~/.config/chezmoi/chezmoi.toml` from `.chezmoi.toml.tmpl`, which only defines `[data]`, not `sourceDir`. That wiped the `sourceDir = "/home/hiukky/dotfiles"` line documented at the top of this file, causing chezmoi to fall back to its default location and clone a second, divergent copy of this repo at `~/.local/share/chezmoi`. Fixed by manually restoring the `sourceDir` line. `setup.sh`'s update-vs-init detection reads `chezmoi source-path` *before* deciding, so as long as that line stays correct, future runs on this machine will correctly resolve to `chezmoi update` against `~/dotfiles` and never hit `chezmoi init` (and this rewrite) again. If `~/.config/chezmoi/chezmoi.toml` on this machine is ever missing the `sourceDir` line, that's why, and the fix is to add it back.

**Short URLs (`hiukky.com`):** `README.md`, `setup.ps1`, and `setup.sh` all reference `https://hiukky.com/setup.sh` and `.../setup.ps1` instead of the long `raw.githubusercontent.com` URLs. The `rewrites` that proxy those two paths straight to the corresponding `raw.githubusercontent.com` files now live in `vercel.json` in the `hiukky/hiukky` repo (the main portfolio site's Vercel project), not in this repo — this repo no longer has its own `vercel.json` or Vercel deployment. This used to run on a dedicated `get.hiukky.com` subdomain/project specifically to avoid touching the main site's config; that's no longer a concern, so the short URLs were consolidated onto the apex domain. `hiukky.com`'s DNS is managed by Vercel (`ns1`/`ns2.vercel-dns.com`), with a legacy Route53 zone also still resolvable for it, a leftover from a prior DNS provider — worth knowing if DNS for this domain ever needs touching, since a stale Route53 record silently shadowing the Vercel one is a real thing that happened here.

Quoting gotcha if this script is ever edited: `'$(curl -fsLS get.chezmoi.io)'` must stay **single-quoted** in the `.ps1` file. PowerShell only expands `$(...)` inside double-quoted strings or bare expressions. Inside single quotes it's passed through as a literal string, which is what lets the *Linux* `sh` (not PowerShell) perform that command substitution once it reaches WSL. Verified by hand before writing this file; don't "simplify" the quoting without re-testing (`wsl -d Ubuntu -- sh -c 'echo $(hostname)'` is a safe way to re-check it).

## Security

This repo is **public** on GitHub. Nothing added here is private, including full git history. Anything committed is effectively permanent and world-readable (rewriting history after the fact doesn't reliably scrub caches/forks/clones).

Rules for adding new files or editing existing ones:

- **Never commit live credentials.** Before `chezmoi add`-ing anything from `$HOME` (or pasting content into a tracked file), check it for tokens/keys/passwords first. `chezmoi add` copies file content verbatim with zero awareness of what's sensitive.
- Already confirmed excluded and must stay excluded: `~/.npmrc` (has an npm `_authToken`), `~/.config/gh/hosts.yml` (has a GitHub `oauth_token`), anything under `~/.ssh/` or `~/.gnupg/` (private keys), shell history files.
- If a secret must be referenced (e.g. a script needs an API key), use an environment variable read at runtime or a template that pulls from a local, gitignored file. Never inline the value.
- The install scripts under `.chezmoiscripts/` run automatically and unattended during `chezmoi apply`; only pipe `curl | sh`/`curl | bash` from a tool's own official install domain (as the existing scripts do: `get.chezmoi.io`, `starship.rs`, `mise.run`, `get.docker.com`, `claude.ai`, `herdr.dev`, `get.scoop.sh`, plus binary/installer downloads straight from `dl.k8s.io`/`kind.sigs.k8s.io`/GitHub releases for `kubectl`/`kind`/`nvim`). Don't add a new one without being sure of the source.
- Full git history (including the pre-chezmoi `legacy-2026-08-09` era) was scanned on 2026-08-09 for known secret patterns (API tokens, private key headers, AWS keys, etc.); clean. Re-run a similar scan (`git grep` over `git rev-list --all`) before making history public again after any future rewrite.

## History note

This repo's git history predates the chezmoi setup (old shell-script-based dotfiles). The pre-chezmoi state is also tagged at `legacy-2026-08-09` for reference.
