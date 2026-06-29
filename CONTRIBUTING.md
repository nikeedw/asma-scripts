# Contributing

Thanks for helping improve these scripts.

## Guidelines

- Keep changes focused and easy to review.
- Preserve behavior parity between fish and zsh when a command exists in both shells.
- Prefer clear shell code over clever one-liners.
- Avoid adding project-specific secrets, tokens, hostnames, or credentials.
- Update `README.md` when command behavior, aliases, or installation steps change.

## Testing

Before opening a pull request, test the affected shell manually:

```sh
god help
god pull --help
god commit --help
```

For completion changes, reload completions and verify that tab completion still works in the target shell.

## Pull Requests

Include a short summary of what changed and how you tested it.
