# AGENTS.md

@README.md

The README describes fork differences. Build, test and lint commands are in `docs/development.md`; read it before building or testing. Update those documents when changing behavior or development workflows. Keep this file for agent-only notes.

## Gotchas

- Argument parsing is skipped under XCTest (`XCTestConfigurationFilePath`). Otherwise `parseOrExit()` kills the test runner.
- In tests, inject `MockListProvider` instead of touching the filesystem or stdin.
- Most bundles in `/System/Library/PreferencePanes` are empty stubs that System Settings maps by name. `AppListProvider.deadPreferencePanes` lists the ones that no longer map; to re-check, `open` each stub and read `tell application "System Settings" to get id of current pane` via osascript.

## Releases

- The process and the signing secrets are in `RELEASING.md`.
- The version lives only in `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` in `project.pbxproj`; `Info.plist` reads them. Never hardcode a version in the plist.
- `scripts/release.sh` is the only thing that should create version tags; the Release workflow refuses tags that don't match the project version.
- Hardened runtime is on. Anything new that needs an entitlement (Apple Events, etc.) goes in `src/dmenu-mac.entitlements`, or notarized builds break at runtime while Debug builds keep working.

## Git Commits

Use `flowrange` for public maintainer attribution in documentation and commit messages.

Use the repository's configured author (`flowrange`) for fork commits. For work
developed with Codex, include this trailer after a blank line in the commit body:

```
Co-authored-by: Codex <codex@openai.com>
```

## Agent skills

### Issue tracker

Local Markdown tickets and specs in the ignored `.scratch/` directory. Before reading or writing tickets, read `docs/agents/issue-tracker.md`.

### Triage labels

Five default triage states, recorded in local ticket metadata. Before triaging, read `docs/agents/triage-labels.md`.

### Domain docs

Single-context: root `GLOSSARY.md` and `docs/adr/`. Before exploring the codebase, read `docs/agents/domain.md`.
