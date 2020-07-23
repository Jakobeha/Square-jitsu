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

        editorTools.didChangeEditSelectMode.subscribe(observer: self, priority: .view) { (self) in
            self.regenerateBody()
        }
        // We subscribe to this because it may change buttons' enabled states
        editorTools.didChangeEditActionMode.subscribe(observer: self, priority: .view) { (self) in
            self.regenerateBody()
        }
    }

    override func newBody() -> UXView {
        HStack([
            Button(
                owner: self,
                textureName: "UI/SelectRect",
                isEnabled: EditSelectMode.rect.canInstantSelect || !editorTools.editAction.mode.requiresSelection,
                isSelected: editorTools.editSelection.mode == .rect
            ) { (self) in self.editorTools.select(selectMode: .rect) },
            Button(
                owner: self,
                textureName: "UI/SelectPrecision",
                isEnabled: EditSelectMode.precision.canInstantSelect || !editorTools.editAction.mode.requiresSelection,
                isSelected: editorTools.editSelection.mode == .precision
            ) { (self) in self.editorTools.select(selectMode: .precision) },
            Button(
                owner: self,
                textureName: "UI/SelectFreehand",
                isEnabled: EditSelectMode.freeHand.canInstantSelect || !editorTools.editAction.mode.requiresSelection,
                isSelected: editorTools.editSelection.mode == .freeHand
            ) { (self) in self.editorTools.select(selectMode: .freeHand) },
            Button(
                owner: self,
                textureName: "UI/SelectSameType",
                isEnabled: EditSelectMode.sameType.canInstantSelect || !editorTools.editAction.mode.requiresSelection,
                isSelected: editorTools.editSelection.mode == .sameType
            ) { (self) in self.editorTools.select(selectMode: .sameType) }
        ])
    }
}
