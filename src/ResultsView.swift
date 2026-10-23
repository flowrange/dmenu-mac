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

/// Draws results as a horizontal row or a vertical list. Text is measured once per list/font change
/// (`layoutItems`), so `draw` only paints the items intersecting the dirty rect.
class ResultsView: NSView {
    let rectFillPadding: CGFloat = 5
    let itemSpacing: CGFloat = 10
    let iconSpacing: CGFloat = 4
    private let appearanceManager = AppearanceManager.shared
    private(set) var resultsList: [ListItem] = []

    /// Items actually drawn: the list, or a placeholder when empty.
    private var drawList: [ListItem] = []
    /// Measured text size and x offset for each entry of `drawList`.
    private var itemSizes: [NSSize] = []
    private var itemOffsets: [CGFloat] = []
    /// File whose icon precedes each item's text, when icons are on. Icons themselves are
    /// fetched lazily in `draw`, so only visible items ever hit `NSWorkspace`.
    private var itemIconURLs: [URL?] = []
    /// Square icon side, matching the text height; 0 when icons are off.
    private(set) var iconSide: CGFloat = 0

    override var isFlipped: Bool { true }

    private var isVertical: Bool { appearanceManager.resultsLayout == .vertical }
    private var rowHeight: CGFloat { appearanceManager.resultRowHeight }

    var selectedRect: NSRect {
        return highlightRect(at: selectedIndexValue)
    }

    var selectedIndexValue: Int = 0
    var selectedIndex: Int {
        get {
            return selectedIndexValue
        }
        set {
            if newValue < 0 || newValue >= resultsList.count || newValue == selectedIndexValue {
                return
            }

            let previous = selectedIndexValue
            selectedIndexValue = newValue
            setNeedsDisplay(highlightRect(at: previous))
            setNeedsDisplay(highlightRect(at: newValue))
            scrollToVisible(selectedRect)
        }
    }

    var list: [ListItem] {
        get {
            return resultsList
        }
        set {
            selectedIndexValue = 0
            resultsList = newValue
            layoutItems()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        layoutItems()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layoutItems()
    }

    func selectedItem() -> ListItem? {
        if selectedIndexValue < 0 || selectedIndexValue >= resultsList.count {
            return nil
        } else {
            return resultsList[selectedIndexValue]
        }
    }

    func clear() {
        list = []
    }

    /// Re-measures every item; call when the font or the icon setting changes.
    func invalidateLayout() {
        layoutItems()
    }

    private func iconColumnWidth(for url: URL?) -> CGFloat {
        guard iconSide > 0, appearanceManager.alignResultNames || url != nil else { return 0 }
        return iconSide + iconSpacing
    }

    private func layoutItems() {
        drawList = resultsList.isEmpty ? [ListItem(name: "No results", data: nil)] : resultsList
        let font = appearanceManager.currentFont
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let showIcons = appearanceManager.showIcons
        iconSide = showIcons ? ceil(font.ascender - font.descender) : 0

        itemSizes.removeAll(keepingCapacity: true)
        itemOffsets.removeAll(keepingCapacity: true)
        itemIconURLs.removeAll(keepingCapacity: true)
        itemSizes.reserveCapacity(drawList.count)
        itemOffsets.reserveCapacity(drawList.count)
        itemIconURLs.reserveCapacity(drawList.count)

        var textX = rectFillPadding
        for item in drawList {
            var size = (item.name as NSString).size(withAttributes: attributes)
            let iconURL = showIcons ? item.fileURL : nil
            size.width += iconColumnWidth(for: iconURL)
            size.height = max(size.height, iconSide)
            itemSizes.append(size)
            itemOffsets.append(textX)
            itemIconURLs.append(iconURL)
            textX += itemSpacing + size.width
        }

        // Trailing padding mirrors the leading one instead of leaving a full item gap.
        let viewport = enclosingScrollView?.contentSize ?? frame.size
        let size = isVertical ? NSSize(width: viewport.width, height: CGFloat(drawList.count) * rowHeight) :
            NSSize(width: textX - itemSpacing + rectFillPadding, height: viewport.height)
        setFrameSize(size)
        needsDisplay = true
        scrollToVisible(selectedRect)
    }

    /// Icon (if any) plus text of one item.
    private func contentRect(at index: Int) -> NSRect {
        let size = itemSizes[index]
        if isVertical {
            return NSRect(x: rectFillPadding, y: CGFloat(index) * rowHeight + (rowHeight - size.height) / 2,
                          width: max(0, bounds.width - 2 * rectFillPadding), height: size.height)
        }
        return NSRect(x: itemOffsets[index], y: (bounds.height - size.height) / 2,
                      width: size.width, height: size.height)
    }

    /// When alignment is on, leave an empty icon column for results without an icon.
    func textRect(at index: Int) -> NSRect {
        let content = contentRect(at: index)
        let inset = iconColumnWidth(for: itemIconURLs[index])
        return NSRect(x: content.minX + inset, y: content.minY,
                      width: max(0, content.width - inset), height: content.height)
    }

    private func highlightRect(at index: Int) -> NSRect {
        guard index >= 0, index < itemSizes.count else {
            return NSRect()
        }
        if isVertical {
            return NSRect(x: 0, y: CGFloat(index) * rowHeight, width: bounds.width, height: rowHeight)
        }
        return contentRect(at: index).insetBy(dx: -rectFillPadding, dy: -rectFillPadding)
    }

    /// Indices whose highlight overlaps `rect`; touching edges don't count.
    /// Vertical rows have a fixed height. Horizontal offsets use binary search followed
    /// by a scan that stops past the right edge.
    func visibleRange(in rect: NSRect) -> Range<Int> {
        if isVertical {
            guard rect.maxX > bounds.minX, rect.minX < bounds.maxX else { return 0..<0 }
            let start = min(itemSizes.count, max(0, Int(floor(rect.minY / rowHeight))))
            let end = min(itemSizes.count, max(start, Int(ceil(rect.maxY / rowHeight))))
            return start..<end
        }
        var low = 0
        var high = itemSizes.count
        while low < high {
            let mid = (low + high) / 2
            if highlightRect(at: mid).maxX <= rect.minX {
                low = mid + 1
            } else {
                high = mid
            }
        }

        var end = low
        while end < itemSizes.count && highlightRect(at: end).minX < rect.maxX {
            end += 1
        }
        return low ..< end
    }

    /// Text offsets are fractional, and an icon straddling device pixels gets resampled
    /// and looks soft, so snap it to the backing grid. Text keeps its subpixel position.
    func iconRect(at originX: CGFloat, originY: CGFloat? = nil) -> NSRect {
        let rect = NSRect(x: originX, y: originY ?? (bounds.height - iconSide) / 2, width: iconSide, height: iconSide)
        return backingAlignedRect(rect, options: .alignAllEdgesNearest)
    }

    override func draw(_ dirtyRect: NSRect) {
        var textAttributes: [NSAttributedString.Key: Any] = [
            .font: appearanceManager.currentFont,
            .foregroundColor: appearanceManager.resultsTextColor
        ]
        if isVertical {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byTruncatingTail
            textAttributes[.paragraphStyle] = paragraph
        }

        NSGraphicsContext.current?.imageInterpolation = .high

        for i in visibleRange(in: dirtyRect) {
            if selectedIndexValue == i {
                appearanceManager.selectionHighlightColor.setFill()
                highlightRect(at: i).fill()
            }

            let content = contentRect(at: i)
            if let iconURL = itemIconURLs[i] {
                let iconFrame = iconRect(at: content.minX, originY: content.midY - iconSide / 2)
                IconCache.shared.icon(for: iconURL).draw(in: iconFrame, from: .zero,
                                                        operation: .sourceOver, fraction: 1,
                                                        respectFlipped: true, hints: nil)
            }

            (drawList[i].name as NSString).draw(in: textRect(at: i), withAttributes: textAttributes)
        }
    }
}
