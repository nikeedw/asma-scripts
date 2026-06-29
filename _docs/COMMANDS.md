# `god` Command Reference

Detailed reference for the `god` helper command available in fish and zsh.

## Overview

`god` wraps common Git, GitHub CLI, and ASMA CLI actions into short workflow commands.

Supported shells:

| Shell | Command file | Completion file |
| --- | --- | --- |
| fish | `fish/god.fish` | `fish/god.completions.fish` |
| zsh | `zsh/god.zsh` | `zsh/_god` |

## Usage

```sh
god push [extra args]
god pull [--master] [--recursive] [extra args]
god commit [--from <ASMA-number|number>] [--release] [--no-verify] [extra args]
god pr --from <ASMA-number|number>
god pr <ASMA-number|number>
god pr --open
god branch --from <ASMA-number|number>
god branch <ASMA-number|number>
god start
god help
```

## Commands

### `god push`

Runs `git push` with any extra arguments passed through.

```sh
god push
god push origin HEAD
```

### `god pull`

Runs `git pull` with any extra arguments passed through.

```sh
god pull
god pull --rebase
```

Special flags:

| Command | Runs |
| --- | --- |
| `god pull --master` | `git pull origin master` |
| `god pull --recursive` | `asma git pull` |

Extra arguments are preserved after removing the `god`-specific flag.

### `god commit`

Runs an AI-assisted ASMA commit that includes unstaged and untracked files.

```sh
god commit
```

Default behavior:

```text
asma git commit --auto-provider ai --include-unstaged --include-untracked
```

On `master`, `god commit` also adds:

```text
--skip-jira-key --allow-protected-push
```

If a merge is in progress, `god commit` runs:

```text
git commit --no-edit
```

#### `god commit --from <ticket>`

Creates an AI commit, then amends the latest commit subject to include the Jira ticket.

```sh
god commit --from ASMA-123
god commit --from 123
```

Both forms are accepted. Numeric ticket IDs are expanded to `ASMA-<number>`.

If the generated commit subject uses a conventional commit prefix, the ticket is inserted after the prefix:

```text
feat: add helper
feat: ASMA-123 add helper
```

Otherwise the ticket is prepended:

```text
add helper
ASMA-123 add helper
```

Commit bodies are preserved by `bin/god-amend-from-task`.

#### `god commit --release`

Adds `--force-release` to the ASMA commit flow.

```sh
god commit --release
god commit --from 123 --release
```

#### `god commit --no-verify`

Sets `LEFTHOOK=0` while committing.

```sh
god commit --no-verify
god commit --from 123 --no-verify
```

This is used because `asma git commit` does not pass `--no-verify` directly through to Git.

### `god pr`

Creates or opens pull requests for the current branch workflow.

#### `god pr --from <ticket>`

Creates a branch from a Jira ticket, commits changes, pushes the branch, creates a PR, and opens it in the browser.

```sh
god pr --from ASMA-123
god pr --from 123
```

Runs:

```text
asma git branch create --from ASMA-123
asma git commit --auto-provider ai --include-untracked --include-unstaged --push --create-pr
gh pr view --web
```

#### `god pr <ticket>`

Short form of `god pr --from <ticket>`.

```sh
god pr 123
```

#### `god pr --open`

Opens the current branch PR in the browser.

If no PR exists, it creates one using `gh pr create --fill`, then opens it.

```sh
god pr --open
```

### `god branch`

Creates a branch from a Jira ticket through the ASMA CLI.

```sh
god branch --from ASMA-123
god branch --from 123
god branch 123
```

Runs:

```text
asma git branch create --from ASMA-123
```

### `god start`

Opens the ASMA modules workspace in VS Code / Cursor.

```sh
god start
```

Runs:

```text
cd ~/asma/asma-modules && code .
```

### `god help`

Prints usage and command summaries.

```sh
god help
god --help
god -h
```

## Ticket Format

Commands that accept Jira tickets support both full and short forms:

```text
ASMA-123
123
```

Short numeric ticket IDs are automatically expanded to `ASMA-<number>`.

## Completions

Fish and zsh completions include:

- `god` subcommands.
- `pull` flags: `--master`, `--recursive`.
- `commit` flags: `--from`, `--release`.
- `pr` flags: `--from`, `--open`.
- `branch` flag: `--from`.
- Jira ticket suggestions after `--from`, delegated to ASMA completion behavior.

## Shortcuts

Available in both fish and zsh:

| Shortcut | Expands to |
| --- | --- |
| `pdev` | `pnpm dev` |
| `padd` | `pnpm add` |
| `prem` | `pnpm remove` |
| `mkcd <dir>` | `mkdir -p <dir> && cd <dir>` |
