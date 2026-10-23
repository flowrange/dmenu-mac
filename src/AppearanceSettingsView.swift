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
import Settings
import SwiftUI

struct AppearanceSettingsView: View {
    @StateObject private var model = AppearanceSettingsModel()

    var body: some View {
        Form {
            Section("Window") {
                Picker("Results", selection: $model.resultsLayout) {
                    ForEach(ResultsLayout.allCases, id: \.self) { layout in
                        Text(layout.title).tag(layout)
                    }
                }

                Stepper("Visible rows: \(model.visibleRows)", value: $model.visibleRows,
                        in: AppearanceSettingsModel.visibleRowsRange)
                    .disabled(model.resultsLayout == .horizontal)
                    .help("Vertical results only. The window height is limited to the available screen area.")

                Picker("Position", selection: $model.windowPosition) {
                    ForEach(WindowPosition.allCases, id: \.self) { position in
                        Text(position.title).tag(position)
                    }
                }

                Picker("Screen", selection: $model.screenSelection) {
                    ForEach(ScreenSelection.allCases, id: \.self) { selection in
                        Text(selection.title).tag(selection)
                    }
                }

                Toggle("Full width", isOn: $model.usesFullWidth)

                LabeledContent("Width") {
                    HStack {
                        Slider(value: $model.windowWidth, in: AppearanceSettingsModel.windowWidthRange, step: 10)
                        Text(model.windowWidthText)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 65, alignment: .trailing)
                    }
                }
                .disabled(model.usesFullWidth)
                .help("Limited to the screen's usable width. Applies to every position.")

                Toggle("Blur background", isOn: $model.blurBackground)
                    .help("Blurs the desktop and windows behind the launcher. Opacity controls the background tint.")

                LabeledContent(model.blurBackground ? "Tint opacity" : "Opacity") {
                    HStack {
                        Slider(value: $model.windowOpacity, in: AppearanceSettingsModel.opacityRange)
                        Text(model.opacityText)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 40, alignment: .trailing)
                    }
                }

                Toggle("Show icons", isOn: $model.showIcons)
            }

            Section("Colors") {
                ColorPicker("Search text", selection: $model.searchTextColor)
                ColorPicker("Results text", selection: $model.resultsTextColor)
                ColorPicker("Selection highlight", selection: $model.selectionHighlightColor)
                ColorPicker("Window background", selection: $model.windowBackgroundColor)
            }

            Section("Font") {
                LabeledContent("Font") {
                    HStack {
                        Text(model.fontDisplayName)
                            .foregroundStyle(.secondary)
                        Button("Choose…") {
                            model.chooseFont()
                        }
                    }
                }

                LabeledContent("Size") {
                    HStack {
                        Text(model.fontSizeText)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Stepper("Size", value: $model.fontSize, in: AppearanceSettingsModel.fontSizeRange, step: 1)
                            .labelsHidden()
                    }
                }
            }

            Section {
                HStack {
                    Spacer()
                    Button("Reset to Defaults") {
                        model.resetToDefaults()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: SettingsLayout.paneWidth, height: 600)
    }
}

extension AppearanceSettingsView {
    static func pane() -> SettingsPane {
        Settings.PaneHostingController(pane: Settings.Pane(
            identifier: .appearance,
            title: "Appearance",
            toolbarIcon: NSImage(systemSymbolName: "paintbrush", accessibilityDescription: "Appearance settings")!
        ) {
            AppearanceSettingsView()
        })
    }
}
