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

Releases are cut with `scripts/release.sh`, see [RELEASING.md](../RELEASING.md).
