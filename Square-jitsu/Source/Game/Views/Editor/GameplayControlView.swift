//
//  Created by Jakob Hain on 5/19/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class GameplayControlView: UXCompoundView {
    private let editor: Editor

    init(editor: Editor) {
        self.editor = editor
        super.init()

        editor.didChangeState.subscribe(observer: self, handler: regenerateBody)
    }

    override func newBody() -> UXView {
        switch editor.state {
        case .playing:
            return Button(textureName: "UI/Pause") { self.editor.state = .editing }
        case .editing:
            return VStack([
                Button(textureName: "UI/Play") { self.editor.state = .playing },
                Button(textureName: "UI/ResetWorld") { self.editor.editableWorld.world.resetExceptForPlayer() },
                Button(textureName: "UI/ResetPlayer") { self.editor.editableWorld.world.resetPlayer() }
            ])
        }
    }
}
