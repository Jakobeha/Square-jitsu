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

        editor.didChangeState.subscribe(observer: self, priority: .view) { (self) in
            self.regenerateBody()
        }
    }

    override func newBody() -> UXView {
        switch editor.state {
        case .playing:
            return Button(owner: self, textureName: "UI/Pause") { (self) in self.editor.state = .editing }
        case .editing:
            return VStack([
                Button(owner: self, textureName: "UI/Play") { (self) in self.editor.state = .playing },
                Button(owner: self, textureName: "UI/ResetWorld") { (self) in self.editor.editableWorld.world.resetExceptForPlayer() },
                Button(owner: self, textureName: "UI/ResetPlayer") { (self) in self.editor.editableWorld.world.resetPlayer() }
            ])
        }
    }
}
