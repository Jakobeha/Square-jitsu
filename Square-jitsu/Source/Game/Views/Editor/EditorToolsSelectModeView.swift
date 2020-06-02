//
//  Created by Jakob Hain on 5/19/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsSelectModeView: UXCompoundView {
    private let editorTools: EditorTools

    init(editorTools: EditorTools) {
        self.editorTools = editorTools
        super.init()

        editorTools.didChangeEditSelectMode.subscribe(observer: self, priority: .view) {
            self.regenerateBody()
        }
        // We subscribe to this because it may change buttons' enabled states
        editorTools.didChangeEditActionMode.subscribe(observer: self, priority: .view) {
            self.regenerateBody()
        }
    }

    override func newBody() -> UXView {
        HStack([
            Button(
                textureName: "UI/SelectRect",
                isEnabled: EditSelectMode.rect.canInstantSelect || !editorTools.editAction.mode.requiresSelection,
                isSelected: editorTools.editSelection.mode == .rect
            ) { self.editorTools.select(selectMode: .rect) },
            Button(
                textureName: "UI/SelectPrecision",
                isEnabled: EditSelectMode.precision.canInstantSelect || !editorTools.editAction.mode.requiresSelection,
                isSelected: editorTools.editSelection.mode == .precision
            ) { self.editorTools.select(selectMode: .precision) },
            Button(
                textureName: "UI/SelectFreehand",
                isEnabled: EditSelectMode.freeHand.canInstantSelect || !editorTools.editAction.mode.requiresSelection,
                isSelected: editorTools.editSelection.mode == .freeHand
            ) { self.editorTools.select(selectMode: .freeHand) },
            Button(
                textureName: "UI/SelectSameType",
                isEnabled: EditSelectMode.sameType.canInstantSelect || !editorTools.editAction.mode.requiresSelection,
                isSelected: editorTools.editSelection.mode == .sameType
            ) { self.editorTools.select(selectMode: .sameType) }
        ])
    }
}
