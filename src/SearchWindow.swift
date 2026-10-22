/*
 * Copyright (c) 2016 Jose Pereira <onaips@gmail.com>.
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

/// Takes keyboard input without activating the app, so the previous app stays frontmost.
class SearchWindow: NSPanel {

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask,
                  backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style.union(.nonactivatingPanel),
                   backing: backingStoreType, defer: flag)
    }

    override func awakeFromNib() {
        self.hasShadow = false
        self.hidesOnDeactivate = false
        self.collectionBehavior = NSWindow.CollectionBehavior.canJoinAllSpaces
        // Stay above a Dock on the side, which the full-width bar overlaps, but below the
        // menu bar. The bar is placed between the menu bar and a bottom Dock (see barArea).
        self.level = NSWindow.Level(rawValue: NSWindow.Level.dock.rawValue + 1)
        updatePosition()
    }

    /**
     * Updates search window position. `monitor` is a screen index that overrides `screen` when valid.
     */
    func updatePosition(_ position: WindowPosition = AppearanceManager.shared.windowPosition,
                        screen selection: ScreenSelection = AppearanceManager.shared.screenSelection,
                        monitor: Int? = nil) {
        guard let screen = ScreenPicker.pick(from: NSScreen.screens, selection: selection, monitor: monitor,
                                             context: .current(), fallback: NSScreen.main) else { return }

        let appearance = AppearanceManager.shared
        let area = Self.barArea(of: screen, fullWidth: appearance.usesFullWidth)
        let width = appearance.usesFullWidth ? nil : appearance.windowWidth
        let height = appearance.resultsLayout == .vertical ?
            appearance.resultRowHeight * CGFloat(appearance.visibleRows + 1) : 31
        let frame = Self.frame(for: position, in: area, width: width, height: height)
        setFrame(frame, display: false)
    }

    /**
     * The screen's full width, between the menu bar and a bottom Dock. A Dock on the side
     * doesn't narrow the full-width bar, since the window level keeps it above the Dock.
     * A custom-width window stays within the visible frame, including beside a side Dock.
     */
    static func barArea(of screen: ScreenDescribing, fullWidth: Bool = true) -> NSRect {
        let visible = screen.visibleFrame
        guard fullWidth else { return visible }
        return NSRect(x: screen.frame.minX, y: visible.minY, width: screen.frame.width, height: visible.height)
    }

    /**
     * Horizontally centered frame, limited to the available area. A nil width fills it.
     */
    static func frame(for position: WindowPosition, in screenFrame: NSRect,
                      width: CGFloat? = nil, height: CGFloat) -> NSRect {
        let width = min(width ?? screenFrame.width, screenFrame.width)
        let height = min(height, screenFrame.height)
        let originY: CGFloat
        switch position {
        case .top:
            originY = screenFrame.maxY - height
        case .center:
            originY = screenFrame.midY - height / 2
        case .bottom:
            originY = screenFrame.minY
        }

        return NSRect(x: screenFrame.midX - width / 2, y: originY, width: width, height: height)
    }

    // The app has no main menu (LSUIElement), so handle Cmd-, here to open Settings.
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
           event.charactersIgnoringModifiers == "," {
            return NSApp.sendAction(#selector(AppDelegate.openSettings), to: nil, from: self)
        }
        return super.performKeyEquivalent(with: event)
    }

    // Replaces hidesOnDeactivate, since the app never activates.
    override func resignKey() {
        super.resignKey()
        orderOut(nil)
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return false
    }
}
