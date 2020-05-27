//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsActionView: UXCompoundView {
    private let editorTools: EditorTools

    private let tileMenuView: TileMenuView

    private var hasSelection: Bool {
        !editorTools.editAction.selectedPositions.isEmpty
    }

    init(editorTools: EditorTools, settings: WorldSettings) {
        self.editorTools = editorTools
        tileMenuView = TileMenuView(tileMenu: editorTools.tileMenu, settings: settings)
        super.init()

        // We subscribe to changing the action because changing the selection might change buttons' tint colors
        editorTools.didChangeEditAction.subscribe(observer: self) {
            self.regenerateBody()
        }
    }

    override func newBody() -> UXView {
        let instantActionIfSelectTintHue =
                editorTools.editAction.mode.affectsSelection && hasSelection ?
                Button.instantActionButtonTintHue :
                nil
        return HStack([
            Button(
                    textureName: "UI/RemoveTiles",
                    isSelected: editorTools.editAction.mode == .remove,
                    tintHue: instantActionIfSelectTintHue
            ) {
                self.editorTools.select(actionMode: .remove)
            },
            Button(
                    textureName: "UI/MoveTiles",
                    isSelected: editorTools.editAction.mode == .move,
                    tintHue: instantActionIfSelectTintHue
            ) {
                if self.hasSelection && self.editorTools.editAction.mode == .move {
                    // Does something different, because we are already in this mode, we clear the current selection
                    self.editorTools.editAction.selectedPositions.removeAll()
                } else {
                    self.editorTools.select(actionMode: .move)
                }
            },
            Button(
                    textureName: "UI/InspectTiles",
                    isSelected: editorTools.editAction.mode == .inspect,
                    tintHue: instantActionIfSelectTintHue
            ) {
                if self.hasSelection && self.editorTools.editAction.mode == .inspect {
                    // Does something different, because we are already in this mode, we clear the current selection
                    self.editorTools.editAction.selectedPositions.removeAll()
                } else {
                    self.editorTools.select(actionMode: .inspect)
                }
            },
            Button(
                    textureName: editorTools.editAction.mode == .select ? "UI/DeselectTiles" : "UI/SelectTiles",
                    isSelected: editorTools.editAction.mode.affectsSelection,
                    tintHue: Button.selectButtonTintHue
            ) {
                if self.editorTools.editAction.mode == .select {
                   self.editorTools.select(actionMode: .deselect)
                } else {
                    self.editorTools.select(actionMode: .select)
                }
            },
            tileMenuView
        ])
    }
}
