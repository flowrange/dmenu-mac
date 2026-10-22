# dmenu-mac — personal fork

A personal fork of [dmenu-mac](https://github.com/oNaiPs/dmenu-mac), the
keyboard-driven macOS launcher by [oNaiPs](https://github.com/oNaiPs).

## What changed

Based on upstream **0.9.0**, this fork adds a **Center** window position and a
custom width in **Settings → Appearance**. Disable **Full width** to adjust the
width from 300 to 3,000 points (initially 900). The window is centered horizontally
within the selected screen's usable area, avoiding a side Dock and shrinking to
fit smaller screens. Custom width works with Top, Center and Bottom positions.

Top and Full width remain the defaults. Appearance settings persist and can be
reset with **Reset to Defaults**.

No fork binaries have been released. Homebrew and Nix install the upstream app.

See the [upstream README](https://github.com/oNaiPs/dmenu-mac#readme) for usage
and [development notes](docs/development.md) for building and testing this fork.

## Credits

- [oNaiPs](https://github.com/oNaiPs) and the upstream contributors: original application.
- [flowrange](https://github.com/flowrange): fork and validation on macOS.
- [Codex](https://github.com/openai/codex): development assistance.

[GPL-3.0](LICENSE). Original copyright notices are retained.
