# ASMA Scripts

Personal shell scripts and configurations for ASMA development workflow.

## Structure

```
scripts/
├── fish/
│   ├── aliases.fish           # pnpm abbreviations + mkcd
│   ├── god.fish               # god command function for fish shell
│   └── god.completions.fish   # tab completions for god command
└── zsh/
    └── god.zsh                # god command + pnpm aliases + mkcd for zsh
```

## Installation

### Fish

```fish
# Copy function and aliases
cp fish/god.fish ~/.config/fish/functions/god.fish
cp fish/aliases.fish ~/.config/fish/conf.d/aliases.fish

# Copy completions
cp fish/god.completions.fish ~/.config/fish/completions/god.fish

# Reload
source ~/.config/fish/functions/god.fish
complete -e -c god
source ~/.config/fish/completions/god.fish
```

### Zsh

```zsh
# Source from ~/.zshrc
echo 'source ~/ASMA/scripts/zsh/god.zsh' >> ~/.zshrc
source ~/.zshrc
```

---

## `god` command reference

| Command                                    | Description                                                                                              |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| `god push`                                 | `git push`                                                                                               |
| `god pull`                                 | `asma git pull`                                                                                          |
| `god pull --master`                        | `git pull origin master`                                                                                 |
| `god commit`                               | AI-assisted commit (staged + unstaged)                                                                   |
| `god commit` _(on master)_                 | + `--skip-jira-key --allow-protected-push`                                                               |
| `god commit --from <ticket>` _(on master)_ | AI message, then amend to insert `ASMA-<ticket>` after conventional commit prefix (no `--skip-jira-key`) |
| `god commit --release`                     | Force release bump (master only)                                                                         |
| `god commit` _(while merging)_             | `git commit --no-edit`                                                                                   |
| `god pr --from <ticket>`                   | Create branch → commit → push → open PR                                                                  |
| `god pr --open`                            | Open existing PR in browser (creates one if missing)                                                     |
| `god branch --from <ticket>`               | Create branch from Jira ticket                                                                           |
| `god start`                                | `cd ~/asma/asma-modules && code .`                                                                       |

### Ticket format

Both `ASMA-123` and `123` are accepted — the `ASMA-` prefix is added automatically.

---

## Shortcuts

Available in both fish (`aliases.fish`) and zsh (`god.zsh`):

| Shortcut     | Expands to                   |
| ------------ | ---------------------------- |
| `pdev`       | `pnpm dev`                   |
| `padd`       | `pnpm add`                   |
| `prem`       | `pnpm remove`                |
| `mkcd <dir>` | `mkdir -p <dir> && cd <dir>` |
