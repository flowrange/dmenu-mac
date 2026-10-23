import XCTest
import SwiftUI
@testable import dmenu_mac

final class AppearanceSettingsModelTests: XCTestCase {
    var model: AppearanceSettingsModel!
    private var snapshot: AppearanceDefaultsSnapshot!

    override func setUp() {
        super.setUp()
        snapshot = AppearanceDefaultsSnapshot()
        AppearanceDefaultsSnapshot.clear()
        model = AppearanceSettingsModel()
    }

    override func tearDown() {
        model = nil
        snapshot.restore()
        super.tearDown()
    }

    // MARK: - Ranges

    func testControlRangesMatchPreviousLimits() {
        XCTAssertEqual(AppearanceSettingsModel.opacityRange, 0.2...1.0)
        XCTAssertEqual(AppearanceSettingsModel.fontSizeRange, 8...72)
        XCTAssertEqual(AppearanceSettingsModel.windowWidthRange, 300...3000)
    }

    // MARK: - Reflecting stored settings

    func testModelReflectsStoredSettings() {
        let manager = AppearanceManager.shared
        manager.windowOpacity = 0.75
        manager.fontSize = 18
        manager.windowPosition = .bottom
        manager.usesFullWidth = false
        manager.windowWidth = 1200

        XCTAssertEqual(model.windowOpacity, 0.75, accuracy: 0.0001)
        XCTAssertEqual(model.opacityText, "75%")
        XCTAssertEqual(model.fontSize, 18, accuracy: 0.0001)
        XCTAssertEqual(model.fontSizeText, "18 pt")
        XCTAssertEqual(model.windowPosition, .bottom)
        XCTAssertFalse(model.usesFullWidth)
        XCTAssertEqual(model.windowWidth, 1200)
        XCTAssertEqual(model.windowWidthText, "1200 pt")
    }

    func testOpacityTextRoundsInsteadOfTruncating() {
        AppearanceManager.shared.windowOpacity = 0.29
        XCTAssertEqual(model.opacityText, "29%")
    }

    func testFontDisplayNameFallsBackToSystemFont() {
        XCTAssertEqual(model.fontDisplayName, NSFont.systemFont(ofSize: 13).displayName)
    }

    // MARK: - Writing settings

    func testBackgroundBlurPersistsNotifiesAndResets() {
        XCTAssertFalse(model.blurBackground)

        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.blurBackground = true
        wait(for: [notified], timeout: 1.0)
        XCTAssertTrue(AppearanceManager().blurBackground)

        let other = AppearanceSettingsModel(manager: AppearanceManager())
        XCTAssertTrue(other.blurBackground)
        other.blurBackground = false
        XCTAssertFalse(model.blurBackground)

        model.blurBackground = true
        model.resetToDefaults()
        XCTAssertFalse(AppearanceManager().blurBackground)
    }

    func testResultsLayoutAndVisibleRowsPersistAndReset() {
        XCTAssertEqual(model.resultsLayout, .horizontal)
        XCTAssertEqual(model.visibleRows, 10)

        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.resultsLayout = .vertical
        wait(for: [notified], timeout: 1.0)
        model.visibleRows = 15

        XCTAssertEqual(AppearanceManager().resultsLayout, .vertical)
        XCTAssertEqual(AppearanceManager().visibleRows, 15)

        model.resetToDefaults()
        XCTAssertEqual(model.resultsLayout, .horizontal)
        XCTAssertEqual(model.visibleRows, 10)
    }

    func testChangingPositionStoresItAndNotifies() {
        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.windowPosition = .center
        wait(for: [notified], timeout: 1.0)

        XCTAssertEqual(AppearanceManager.shared.windowPosition, .center)
    }

    func testChangingWidthStoresItAndNotifies() {
        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.windowWidth = 1100
        wait(for: [notified], timeout: 1.0)

        XCTAssertEqual(AppearanceManager().windowWidth, 1100)
        XCTAssertEqual(model.windowWidthText, "1100 pt")
    }

    func testTogglingFullWidthStoresItAndNotifies() {
        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.usesFullWidth = false
        wait(for: [notified], timeout: 1.0)

        XCTAssertFalse(AppearanceManager().usesFullWidth)
    }

    func testChangingScreenStoresItAndNotifies() {
        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.screenSelection = .primary
        wait(for: [notified], timeout: 1.0)

        XCTAssertEqual(AppearanceManager.shared.screenSelection, .primary)
    }

    func testChangingOpacityStoresItAndNotifies() {
        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.windowOpacity = 0.4
        wait(for: [notified], timeout: 1.0)

        XCTAssertEqual(AppearanceManager.shared.windowOpacity, 0.4, accuracy: 0.0001)
        XCTAssertEqual(model.opacityText, "40%")
    }

    func testChangingFontSizeStoresItAndNotifies() {
        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.fontSize = 21
        wait(for: [notified], timeout: 1.0)

        XCTAssertEqual(AppearanceManager.shared.fontSize, 21, accuracy: 0.0001)
        XCTAssertEqual(model.fontSizeText, "21 pt")
    }

    func testShowIconsIsOffByDefault() {
        XCTAssertFalse(model.showIcons)
    }

    func testTogglingResultNameAlignmentPersistsAndNotifies() {
        XCTAssertTrue(model.alignResultNames)
        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.alignResultNames = false
        wait(for: [notified], timeout: 1.0)

        XCTAssertFalse(AppearanceManager().alignResultNames)
        XCTAssertFalse(model.alignResultNames)
    }

    func testTogglingShowIconsStoresItAndNotifies() {
        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.showIcons = true
        wait(for: [notified], timeout: 1.0)

        XCTAssertTrue(AppearanceManager.shared.showIcons)
        XCTAssertTrue(model.showIcons)
    }

    func testTogglingShowIconsClearsIconCache() {
        let app = URL(fileURLWithPath: "/System/Applications/Calculator.app")
        _ = IconCache.shared.icon(for: app)
        XCTAssertTrue(IconCache.shared.isCached(app))

        model.showIcons = true

        XCTAssertFalse(IconCache.shared.isCached(app))
    }

    func testChangingColorPersistsAsArchivableColor() {
        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.searchTextColor = Color(red: 1, green: 0, blue: 0)
        wait(for: [notified], timeout: 1.0)

        // Read back through a fresh manager so the value must come from UserDefaults.
        let stored = AppearanceManager().searchTextColor.usingColorSpace(.sRGB)
        XCTAssertEqual(stored?.redComponent ?? 0, 1, accuracy: 0.01)
        XCTAssertEqual(stored?.greenComponent ?? 1, 0, accuracy: 0.01)
        XCTAssertEqual(stored?.blueComponent ?? 1, 0, accuracy: 0.01)
    }

    func testModelPublishesBeforeEachChange() {
        var published = 0
        let subscription = model.objectWillChange.sink { published += 1 }
        defer { subscription.cancel() }

        model.windowOpacity = 0.5
        model.fontSize = 14
        model.windowPosition = .bottom
        model.windowWidth = 1000
        model.usesFullWidth = false

        XCTAssertEqual(published, 5)
    }

    // MARK: - Reset

    func testResetToDefaultsRestoresValuesAndNotifies() {
        let manager = AppearanceManager.shared
        manager.windowOpacity = 0.3
        manager.fontSize = 40
        manager.windowPosition = .center
        manager.usesFullWidth = false
        manager.windowWidth = 1500
        manager.screenSelection = .mouse
        manager.showIcons = true
        manager.alignResultNames = false

        let notified = expectation(forNotification: .appearanceSettingsChanged, object: nil)
        model.resetToDefaults()
        wait(for: [notified], timeout: 1.0)

        XCTAssertFalse(model.showIcons)
        XCTAssertTrue(model.alignResultNames)

        XCTAssertEqual(manager.windowOpacity, 0.6, accuracy: 0.0001)
        XCTAssertEqual(model.opacityText, "60%")
        XCTAssertEqual(model.fontSizeText, "13 pt")
        XCTAssertEqual(model.windowPosition, .top)
        XCTAssertTrue(model.usesFullWidth)
        XCTAssertEqual(model.windowWidth, 900)
        XCTAssertEqual(model.screenSelection, .activeWindow)
    }

    // MARK: - Font panel

    func testChooseFontMakesModelTheFontManagerTarget() {
        model.chooseFont()
        defer { NSFontPanel.shared.orderOut(nil) }

        XCTAssertTrue(NSFontManager.shared.target === model)
    }

    func testDeallocatedModelClearsFontManagerTarget() {
        weak var weakModel: AppearanceSettingsModel?

        autoreleasepool {
            let model = AppearanceSettingsModel()
            weakModel = model
            NSFontManager.shared.target = model
        }

        XCTAssertNil(weakModel)
        XCTAssertNil(NSFontManager.shared.target)
    }
}
