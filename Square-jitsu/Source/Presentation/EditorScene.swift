//
//  Created by Jakob Hain on 5/2/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorScene: SJScene {
    private let settings: UserSettings = UserSettings()
    private(set) var editorController: EditorController! {
        willSet {
            if editorController != nil {
                fatalError("worldController shouldn't be set twice")
            }
        }
    }

    override var size: CGSize {
        didSet { settings.screenSize = size }
    }

    private var loadedEditor: Editor? {
        editorController.loaded?.editor
    }

    private var loadedWorld: World? {
        editorController.loaded?.world
    }

    override init(size: CGSize) {
        super.init(size: size)
        editorController = EditorController(userSettings: settings, parent: self)
        settings.screenSize = size
    }

    required init(coder: NSCoder) {
        fatalError("EditorScene can't be encoded or decoded")
    }

    override func update(_ currentTime: TimeInterval) {
        editorController.update(currentTime)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        loadedEditor?.touchesBegan(touches, with: event, container: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        loadedEditor?.touchesMoved(touches, with: event, container: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        loadedEditor?.touchesEnded(touches, with: event, container: self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        loadedEditor?.touchesCancelled(touches, with: event, container: self)
    }
}
