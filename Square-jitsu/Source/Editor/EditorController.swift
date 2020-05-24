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
        if !FileManager.default.fileExists(atPath: EditorController.testWorldUrl.path) {
            FileManager.default.createFile(atPath: EditorController.testWorldUrl.path, contents: nil)
        }
        try! load(worldUrl: EditorController.testWorldUrl)
    }

    func load(worldUrl: URL) throws {
        let document = WorldDocument(fileURL: worldUrl)
        document.open()
        try load(worldDocument: document)
    }

    func load(worldDocument: WorldDocument) throws {
        unload()

        let editor = try Editor(worldDocument: worldDocument, userSettings: userSettings)
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
