# Development

Requires the full Xcode application, including its macOS SDK and build tools.
Command Line Tools alone cannot build this storyboard-based project.

After installing Xcode, open it once to complete its initial setup, then select
its developer directory so both `xcodebuild` and the SwiftLint build plugin can
find its toolchain:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

```sh
git clone https://github.com/flowrange/dmenu-mac.git
cd dmenu-mac
git remote add upstream https://github.com/oNaiPs/dmenu-mac.git
git fetch upstream
```

```sh
xcodebuild -skipPackagePluginValidation -skipMacroValidation \
  -project dmenu-mac.xcodeproj -scheme dmenu-mac -configuration Debug build

xcodebuild -skipPackagePluginValidation -skipMacroValidation \
  -project dmenu-mac.xcodeproj -scheme dmenu-mac -configuration Debug test
# single test: add -only-testing:dmenu-macTests/SearchServiceTests[/testName]

swiftlint --strict   # CI fails on warnings
```

`-skipPackagePluginValidation` is required because SwiftLint runs as an Xcode build plugin.
If `swiftlint` is not on your PATH, use the plugin's bundled macOS executable at
`<project DerivedData>/SourcePackages/artifacts/swiftlintplugins/SwiftLintBinary/SwiftLintBinary.artifactbundle/macos/swiftlint`
with `--strict` after Xcode has resolved the packages.

Building or testing does not update the installed app. To use a new build from
macOS Apps or Spotlight, quit dmenu-mac from its menu bar menu and replace
`dmenu-mac.app` in `~/Applications` with the newly built bundle, then reopen it.
Settings are preserved. The build is in the project's DerivedData directory under
`Build/Products/Debug/dmenu-mac.app`. Adding `-derivedDataPath build` to the build
command gives it the predictable path `build/Build/Products/Debug/dmenu-mac.app`.

For window layout changes, run `SearchWindowTests`, `ResultsViewTests`,
`SearchViewControllerCommandTests`, the appearance and screen-selection tests
along with the full suite. Manually check **Settings → Appearance**:
Top/Center/Bottom, Full width and a custom width, smaller and offset displays,
and a side Dock. Check that relaunch preserves the settings and Reset to
Defaults restores Top, Full width and the 900-point custom width. The command
line `--bottom` and `--monitor` overrides, horizontal navigation and stdin mode
should continue to work. For Vertical results, check 3/10/20 rows, a large font,
icons, long labels, no matches and a short result list. Check Up/Down and
Tab/Shift+Tab wrapping, Left/Right query editing, selection visibility after
scrolling or resizing, and switching back to Horizontal. The vertical window
keeps its height while filtering and fits within the available screen height;
Reset to Defaults restores Horizontal and 10 rows. Appearance has a 600-point
scrolling viewport so all controls remain reachable on shorter displays.

For **Show icons**, check both layouts with apps, settings panes and commands
mixed together, plus stdin choices and no matches. With **Align result names** on,
items without icons must keep an empty icon slot and vertical labels must align;
turn it off to remove only the empty slots. Both controls must update results
immediately. Alignment is disabled in Settings when icons are off. Check larger
fonts, long labels, scrolling and persistence after relaunch. Reset to Defaults
turns icons off, enables alignment and removes the reserved space.

For background changes, toggle **Blur background** over a window with detailed
content in both results layouts. Check that text, icons and selection stay sharp,
the effect fills the launcher after resizing, and **Window background** plus
**Tint opacity** tint the blur (100% covers it). Disabling blur restores plain
transparency. Check light/dark appearance, **Reduce transparency** in macOS
Accessibility settings, persistence after relaunch and Reset to Defaults (blur
off). Color updates must apply only to the launcher, including while Settings
or the font panel is open.

Releases are cut with `scripts/release.sh`, see [RELEASING.md](../RELEASING.md).
