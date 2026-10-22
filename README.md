# dmenu-mac — personal fork

A personal fork of [dmenu-mac](https://github.com/oNaiPs/dmenu-mac), the
keyboard-driven macOS launcher by [oNaiPs](https://github.com/oNaiPs).

## What changed

Based on upstream **0.9.0**, this fork adds a **Center** window position,
adjustable width and an optional vertical results list.

To use a compact, centered launcher:

1. Open the launcher and press **⌘,** to open **Settings → Appearance**.
2. Set **Position** to **Center** and turn off **Full width**.
3. Adjust **Width**: initially **900 points**, from 300 to 3,000 in 10-point steps.

Custom width also works with **Top** and **Bottom**. The window is centered
horizontally within the selected screen's usable area, avoiding a side Dock and
shrinking to fit smaller screens. Results remain horizontal, with the selected
item kept visible when the window narrows.

For a vertical list, set **Results** to **Vertical** in **Settings → Appearance**.
The search field sits above **10 visible rows** by default, adjustable from 3 to
20. **↑/↓** or **Tab/Shift+Tab** select results and wrap at either end;
**←/→** edit the query. The list scrolls to keep the selection visible. Its height
stays fixed while searching, grows with the font and is limited to the available
screen height. Position and width controls work in both layouts.

Top, Full width and Horizontal remain the defaults. Appearance settings persist;
**Reset to Defaults** also restores the vertical row count to 10.

No fork binaries have been released. Homebrew and Nix install the upstream app;
build this fork from source to use these controls.

See the [upstream README](https://github.com/oNaiPs/dmenu-mac#readme) for usage
and [development notes](docs/development.md) for building and testing this fork.

## Credits

- [oNaiPs](https://github.com/oNaiPs) and the upstream contributors: original application.
- [flowrange](https://github.com/flowrange): fork and validation on macOS.
- [Codex](https://github.com/openai/codex): development assistance.

[GPL-3.0](LICENSE). Original copyright notices are retained.
