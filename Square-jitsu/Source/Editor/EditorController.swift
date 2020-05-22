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
    private static let testWorldUrl: URL = Bundle.main.resourceURL!.appendingPathComponent("\(testWorldFileName).\(WorldFile.fileExtension)")

    private let userSettings: UserSettings
    private let parent: SKNode
    private let updater: FixedUpdater = FixedUpdater()
    private(set) var loaded: EditorModelView? = nil

    init(userSettings: UserSettings, parent: SKNode) {
        self.userSettings = userSettings
        self.parent = parent
        updater.onTick = tick
    }

    func loadTestWorld() {
        try! load(worldUrl: EditorController.testWorldUrl)
    }

    func load(worldUrl: URL) throws {
        try load(worldDocument: WorldDocument(fileURL: worldUrl))
    }

    func load(worldDocument: WorldDocument) throws {
        load(worldFile: try worldDocument.getFile())
    }

    func load(worldFile: WorldFile) {
        unload()

        let editor = Editor(editableWorld: EditableWorld(worldFile: worldFile, userSettings: userSettings))
        let editorView = EditorView(editor: editor)
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
