//
//  GameScene.swift
//  Square-jitsu
//
//  Created by Jakob Hain on 5/2/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorController {
    struct EditorModelView {
        let editor: Editor
        let editorView: EditorView

        var world: World { editor.editableWorld.world }
    }

    private static let testWorldFileName: String = "test"
    private static let testWorldUrl: URL = WorldFile.localUrl(baseName: testWorldFileName)

    private let userSettings: UserSettings
    private let parent: SKScene
    private let updater: FixedUpdater = FixedUpdater()
    private(set) var loaded: EditorModelView? = nil

    init(userSettings: UserSettings, parent: SKScene) {
        self.userSettings = userSettings
        self.parent = parent
        updater.onTick = tick
    }

    func loadTestWorld() {
        // try! FileManager.default.removeItem(at: EditorController.testWorldUrl)
        load(worldUrl: EditorController.testWorldUrl) { result in
            switch result {
            case .success(()):
                Logger.log("Loaded test world")
            case .failure(let error):
                fatalError("Error loading test world: \(error)")
            }
        }
    }

    func load(worldUrl: URL, completionHandler: @escaping (Result<(), Error>) -> ()) {
        let document = WorldDocument(fileURL: worldUrl)
        document.open { succeeded in
            if succeeded {
                self.load(worldDocument: document)
                completionHandler(.success(()))
            } else {
                completionHandler(.failure(WorldFileSyncError(action: "reading", error: nil)))
            }
        }
    }

    func load(worldDocument: WorldDocument) {
        unload()

        let editor = Editor(worldDocument: worldDocument, userSettings: userSettings)
        let editorView = EditorView(editor: editor, sceneSize: parent.size)
        editorView.placeIn(parent: parent)
        loaded = EditorModelView(editor: editor, editorView: editorView)

        let world = loaded!.world
        updater.fixedDeltaTime = world.settings.fixedDeltaTime / world.speed
        world.didChangeSpeed.subscribe(observer: self) {
            self.updater.fixedDeltaTime = world.settings.fixedDeltaTime / world.speed
        }
    }

    func unload() {
        loaded?.editorView.removeFromParent()
        loaded?.world.didChangeSpeed.unsubscribe(observer: self)

        loaded = nil
    }

    /// Even if paused we still need to update to prevent accumulated ticks
    func update(_ currentTime: TimeInterval) {
        updater.update(currentTime)
    }

    private func tick() {
        if let loaded = loaded {
            switch loaded.editor.state {
            case .editing:
                break
            case .playing:
                loaded.world.tick()
            }
        }
    }
}
