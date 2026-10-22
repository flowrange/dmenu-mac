import XCTest
@testable import dmenu_mac

final class SearchWindowTests: XCTestCase {

    func testWindowIsAboveDock() {
        let window = SearchWindow()
        window.awakeFromNib()

        XCTAssertGreaterThan(window.level.rawValue, NSWindow.Level.dock.rawValue)
    }

    func testWindowIsBelowMenuBar() {
        let window = SearchWindow()
        window.awakeFromNib()

        XCTAssertLessThan(window.level.rawValue, NSWindow.Level.mainMenu.rawValue)
    }

    // MARK: - Focus

    func testWindowDoesNotActivateApp() {
        let window = SearchWindow()
        window.awakeFromNib()

        XCTAssertTrue(window.styleMask.contains(.nonactivatingPanel))
        XCTAssertTrue(window.canBecomeKey)
        XCTAssertFalse(window.canBecomeMain)
        XCTAssertFalse(window.hidesOnDeactivate)
    }

    func testWindowHidesWhenResigningKey() {
        let window = SearchWindow()
        window.awakeFromNib()
        window.orderFront(nil)
        XCTAssertTrue(window.isVisible)

        window.resignKey()

        XCTAssertFalse(window.isVisible)
    }

    // MARK: - Position

    // Offset origin, like a secondary display.
    private let screenFrame = NSRect(x: 1440, y: -200, width: 1920, height: 1080)

    func testTopFrameIsPinnedToTopEdge() {
        let frame = SearchWindow.frame(for: .top, in: screenFrame, height: 30)
        XCTAssertEqual(frame, NSRect(x: 1440, y: 850, width: 1920, height: 30))
    }

    func testBottomFrameIsPinnedToBottomEdge() {
        let frame = SearchWindow.frame(for: .bottom, in: screenFrame, height: 30)
        XCTAssertEqual(frame, NSRect(x: 1440, y: -200, width: 1920, height: 30))
    }

    func testCustomWidthIsCenteredHorizontallyAtEveryPosition() {
        let expectedY: [WindowPosition: CGFloat] = [.top: 850, .center: 325, .bottom: -200]
        for position in WindowPosition.allCases {
            let frame = SearchWindow.frame(for: position, in: screenFrame, width: 900, height: 30)
            XCTAssertEqual(frame, NSRect(x: 1950, y: expectedY[position]!, width: 900, height: 30))
        }
    }

    func testCenterPositionAlsoSupportsFullWidth() {
        let frame = SearchWindow.frame(for: .center, in: screenFrame, height: 30)
        XCTAssertEqual(frame, NSRect(x: 1440, y: 325, width: 1920, height: 30))
    }

    func testCustomFrameFitsSmallDisplayAboveOrLeftOfPrimary() {
        for area in [NSRect(x: -640, y: 0, width: 640, height: 400),
                     NSRect(x: 0, y: 1080, width: 250, height: 400)] {
            for position in WindowPosition.allCases {
                let frame = SearchWindow.frame(for: position, in: area, width: 900, height: 30)
                XCTAssertEqual(frame.width, area.width)
                XCTAssertEqual(frame.midX, area.midX)
                XCTAssertTrue(area.contains(frame))
            }
        }
    }

    func testOversizedHeightIsLimitedToAvailableArea() {
        let area = NSRect(x: -640, y: 1080, width: 640, height: 20)
        for position in WindowPosition.allCases {
            XCTAssertEqual(SearchWindow.frame(for: position, in: area, width: 900, height: 30), area)
        }
    }

    func testCustomWidthAvoidsSideDockAndMenuBar() {
        struct Screen: ScreenDescribing {
            let frame = NSRect(x: 1440, y: -200, width: 1920, height: 1080)
            let visibleFrame: NSRect
        }
        let areas = [NSRect(x: 1520, y: -200, width: 1840, height: 1055),
                     NSRect(x: 1440, y: -200, width: 1840, height: 1055)]
        for visible in areas {
            let area = SearchWindow.barArea(of: Screen(visibleFrame: visible), fullWidth: false)
            XCTAssertEqual(area, visible)
            for position in WindowPosition.allCases {
                let frame = SearchWindow.frame(for: position, in: area, width: 900, height: 30)
                XCTAssertEqual(frame.midX, visible.midX)
                XCTAssertTrue(visible.contains(frame))
            }
        }
    }

    func testWidthSettingsResizeStoryboardContentAndKeepResultsVisible() throws {
        let screen = try XCTUnwrap(NSScreen.screens.first)
        let snapshot = AppearanceDefaultsSnapshot()
        defer { snapshot.restore() }
        AppearanceDefaultsSnapshot.clear()
        let manager = AppearanceManager.shared
        manager.usesFullWidth = false
        manager.windowPosition = .center

        let storyboard = NSStoryboard(name: "Main", bundle: Bundle(for: SearchViewController.self))
        let controller = try XCTUnwrap(storyboard.instantiateController(
            withIdentifier: "SearchViewController"
        ) as? SearchViewController)
        controller.listProvider = MockListProvider(items: (0..<30).map { ListItem(name: "A\($0)", data: nil) })
        controller.monitorOverride = 0
        let window = SearchWindow(contentRect: NSRect(x: 0, y: 0, width: 629, height: 31),
                                  styleMask: .borderless, backing: .buffered, defer: false)
        window.contentViewController = controller
        defer { window.orderOut(nil) }
        let scroll = try XCTUnwrap(controller.view.subviews.compactMap { $0 as? NSScrollView }.first)
        let results = try XCTUnwrap(scroll.documentView as? ResultsView)
        results.selectedIndex = results.list.count - 1

        for width: CGFloat in [900, 300, 3000] {
            manager.windowWidth = width
            controller.updatePosition()
            window.layoutIfNeeded()
            controller.view.layoutSubtreeIfNeeded()

            XCTAssertEqual(window.frame.width, min(width, screen.visibleFrame.width))
            XCTAssertEqual(window.frame.midX, screen.visibleFrame.midX)
            // NSWindow aligns the origin to whole points when the 31-point bar is centered.
            XCTAssertEqual(window.frame.midY, screen.visibleFrame.midY, accuracy: 0.5)
            XCTAssertGreaterThan(scroll.frame.width, 0)
            XCTAssertLessThanOrEqual(scroll.frame.maxX, controller.view.bounds.maxX)
            XCTAssertTrue(results.visibleRect.intersects(results.selectedRect),
                          "width \(width): scroll \(scroll.frame), document \(results.frame), " +
                          "visible \(results.visibleRect), selected \(results.selectedRect)")
        }

        manager.usesFullWidth = true
        controller.windowPositionOverride = .bottom
        controller.updatePosition()
        XCTAssertEqual(window.frame.width, screen.frame.width)
        XCTAssertEqual(window.frame.minX, screen.frame.minX)
        XCTAssertEqual(window.frame.minY, screen.visibleFrame.minY)
    }

    func testBarAreaKeepsFullWidthButSkipsMenuBarAndBottomDock() {
        struct Screen: ScreenDescribing {
            let frame = NSRect(x: 1440, y: -200, width: 1920, height: 1080)
            // Menu bar on top, Dock on the left and a bottom Dock inset.
            let visibleFrame = NSRect(x: 1520, y: -150, width: 1840, height: 995)
        }
        XCTAssertEqual(SearchWindow.barArea(of: Screen()), NSRect(x: 1440, y: -150, width: 1920, height: 995))
    }
}
