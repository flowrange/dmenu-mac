/*
 * Copyright (c) 2023 Jose Pereira <onaips@gmail.com>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import Cocoa

// MARK: - UserDefaults Keys
extension UserDefaults {
    enum AppearanceKeys {
        static let searchTextColor = "appearance.searchTextColor"
        static let resultsTextColor = "appearance.resultsTextColor"
        static let selectionHighlightColor = "appearance.selectionHighlightColor"
        static let windowBackgroundColor = "appearance.windowBackgroundColor"
        static let windowOpacity = "appearance.windowOpacity"
        static let fontName = "appearance.fontName"
        static let fontSize = "appearance.fontSize"
        static let windowPosition = "appearance.windowPosition"
        static let usesFullWidth = "appearance.usesFullWidth"
        static let windowWidth = "appearance.windowWidth"
        static let screenSelection = "appearance.screenSelection"
        static let showIcons = "appearance.showIcons"
    }
}

// MARK: - Window Position
enum WindowPosition: String, CaseIterable {
    case top
    case center
    case bottom

    var title: String {
        switch self {
        case .top: return "Top"
        case .center: return "Center"
        case .bottom: return "Bottom"
        }
    }
}

// MARK: - Appearance Manager
class AppearanceManager {
    static let shared = AppearanceManager()
    static let windowWidthRange: ClosedRange<Double> = 300...3000

    /// The app's defaults, or a throwaway suite under tests so they never touch the user's real settings.
    static let appDefaults: UserDefaults = {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil else { return .standard }
        let suite = "dmenu-mac.tests.appearance"
        UserDefaults().removePersistentDomain(forName: suite)
        return UserDefaults(suiteName: suite) ?? .standard
    }()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = AppearanceManager.appDefaults) {
        self.defaults = defaults
    }

    // MARK: - Default Values
    private struct Defaults {
        static let searchTextColor = NSColor.textColor
        static let resultsTextColor = NSColor.textColor
        static let selectionHighlightColor = NSColor.selectedTextBackgroundColor
        static let windowBackgroundColor = NSColor.windowBackgroundColor
        static let windowOpacity: CGFloat = 0.6
        static let fontName = "system"
        static let fontSize: CGFloat = 13.0
        static let windowPosition = WindowPosition.top
        static let usesFullWidth = true
        static let windowWidth: CGFloat = 900
        static let screenSelection = ScreenSelection.activeWindow
        static let showIcons = false
    }

    // MARK: - Color Properties
    var searchTextColor: NSColor {
        get { colorForKey(UserDefaults.AppearanceKeys.searchTextColor) ?? Defaults.searchTextColor }
        set { setColor(newValue, forKey: UserDefaults.AppearanceKeys.searchTextColor) }
    }

    var resultsTextColor: NSColor {
        get { colorForKey(UserDefaults.AppearanceKeys.resultsTextColor) ?? Defaults.resultsTextColor }
        set { setColor(newValue, forKey: UserDefaults.AppearanceKeys.resultsTextColor) }
    }

    var selectionHighlightColor: NSColor {
        get {
            colorForKey(UserDefaults.AppearanceKeys.selectionHighlightColor) ??
                Defaults.selectionHighlightColor
        }
        set { setColor(newValue, forKey: UserDefaults.AppearanceKeys.selectionHighlightColor) }
    }

    var windowBackgroundColor: NSColor {
        get {
            colorForKey(UserDefaults.AppearanceKeys.windowBackgroundColor) ??
                Defaults.windowBackgroundColor
        }
        set { setColor(newValue, forKey: UserDefaults.AppearanceKeys.windowBackgroundColor) }
    }

    var windowOpacity: CGFloat {
        get {
            if defaults.object(forKey: UserDefaults.AppearanceKeys.windowOpacity) != nil {
                return CGFloat(defaults.double(forKey: UserDefaults.AppearanceKeys.windowOpacity))
            }
            return Defaults.windowOpacity
        }
        set { defaults.set(Double(newValue), forKey: UserDefaults.AppearanceKeys.windowOpacity) }
    }

    // MARK: - Font Properties
    var fontName: String {
        get { defaults.string(forKey: UserDefaults.AppearanceKeys.fontName) ?? Defaults.fontName }
        set { defaults.set(newValue, forKey: UserDefaults.AppearanceKeys.fontName) }
    }

    var fontSize: CGFloat {
        get {
            if defaults.object(forKey: UserDefaults.AppearanceKeys.fontSize) != nil {
                return CGFloat(defaults.double(forKey: UserDefaults.AppearanceKeys.fontSize))
            }
            return Defaults.fontSize
        }
        set { defaults.set(Double(newValue), forKey: UserDefaults.AppearanceKeys.fontSize) }
    }

    var currentFont: NSFont {
        if fontName == "system" {
            return NSFont.systemFont(ofSize: fontSize)
        } else {
            return NSFont(name: fontName, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        }
    }

    // MARK: - Layout Properties
    var windowPosition: WindowPosition {
        get {
            defaults.string(forKey: UserDefaults.AppearanceKeys.windowPosition)
                .flatMap(WindowPosition.init(rawValue:)) ?? Defaults.windowPosition
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaults.AppearanceKeys.windowPosition) }
    }

    var usesFullWidth: Bool {
        get { defaults.object(forKey: UserDefaults.AppearanceKeys.usesFullWidth) as? Bool ?? Defaults.usesFullWidth }
        set { defaults.set(newValue, forKey: UserDefaults.AppearanceKeys.usesFullWidth) }
    }

    var windowWidth: CGFloat {
        get {
            let stored = defaults.object(forKey: UserDefaults.AppearanceKeys.windowWidth) as? NSNumber
            return Self.clampedWindowWidth(stored.map { CGFloat($0.doubleValue) } ?? Defaults.windowWidth)
        }
        set {
            defaults.set(Double(Self.clampedWindowWidth(newValue)), forKey: UserDefaults.AppearanceKeys.windowWidth)
        }
    }

    var screenSelection: ScreenSelection {
        get {
            defaults.string(forKey: UserDefaults.AppearanceKeys.screenSelection)
                .flatMap(ScreenSelection.init(rawValue:)) ?? Defaults.screenSelection
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaults.AppearanceKeys.screenSelection) }
    }

    var showIcons: Bool {
        get { defaults.object(forKey: UserDefaults.AppearanceKeys.showIcons) as? Bool ?? Defaults.showIcons }
        set { defaults.set(newValue, forKey: UserDefaults.AppearanceKeys.showIcons) }
    }

    // MARK: - Helper Methods
    private static func clampedWindowWidth(_ width: CGFloat) -> CGFloat {
        guard width.isFinite else { return Defaults.windowWidth }
        return min(max(width, CGFloat(windowWidthRange.lowerBound)), CGFloat(windowWidthRange.upperBound))
    }

    private func colorForKey(_ key: String) -> NSColor? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    }

    private func setColor(_ color: NSColor, forKey key: String) {
        if let data = try? NSKeyedArchiver.archivedData(
            withRootObject: color,
            requiringSecureCoding: false
        ) {
            defaults.set(data, forKey: key)
        }
    }

    func resetToDefaults() {
        searchTextColor = Defaults.searchTextColor
        resultsTextColor = Defaults.resultsTextColor
        selectionHighlightColor = Defaults.selectionHighlightColor
        windowBackgroundColor = Defaults.windowBackgroundColor
        windowOpacity = Defaults.windowOpacity
        fontName = Defaults.fontName
        fontSize = Defaults.fontSize
        windowPosition = Defaults.windowPosition
        usesFullWidth = Defaults.usesFullWidth
        windowWidth = Defaults.windowWidth
        screenSelection = Defaults.screenSelection
        showIcons = Defaults.showIcons
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let appearanceSettingsChanged = Notification.Name("appearanceSettingsChanged")
}
