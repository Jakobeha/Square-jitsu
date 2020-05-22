//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsTopView: UXCompoundView {
    private let editorTools: EditorTools

    private let tileMenuView: TileMenuView

    init(editorTools: EditorTools) {
        self.editorTools = editorTools
        tileMenuView = TileMenuView(tileMenu: editorTools.tileMenu, settings: editorTools.world.settings)
    }

    override func newBody() -> UXView {
        editorTools.editAction.mode.requiresSelection ? HStack([
            Button(textureName: "UI/PlaceTiles") { print("TODO") },
            Button(textureName: "UI/RemoveTiles") { print("TODO") },
            Button(textureName: "UI/SelectTiles") { print("TODO") },
            tileMenuView
        ]) : HStack([
            Button(textureName: "UI/MoveTiles") { print("TODO") },
            Button(textureName: "UI/InspectTiles") { print("TODO") },
            Button(textureName: "UI/SelectTiles", isSelected: true) { print("TODO") },
            tileMenuView
        ])
    }
}
