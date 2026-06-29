# Security Policy

## Supported Versions

This repository contains personal workflow scripts. Security fixes are applied to the latest version on the default branch.

## Reporting a Vulnerability

Please do not open a public issue for sensitive security problems.

Report vulnerabilities privately to the repository owner with:

- A clear description of the issue.
- Steps to reproduce it.
- The affected script or command.
- Any relevant environment details.

## Scope

Security-sensitive areas include:

- Commands that run Git, GitHub CLI, or ASMA CLI actions.
- Handling of branch names, Jira ticket identifiers, and command arguments.
- Any change that could expose secrets or execute unintended shell commands.
