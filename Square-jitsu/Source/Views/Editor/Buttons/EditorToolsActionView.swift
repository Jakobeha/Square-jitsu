//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsActionView: UXCompoundView {
    private let editorTools: EditorTools

    private let tileMenuView: TileMenuView

    private var editActionMode: EditActionMode {
        editorTools.editAction.mode
    }

    private var hasSelection: Bool {
        !editorTools.editAction.selectedPositions.isEmpty
    }

    init(editorTools: EditorTools, settings: WorldSettings) {
        self.editorTools = editorTools
        tileMenuView = TileMenuView(tileMenu: editorTools.tileMenu, settings: settings)
        super.init()

        // We subscribe to changing the action because changing the selection might change buttons' tint colors
        editorTools.didChangeEditAction.subscribe(observer: self, priority: .view) { (self) in
            self.regenerateBody()
        }
    }

    override func newBody() -> UXView {
        let instantActionIfSelectTintHue =
                editActionMode.affectsSelection && hasSelection ?
                Button.instantActionButtonTintHue :
                nil
        return HStack([
            Button(
                owner: self,
                textureName: "UI/RemoveTiles",
                isSelected: editActionMode == .remove,
                tintHue: instantActionIfSelectTintHue
            ) { (self) in
                self.editorTools.select(actionMode: .remove)
            },
            Button(
                owner: self,
                textureName: editActionMode == .copy ? "UI/CopyTiles" : "UI/MoveTiles",
                rouletteNextItemTextureName: editActionMode == .copy ? "UI/MoveTiles" : "UI/CopyTiles",
                isSelected: editActionMode == .move || editActionMode == .copy,
                tintHue: instantActionIfSelectTintHue
            ) { (self) in
                self.editorTools.select(actionMode: self.editActionMode == .move ? .copy : .move)
            },
            Button(
                owner: self,
                textureName: "UI/InspectTiles",
                isSelected: editActionMode == .inspect,
                tintHue: instantActionIfSelectTintHue
            ) { (self) in
                self.editorTools.select(actionMode: .inspect)
            },
            Button(
                owner: self,
                textureName: editActionMode == .deselect ? "UI/DeselectTiles" : "UI/SelectTiles",
                rouletteNextItemTextureName: editActionMode == .deselect ? "UI/SelectTiles" : "UI/DeselectTiles",
                isSelected: editActionMode == .select || editActionMode == .deselect
            ) { (self) in
                self.editorTools.select(actionMode: self.editActionMode == .select ? .deselect : .select)
            },
            tileMenuView
        ])
    }
}
